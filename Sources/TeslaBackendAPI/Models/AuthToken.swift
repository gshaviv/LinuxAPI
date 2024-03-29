//
//  File.swift
//  
//
//  Created by Guy on 24/02/2023.
//

import Foundation

private let oAuthClientID: String = "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef21067963841234334232123232323232"
private let oAuthWebClientID: String = "ownerapi"
private let oAuthClientSecret: String = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
private let oAuthScope: String = "openid email offline_access"
private let oAuthRedirectURI: String = "https://auth.tesla.com/void/callback"

extension Tesla {
  public struct AuthToken: Codable {
    public let accessToken: String
    public let tokenType: String?
    public let expiresIn: TimeInterval?
    public let refreshToken: String?
    public let idToken: String?
    public var createdAt: TimeInterval?
    public enum Region: String, Codable {
      case northAmerica = "na"
      case europe = "eu"
      static let middleEast = Region.europe
      static let africa = Region.europe
      static let asiaPacific = Region.northAmerica
    }
    public var region: Region?
    
    public init(accessToken: String, tokenType: String?, expiresIn: TimeInterval?, refreshToken: String?, idToken: String?, region: Region) {
      self.accessToken = accessToken
      self.tokenType = tokenType
      self.expiresIn = expiresIn
      self.refreshToken = refreshToken
      self.idToken = idToken
      self.region = region
    }
    
    private enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case tokenType = "token_type"
      case expiresIn = "expires_in"
      case refreshToken  = "refresh_token"
      case idToken = "id_token"
      case region
      case createdAt = "created_at"
    }
    
    public var expirationDate: Date? {
      if let createdAt, let expiresIn {
        return Date(timeIntervalSince1970: createdAt + expiresIn)
      } else {
        return nil
      }
    }
    
    public mutating func createdNow() {
      createdAt = Date().timeIntervalSince1970
    }
  }
}
