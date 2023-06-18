//
//  File.swift
//
//
//  Created by Guy on 24/02/2023.
//


import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

var loggingEnabled = false

public enum TeslaAPIError: Error, LocalizedError {
  case badURL
  case network(HTTPStatusCode)
  case refreshTokenMissing
  
  public var errorDescription: String? {
    switch self {
    case .badURL: return "bad URL"
    case .network(let code): return "network status: \(code)"
    case .refreshTokenMissing: return "Refresh token missing"
    }
  }
}

protocol IntString {}
extension String : IntString {}
extension Int: IntString {}
extension Int64: IntString {}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}

internal enum TeslaAPI {
  private static let host = "https://owner-api.teslamotors.com"
  fileprivate static let authHost = "https://auth.tesla.com"
  private static let session: URLSession = {
    let config = URLSessionConfiguration.default
    config.httpMaximumConnectionsPerHost = 12
    config.httpShouldUsePipelining = true
    return URLSession(configuration: config)
  }()
  public static var logger: ((String, String, Data?, String?, HTTPStatusCode?) -> Void)?

  
  static func call<R: Decodable>(host: String? = nil,
                                 endpoint: IntString...,
                                 method: HTTPMethod? = nil,
                                 token: AuthToken?,
                                 onTokenRefresh: OnRefreshBlock?) async throws -> R {
    return try await call(host: host, endpoint: endpoint, method: method, body: false, token: token, onTokenRefresh: onTokenRefresh)
  }
  
  static func call<R: Decodable>(host: String? = nil,
                                               endpoint: IntString...,
                                               method: HTTPMethod? = nil,
                                               body: Any,
                                               token: AuthToken?,
                                               onTokenRefresh: OnRefreshBlock?) async throws -> R {
    return try await call(host: host, endpoint: endpoint, method: method, body: body, token: token, onTokenRefresh: onTokenRefresh)
  }
  
  static private func call<R: Decodable>(host: String?,
                                                       endpoint: [IntString],
                                                       method: HTTPMethod?,
                                                       body: Any,
                                                       token: AuthToken?,
                                                       onTokenRefresh: OnRefreshBlock?) async throws -> R {
    let urlStr = "\(host ?? Self.host)/\(endpoint.map { String(describing: $0) }.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }.joined(separator: "/"))"
    guard let url = URL(string: urlStr) else {
      throw TeslaAPIError.badURL
    }
    
    var request = URLRequest(url: url)
    
    if body is Bool {
      if let method {
        request.httpMethod = method.rawValue
      }
    } else if let body = body as? [String: Any] {
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "content-type")
    } else if let body = body as? Encodable {
      request.httpBody = try teslaJSONEncoder.encode(body)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "content-type")
    } else if let method {
      request.httpMethod = method.rawValue
    }
    
    if host == nil, let token {
      request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
    }
      
    let data: Data
    do {
      data = try await session.data(for: request)
    } catch HTTPError.statusCode(.unauthorized) {
      logger?(request.httpMethod ?? "GET", urlStr, request.httpBody, nil, .unauthorized)
      guard let onTokenRefresh, let token else {
        throw HTTPError.statusCode(.unauthorized)
      }
      let refreshedToken = try await TeslaTokenRefresher.shared.refresh(token: token)
      await onTokenRefresh(refreshedToken)
      return try await call(host: host, endpoint: endpoint, method: method, body: body, token: refreshedToken, onTokenRefresh: nil)
    } catch HTTPError.statusCode(let code) {
      if let logger {
        logger(request.httpMethod ?? "GET", urlStr, request.httpBody, nil, code)
      }
      throw TeslaAPIError.network(code)
    }
    
    if let logger, let str = String(data: data, encoding: .utf8) {
      logger(request.httpMethod ?? "GET", urlStr, request.httpBody, str, nil)
    }
    
    if host == nil {
      let result = try teslaJSONDecoder.decode(TeslaResponse<R>.self, from: data)
      return result.response
    } else {
      return try teslaJSONDecoder.decode(R.self, from: data)
    }
  }
  
  internal static let teslaJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .secondsSince1970
    return encoder
  }()
  
  internal static let teslaJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder -> Date in
      let container = try decoder.singleValueContainer()
      if let dateDouble = try? container.decode(Double.self) {
        return Date(timeIntervalSince1970: dateDouble)
      } else {
        let dateString = try container.decode(String.self)
        let dateFormatter = ISO8601DateFormatter()
        var date = dateFormatter.date(from: dateString)
        guard let date = date else {
          throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return date
      }
    }
    return decoder
  }()
}

struct RefreshTokenRequest: Encodable {
  var refreshToken: String
  private(set) var grantType = "refresh_token"
  private(set) var clientID = "ownerapi"
  private(set) var clientSecret = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
  private(set) var scope = "openid email offline_access"
  
  private enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh_token"
    case grantType = "grant_type"
    case clientID = "client_id"
    case clientSecret = "client_secret"
    case scope
  }
}

private struct TeslaResponse<T: Decodable>: Decodable {
  let response: T
}

public actor TeslaTokenRefresher {
  public static let shared = TeslaTokenRefresher()
  
  private var ongoing = [String: Task<AuthToken, Error>]()
  public var makeRefreshTask: (String, AuthToken) -> Task<AuthToken, Error> = { refreshToken, token  in
    Task {
      let request = RefreshTokenRequest(refreshToken: refreshToken)
      let refreshedToken: AuthToken = try await TeslaAPI.call(host: TeslaAPI.authHost, endpoint: "/oauth2/v3/token", body: request, token: token, onTokenRefresh: nil)
      return refreshedToken
    }
  }
  
  func refresh(token: AuthToken) async throws -> AuthToken {
    if let task = ongoing[token.accessToken] {
      return try await task.value
    }
    
    guard let refreshToken = token.refreshToken else {
      throw TeslaAPIError.refreshTokenMissing
    }
    
    let task = makeRefreshTask(refreshToken, token)
    
    ongoing[token.accessToken] = task
    do {
      let refreshedToken = try await task.value
      ongoing[token.accessToken] = nil
      return refreshedToken
    } catch {
      ongoing[token.accessToken] = nil
      throw error
    }
  }
}


