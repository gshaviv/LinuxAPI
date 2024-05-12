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

protocol IntString {}
extension String: IntString {}
extension Int: IntString {}
extension Int64: IntString {}

extension Tesla {
  public enum TeslaAPIError: Error, LocalizedError {
    case badURL
    case network(HTTPStatusCode)
    case refreshTokenMissing
    case message(String)
    
    public var errorDescription: String? {
      switch self {
      case .badURL: return "bad URL"
      case .network(let code): return "network status: \(code)"
      case .refreshTokenMissing: return "Refresh token missing"
      case .message(let string): return string
      }
    }
  }
  
  enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }
  
 public  enum API {
    public enum Region: Hashable {
      case northAmeria
      case europe
      case noRegion
      
      public var host: String {
        switch self {
        case .noRegion: return "https://owner-api.teslamotors.com"
        case .northAmeria: return "https://fleet-api.prd.na.vn.cloud.tesla.com"
        case .europe: return "https://fleet-api.prd.eu.vn.cloud.tesla.com"
        }
      }
    }

    fileprivate static let authHost = "https://auth.tesla.com"
    fileprivate static let authEndpoint = "/oauth2/v3/token"
    private static let session: URLSession = {
      let config = URLSessionConfiguration.default
      config.httpMaximumConnectionsPerHost = 12
      config.timeoutIntervalForResource = 15
      config.urlCache = nil
      return URLSession(configuration: config)
    }()

   // (http method, url, body, body str, errorCode, response headers)
   public static var logger: ((String, String, Data?, String?, HTTPStatusCode?, [String: String]?) -> Void)?
    static func call<R: Decodable>(host: String? = nil,
                                   endpoint: IntString...,
                                   method: HTTPMethod? = nil,
                                   token: () async -> AuthToken?,
                                   onTokenRefresh: RefreshBlock?) async throws -> R
    {
      try await call(host: host, endpoint: endpoint, method: method, body: false, token: token, onTokenRefresh: onTokenRefresh)
    }
    
    static func call<R: Decodable>(host: String? = nil,
                                   endpoint: IntString...,
                                   method: HTTPMethod? = nil,
                                   body: Any,
                                   token: () async -> AuthToken?,
                                   onTokenRefresh: RefreshBlock?) async throws -> R
    {
      try await call(host: host, endpoint: endpoint, method: method, body: body, token: token, onTokenRefresh: onTokenRefresh)
    }
    
    private static func call<R: Decodable>(host: String?,
                                           endpoint: [IntString],
                                           method: HTTPMethod?,
                                           body: Any,
                                           token tokenFetcher: () async -> AuthToken?,
                                           onTokenRefresh: RefreshBlock?) async throws -> R
    {
      let callRoot: String
      let token = await tokenFetcher()
      if let host {
        callRoot = host
      } else {
        let region: Region
        switch token?.region {
        case .none:
          region = .noRegion
        case .northAmerica:
          region = .northAmeria
        case .europe:
          region = .europe
        }
        let host = region.host
        callRoot = host
      }
      
      let urlStr = "\(callRoot)/\(endpoint.map { String(describing: $0) }.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }.joined(separator: "/"))"
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
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      } else if let body = body as? Encodable {
        request.httpBody = try teslaJSONEncoder.encode(body)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      } else if let method {
        request.httpMethod = method.rawValue
      }
      
      if let token {
        request.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
      }
      request.setValue("TeslaSwift", forHTTPHeaderField: "User-Agent")
      
      let data: Data
      var response: URLResponse? = nil
      do {
        (data, response) = try await session.data(for: request)
        guard let response else {
          throw URLError(.badServerResponse)
        }
        guard response.code == .ok else {
          throw HTTPError.statusCode(response.code)
        }
        if logger != nil, let str = String(data: data, encoding: .utf8) {
          logger?(request.httpMethod ?? "GET", urlStr, request.httpBody, str, nil, (response as? HTTPURLResponse)?.allHeaderFields as? [String: String])
        }
      } catch HTTPError.statusCode(.unauthorized) {
        logger?(request.httpMethod ?? "GET", urlStr, request.httpBody, nil, .unauthorized, nil)
        guard let onTokenRefresh else {
          throw HTTPError.statusCode(.unauthorized)
        }
        if try await onTokenRefresh() {
          return try await call(host: host, endpoint: endpoint, method: method, body: body, token: tokenFetcher, onTokenRefresh: nil)
        } else {
          throw HTTPError.statusCode(.unauthorized)
        }
        
      } catch HTTPError.statusCode(let code) {
        logger?(request.httpMethod ?? "GET", urlStr, request.httpBody, nil, code, (response as? HTTPURLResponse)?.allHeaderFields as? [String: String])
        throw TeslaAPIError.network(code)
      }
      
      if host == nil {
        let result = try teslaJSONDecoder.decode(TeslaResponse<R>.self, from: data)
        return result.response
      } else {
        do {
          return try teslaJSONDecoder.decode(R.self, from: data)
        } catch {
          logger?(request.httpMethod ?? "GET", urlStr, request.httpBody, (error as? LocalizedError)?.errorDescription ?? error.localizedDescription, nil, nil)
          throw error
        }
      }
    }
    
    static let teslaJSONEncoder: JSONEncoder = {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      encoder.dateEncodingStrategy = .secondsSince1970
      return encoder
    }()
    
    static let teslaJSONDecoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        if let dateDouble = try? container.decode(Double.self) {
          return Date(timeIntervalSince1970: dateDouble)
        } else {
          let dateString = try container.decode(String.self)
          let dateFormatter = ISO8601DateFormatter()
          var date = dateFormatter.date(from: dateString)
          guard let date else {
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
    
    static let credentials: [(clientID: String, clientSecret: String, scope: String)] = [
      (clientID: "ownerapi",
       clientSecret: "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3",
       scope: "openid email offline_access"),
      (clientID: "81aa009288f7-4dac-8d69-97fcc04fa737",
       clientSecret: "ta-secret.*AciQd9Q2Db&+yG*",
       scope: "openid user_data vehicle_device_data offline_access vehicle_cmds vehicle_charging_cmds"),
    ]
    static let ownerAPI = 0
    static let fleetAPI = 1
    let kind: Int
    let grantType = "refresh_token"

    var clientID: String {
      Self.credentials[kind].clientID
    }

    var clientSecret: String {
      Self.credentials[kind].clientSecret
    }

    var scope: String {
      Self.credentials[kind].scope
    }
    
    private enum CodingKeys: String, CodingKey {
      case refreshToken = "refresh_token"
      case grantType = "grant_type"
      case clientID = "client_id"
//      case clientSecret = "client_secret"
//      case scope
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
//      try container.encode(scope, forKey: .scope)
      try container.encode(clientID, forKey: .clientID)
//      try container.encode(clientSecret, forKey: .clientSecret)
      try container.encode(refreshToken, forKey: .refreshToken)
      try container.encode(grantType, forKey: .grantType)
    }
  }
  
  struct GenerateTokenRequest: Encodable {
    let code: String
    let kind: Int
    let grantType = "authorization_code"
    let audience: String
    let redirect = "https://myt-server.fly.dev/oauth/redirect"

    var clientID: String {
      RefreshTokenRequest.credentials[kind].clientID
    }

    var clientSecret: String {
      RefreshTokenRequest.credentials[kind].clientSecret
    }

    var scope: String {
      RefreshTokenRequest.credentials[kind].scope
    }
    
    private enum CodingKeys: String, CodingKey {
      case grantType = "grant_type"
      case clientID = "client_id"
      case clientSecret = "client_secret"
      case code
      case audience
      case redirect = "redirect_uri"
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(code, forKey: .code)
      try container.encode(clientID, forKey: .clientID)
      try container.encode(clientSecret, forKey: .clientSecret)
      try container.encode(grantType, forKey: .grantType)
      try container.encode(audience, forKey: .audience)
      try container.encode(redirect, forKey: .redirect)
    }
  }
  
  internal struct TeslaResponse<T: Decodable>: Decodable {
    let response: T
  }
  
  public actor TeslaTokenRefresher {
    public static let shared = TeslaTokenRefresher()
    
    private var ongoing = [String: Task<AuthToken, Error>]()
    public var makeRefreshTask: (String?, AuthToken.Region?) -> Task<AuthToken, Error> = { refreshToken, region in
      Task {
        guard let refreshToken else {
          throw TeslaAPIError.refreshTokenMissing
        }
        let request = RefreshTokenRequest(refreshToken: refreshToken, kind: region == nil ? RefreshTokenRequest.ownerAPI : RefreshTokenRequest.fleetAPI)
        var refreshedToken: AuthToken = try await API.call(host: API.authHost, endpoint: API.authEndpoint, body: request, token: { nil }, onTokenRefresh: nil)
        refreshedToken.region = region
        refreshedToken.createdNow()
        return refreshedToken
      }
    }
    
    public func refresh(token: AuthToken, refreshToken: String? = nil) async throws -> AuthToken {
      let key = refreshToken ?? token.refreshToken ?? ""
      if let task = ongoing[key] {
        return try await task.value
      }
      let task = makeRefreshTask(refreshToken ?? token.refreshToken, token.region)
      
      ongoing[key] = task
      do {
        let refreshedToken = try await task.value
        ongoing[key] = nil
        return refreshedToken
      } catch {
        ongoing[key] = nil
        throw error
      }
    }
    
    public func setRefreshTaskMaker(_ refreshMaker: @escaping (String?, AuthToken.Region?) -> Task<AuthToken, Error>) {
      makeRefreshTask = refreshMaker
    }
  }
  
  public static func exchange(code: String) async throws -> AuthToken {
    let request = GenerateTokenRequest(code: code, kind: RefreshTokenRequest.fleetAPI, audience: [API.Region.northAmeria, API.Region.europe].map { $0.host }.joined(separator: " "))
    return try await API.call(host: API.authHost, endpoint: API.authEndpoint, body: request, token: { nil }, onTokenRefresh: nil)
  }
}
