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

public struct AuthToken: Codable {
  public let accessToken: String
  public let tokenType: String?
  public let expiresIn: TimeInterval?
  public let refreshToken: String?
  public let idToken: String?
  
  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken  = "refresh_token"
    case idToken = "id_token"
  }
}
