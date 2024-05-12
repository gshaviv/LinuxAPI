//
//  File.swift
//
//
//  Created by Guy on 26/02/2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if os(Linux)

extension URLSession {
  func data(from url: URL) async throws -> (Data, URLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let task = self.dataTask(with: url) { data, response, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        guard let response else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }
        guard let data else {
          let error = URLError(.badServerResponse)
          return continuation.resume(throwing: error)
        }

        continuation.resume(returning: (data, URLResponse)
        )
      }

      task.resume()
    }
  }
  
  func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let task = self.dataTask(with: urlRequest) { data, response, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        guard let response else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }
        guard let data else {
          let error = URLError(.badServerResponse)
          return continuation.resume(throwing: error)
        }
        
        continuation.resume(returning: (data, response))
      }
      
      task.resume()
    }
  }
}
#endif

extension URLResponse {
  var code: HTTPStatusCode {
    HTTPStatusCode(rawValue: (self as? HTTPURLResponse)?.statusCode ?? 0) ?? .unknown
  }
}

public enum HTTPError: Error {
  case statusCode(HTTPStatusCode)
}

public enum HTTPStatusCode: Int {
  case `continue` = 100
  case switchingProtocols = 101
  case ok = 200
  case created = 201
  case accepted = 202
  case nonAuthorative = 203
  case noContent = 204
  case resetContent = 205
  case partialContent = 206
  case multipleChoices = 300
  case moved = 301
  case found = 302
  case seeOther = 303
  case notModified = 304
  case useProxy = 305
  case temporaryRedirect = 307
  case badRequest = 400
  case unauthorized = 401
  case paymentRequired = 402
  case forbidden = 403
  case notFound = 404
  case methodNotAllowed = 405
  case notAcceptable = 406
  case proxyAuthenticationRequired = 407
  case timeout = 408
  case conflict = 409
  case gone = 410
  case lengthRequired = 411
  case preconditionFailed = 412
  case entityTooLarge = 413
  case uriTooLarge = 414
  case unsupportedMediaType = 415
  case requestedRangeNotSatisfied = 416
  case expectationFailed = 417
  case misdirectedRequest = 421
  case unprocessableEntity = 422
  case locked = 423
  case failedDependency = 424
  case upgradeRequired = 426
  case preconditionRequired = 428
  case tooManyRequests = 429
  case requestHeaderFieldsTooLarge = 431
  case unavailableForLegalReasons = 451
  case internalServerError = 500
  case notImplemented = 501
  case badGateway = 502
  case serviceUnavailable = 503
  case gatewayTimeout = 504
  case httpVersionNotSupported = 505
  case vehicleServerError = 540
  case unknown
}

extension HTTPStatusCode: CustomStringConvertible {
  public var stringValue: String {
    switch self {
    case .continue:
      return "continue"
    case .switchingProtocols:
      return "Switching Protocols"
    case .ok:
      return "ok"
    case .created:
      return "created"
    case .accepted:
      return "Accepted"
    case .nonAuthorative:
      return "Non Authorative"
    case .noContent:
      return "No Content"
    case .resetContent:
      return "Reset Content"
    case .partialContent:
      return "Partial Content"
    case .multipleChoices:
      return "Multiple Choises"
    case .moved:
      return "Moved"
    case .found:
      return "Found"
    case .seeOther:
      return "See Other"
    case .notModified:
      return "Not Modified"
    case .useProxy:
      return "Use Proxy"
    case .temporaryRedirect:
      return "Temporary Redirect"
    case .badRequest:
      return "Bad Request"
    case .unauthorized:
      return "Unauthorized"
    case .paymentRequired:
      return "Payment Required"
    case .forbidden:
      return "Forbidden"
    case .notFound:
      return "Not Found"
    case .methodNotAllowed:
      return "Method not allowed"
    case .notAcceptable:
      return "Not Acceptable"
    case .proxyAuthenticationRequired:
      return "Proxy Authentication Required"
    case .timeout:
      return "Timeout"
    case .conflict:
      return "Conflict"
    case .gone:
      return "Gone"
    case .lengthRequired:
      return "Length Required"
    case .preconditionFailed:
      return "Precondition Failed"
    case .entityTooLarge:
      return "Entity too large"
    case .uriTooLarge:
      return "URI too large"
    case .unsupportedMediaType:
      return "Unsupported media type"
    case .requestedRangeNotSatisfied:
      return "Requested Range not satisfied"
    case .expectationFailed:
      return "Expectation failed"
    case .misdirectedRequest:
      return "Misdirected request"
    case .unprocessableEntity:
      return "Unprocessable entity"
    case .locked:
      return "locked"
    case .failedDependency:
      return "Failed dependency"
    case .upgradeRequired:
      return "Upgrade required"
    case .preconditionRequired:
      return "Preconditin required"
    case .tooManyRequests:
      return "Too many resources"
    case .requestHeaderFieldsTooLarge:
      return "request header field too large"
    case .unavailableForLegalReasons:
      return "unavailable for legal reasons"
    case .internalServerError:
      return "internal server error"
    case .notImplemented:
      return "Not implemented"
    case .badGateway:
      return "Bad Gateway"
    case .serviceUnavailable:
      return "Server unavailable"
    case .gatewayTimeout:
      return "Gateway timeout"
    case .httpVersionNotSupported:
      return "http version not supported"
    case .vehicleServerError:
      return "Vehicle server error"
    case .unknown:
      return "unknown"
    }
  }
  
  public var description: String {
    return "Status \(rawValue): \(stringValue)"
  }
}


extension HTTPError: LocalizedError {
  public var errorDescription: String? {
    if case let .statusCode(code) = self {
      return code.description
    } else {
      return nil
    }
  }
}
