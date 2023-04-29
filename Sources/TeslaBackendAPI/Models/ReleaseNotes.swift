//
//  File.swift
//  
//
//  Created by Guy on 29/04/2023.
//

import Foundation

public struct ReleaseNotes: Codable {
  public struct Note: Codable {
    public let title: String
    public let subtitle: String
    public let description: String
    public let imageUrl: String
    public let customerVersion: String
    
    private enum CodingKeys: String, CodingKey {
      case title, subtitle, description
      case customerVersion = "customer_version"
      case imageUrl = "image_url"
    }
  }
  public let releaseNotes: [Note]
  public let deployedVersion: String
  public let stagedVersion: String?
  private enum CodingKeys: String, CodingKey {
    case releaseNotes = "release_notes"
    case deployedVersion = "deployed_version"
    case stagedVersion = "staged_version"
  }
}
