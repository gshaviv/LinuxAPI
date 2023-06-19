//
//  GuiSettings.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 17/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

extension TeslaBackendAPI {
  public struct GuiSettings: Codable {
    public let distanceUnits: String?
    public let temperatureUnits: String?
    public let chargeRateUnits: String?
    public let time24Hours: Bool?
    public let rangeDisplay: String?
    public let timeStamp: TimeStamp
    
    private enum CodingKeys: String, CodingKey {
      case distanceUnits = "gui_distance_units"
      case temperatureUnits = "gui_temperature_units"
      case chargeRateUnits = "gui_charge_rate_units"
      case time24Hours = "gui_24_hour_time"
      case rangeDisplay = "gui_range_display"
      case timeStamp = "timestamp"
    }
  }
}
