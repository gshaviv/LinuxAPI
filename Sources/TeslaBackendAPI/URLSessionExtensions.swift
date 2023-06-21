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
  func data(from url: URL) async throws -> Data {
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
        guard response.code == .ok else {
          continuation.resume(throwing: HTTPError.statusCode(response.code))
          return
        }
        guard let data else {
          let error = URLError(.badServerResponse)
          return continuation.resume(throwing: error)
        }

        continuation.resume(returning: data)
      }

      task.resume()
    }
  }
  
  func data(for urlRequest: URLRequest) async throws -> Data {
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
        guard response.code == .ok else {
          continuation.resume(throwing: HTTPError.statusCode(response.code))
          return
        }
        guard let data else {
          let error = URLError(.badServerResponse)
          return continuation.resume(throwing: error)
        }
        
        continuation.resume(returning: data)
      }
      
      task.resume()
    }
  }
}

#else

extension URLSession {
  func data(from url: URL) async throws -> Data {
    let (data, response) = try await self.data(from: url)
    guard response.code == .ok else {
      throw HTTPError.statusCode(response.code)
    }
    return data
  }

  func data(for urlRequst: URLRequest) async throws -> Data {
    let (data, response) = try await self.data(for: urlRequst)
    guard response.code == .ok else {
      throw HTTPError.statusCode(response.code)
    }
    return data
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
