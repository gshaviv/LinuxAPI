//
//  ChargingLocation.swift
//  
//
//  Created by Guy Shaviv on 08/08/2023.
//

import Foundation

extension Tesla {
  public struct ChargingLocation: Decodable {
    struct AbbreviatedLocation: Decodable {
      let lat: Double
      let long: Double
    }
    
    public let location: (longitude: Double, latitude: Double)
    public let name: String
    public enum ChargerType: String, Codable {
      case supercharger
      case destination
    }
    
    public let type: ChargerType
    public let distance: Distance
    public let availableStalls: Int?
    public let totalStalls: Int?
    public let isClosed: Bool?
    
    private enum CodingKeys: String, CodingKey {
      case location
      case name
      case type
      case distance = "distance_miles"
      case availableStalls = "available_stalls"
      case totalStalls = "total_stalls"
      case isClosed = "site_closed"
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let loc = try container.decode(AbbreviatedLocation.self, forKey: .location)
      self.location = (longitude: loc.long, latitude: loc.lat)
      self.name = try container.decode(String.self, forKey: .name)
      self.type = try container.decode(ChargingLocation.ChargerType.self, forKey: .type)
      self.distance = try container.decode(Distance.self, forKey: .distance)
      self.availableStalls = try container.decodeIfPresent(Int.self, forKey: .availableStalls)
      self.totalStalls = try container.decodeIfPresent(Int.self, forKey: .totalStalls)
      self.isClosed = try container.decodeIfPresent(Bool.self, forKey: .isClosed)
    }
  }
}
