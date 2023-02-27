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

enum TeslaAPIError: Error, LocalizedError {
  case badURL
  case network(HTTPStatusCode)
  
  var errorDescription: String? {
    switch self {
    case .badURL: return "bad URL"
    case .network(let code): return "network status: \(code)"
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
  private static let authHost = "https://auth.tesla.com"
  private static let session: URLSession = {
    let config = URLSessionConfiguration.default
    return URLSession(configuration: config)
  }()
  
  static func call<R: Decodable>(host: String? = nil,
                                 endpoint: IntString...,
                                 method: HTTPMethod? = nil,
                                 token: AuthToken?,
                                 onTokenRefresh: ((AuthToken) -> Void)?) async throws -> R {
    return try await call(host: host, endpoint: endpoint, method: method, body: Bool?.none, token: token, onTokenRefresh: onTokenRefresh)
  }
  
  static func call<B: Encodable, R: Decodable>(host: String? = nil,
                                               endpoint: IntString...,
                                               method: HTTPMethod? = nil,
                                               body: B,
                                               token: AuthToken?,
                                               onTokenRefresh: ((AuthToken) -> Void)?) async throws -> R {
    return try await call(host: host, endpoint: endpoint, method: method, body: body, token: token, onTokenRefresh: onTokenRefresh)
  }
  
  static private func call<B: Encodable, R: Decodable>(host: String?,
                                                       endpoint: [IntString],
                                                       method: HTTPMethod?,
                                                       body: B?,
                                                       token: AuthToken?,
                                                       onTokenRefresh: ((AuthToken) -> Void)?) async throws -> R {
    let urlStr = "\(host ?? Self.host)/\(endpoint.map { String(describing: $0) }.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }.joined(separator: "/"))"
    guard let url = URL(string: urlStr) else {
      throw TeslaAPIError.badURL
    }
    
    var request = URLRequest(url: url)
    
    if let body {
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
      guard let onTokenRefresh, let token, let refreshToken = token.refreshToken else {
        throw HTTPError.statusCode(.unauthorized)
      }
      print("Refreshing token")
      let request = RefreshTokenRequest(refreshToken: refreshToken)
      let refreshedToken: AuthToken = try await call(host: authHost, endpoint: "/oauth2/v3/token", body: request, token: token, onTokenRefresh: nil)
      onTokenRefresh(refreshedToken)
      return try await call(host: host, endpoint: endpoint, method: method, body: body, token: refreshedToken, onTokenRefresh: nil)
    } catch HTTPError.statusCode(let code) {
      throw TeslaAPIError.network(code)
    }
    
    if loggingEnabled, let str = String(data: data, encoding: .utf8) {
      print("- URL:\n\(urlStr)\n- Response:\n\(str)")
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
