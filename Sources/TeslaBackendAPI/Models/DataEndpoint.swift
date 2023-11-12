//
//  File.swift
//
//
//  Created by Guy Shaviv on 12/11/2023.
//

import Foundation

public enum DataEndpoint: String {
  case location = "location_data"
  case chargeState = "charge_state"
  case climateState = "climate_state"
  case vehicleState = "vehicle_state"
  case guiSettings = "gui_settings"
  case vehicleConfig = "vehicle_config"
  case driveState = "drive_state"
  case closuresState = "closures_state"
//  case combo = "vehicle_data_combo"
  
  public static var all: [DataEndpoint] = [.chargeState, .climateState, .vehicleState, .guiSettings, .vehicleConfig, .driveState, .closuresState, .location]
  public static var allWithoutLocation: [DataEndpoint] = [.chargeState, .climateState, .vehicleState, .guiSettings, .vehicleConfig, .driveState, .closuresState]
}
