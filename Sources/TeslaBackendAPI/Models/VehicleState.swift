//
//  VehicleState.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 20/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import Foundation

public struct VehicleState: Codable {
  public struct MediaState: Codable {
    public let remoteControlEnabled: Bool?
    private enum CodingKeys: String, CodingKey {
      case remoteControlEnabled = "remote_control_enabled"
    }
  }
	
  public struct SpeedLimitMode: Codable {
    public let active: Bool?
    public let currentLimit: Speed?
    public let maxLimit: Speed?
    public let minLimit: Speed?
    public let pinCodeSet: Bool?
		
    private enum CodingKeys: String, CodingKey {
      case active = "active"
      case currentLimit = "current_limit_mph"
      case maxLimit = "max_limit_mph"
      case minLimit = "min_limit_mph"
      case pinCodeSet = "pin_code_set"
    }
  }
	
  public let apiVersion: Int?
	
  public let autoparkState: String?
  public let autoparkStateV2: String?
  public let autoparkStyle: String?
	
  public let calendarSupported: Bool?
	
  public let firmwareVersion: String?
	
  private var centerDisplayStateBool: Int?
  public var centerDisplayState: Bool { centerDisplayStateBool == 1 }
	
  private var driverDoorOpenBool: Int?
  public var driverDoorOpen: Bool { (driverDoorOpenBool ?? 0) > 0 }
  private var driverWindowOpenBool: Int?
  public var driverWindowOpen: Bool { (driverWindowOpenBool ?? 0) > 0 }

  private var driverRearDoorOpenBool: Int?
  public var driverRearDoorOpen: Bool { (driverRearDoorOpenBool ?? 0) > 0 }
  private var driverRearWindowOpenBool: Int?
  public var driverRearWindowOpen: Bool { (driverRearWindowOpenBool ?? 0) > 0 }
	
  private var frontTrunkOpenBool: Int?
  public var frontTrunkOpen: Bool { (frontTrunkOpenBool ?? 0) > 0 }
	
  public let homelinkNearby: Bool?
  public let homelinkDeviceCount: Int?
  public let isUserPresent: Bool?
	
  public let lastAutoparkError: String?
	
  public let locked: Bool?
	
  public let mediaState: MediaState?
	
  public let notificationsSupported: Bool?
	
  public let odometer: Double?
	
  public let parsedCalendarSupported: Bool?
	
  private var passengerDoorOpenBool: Int?
  public var passengerDoorOpen: Bool { (passengerDoorOpenBool ?? 0) > 0 }
  private var passengerWindowOpenBool: Int?
  public var passengerWindowOpen: Bool { (passengerWindowOpenBool ?? 0) > 0 }

  private var passengerRearDoorOpenBool: Int?
  public var passengerRearDoorOpen: Bool { (passengerRearDoorOpenBool ?? 0) > 0 }
  private var passengerRearWindowOpenBool: Int?
  public var passengerRearWindowOpen: Bool { (passengerRearWindowOpenBool ?? 0) > 0 }
	
  public let remoteStart: Bool?
  public let remoteStartSupported: Bool?
	
  private var rearTrunkOpenInt: Int?
  public var rearTrunkOpen: Bool {
    if let rearTrunkOpenInt = rearTrunkOpenInt {
      return rearTrunkOpenInt > 0
    } else {
      return false
    }
  }
	
  public let sentryMode: Bool?
    
  public let softwareUpdate: SoftwareUpdate?
  public let speedLimitMode: SpeedLimitMode?
	
  public let sunRoofPercentageOpen: Int? // null if not installed
  public let sunRoofState: String?
	
  public let timeStamp: Double?
	
  public let valetMode: Bool?
  public let valetPinNeeded: Bool?
	
  public let vehicleName: String?
  
  public let frontLeftTirePresssure: Pressure?
  public let frontRightTirePressure: Pressure?
  public let rearLeftTirePressure: Pressure?
  public let rearRightTirePressure: Pressure?
  public let lastSeenTirePressureTime: Date?
	
  private enum CodingKeys: String, CodingKey {
    case apiVersion = "api_version"
    case autoparkState = "autopark_state"
    case autoparkStateV2 = "autopark_state_v2"
    case autoparkStyle = "autopark_style"
    case calendarSupported = "calendar_supported"
    case firmwareVersion = "car_version"
    case centerDisplayStateBool = "center_display_state"
    case driverDoorOpenBool = "df"
    case driverWindowOpenBool = "fd_window"
    case driverRearDoorOpenBool = "dr"
    case driverRearWindowOpenBool = "rd_window"
    case frontTrunkOpenBool = "ft"
    case homelinkNearby = "homelink_nearby"
    case homelinkDeviceCount = "homelink_device_count"
    case isUserPresent = "is_user_present"
    case lastAutoparkError = "last_autopark_error"
    case locked = "locked"
    case mediaState = "media_state"
    case notificationsSupported = "notifications_supported"
    case odometer = "odometer"
    case parsedCalendarSupported = "parsed_calendar_supported"
    case passengerDoorOpenBool = "pf"
    case passengerWindowOpenBool = "fp_window"
    case passengerRearDoorOpenBool = "pr"
    case passengerRearWindowOpenBool = "rp_window"
    case remoteStart = "remote_start"
    case remoteStartSupported = "remote_start_supported"
    case rearTrunkOpenInt = "rt"
    case sentryMode = "sentry_mode"
    case softwareUpdate = "software_update"
    case speedLimitMode = "speed_limit_mode"
    case sunRoofPercentageOpen = "sun_roof_percent_open"
    case sunRoofState = "sun_roof_state"
    case timeStamp = "timestamp"
    case valetMode = "valet_mode"
    case valetPinNeeded = "valet_pin_needed"
    case vehicleName = "vehicle_name"
    case frontLeftTirePresssure = "tpms_pressure_fl"
    case frontRightTirePressure = "tpms_pressure_fr"
    case rearLeftTirePressure = "tpms_pressure_rl"
    case rearRightTirePressure = "tpms_pressure_rr"
    case lastSeenTirePressureTime = "tpms_last_seen_pressure_time_fl"
  }
}

public struct SoftwareUpdate: Codable {
  public let status: String?
  public let expectedDuration: Int?
  public let scheduledTime: Double?
  public let warningTimeRemaining: Double?
  public let downloadPercentage: Int?
  public let installPercentage: Int?
  public let version: String?
  
  private enum CodingKeys: String, CodingKey {
    case status
    case expectedDuration = "expected_duration_sec"
    case scheduledTime = "scheduled_time_ms"
    case warningTimeRemaining = "warning_time_remaining_ms"
    case downloadPercentage = "download_perc"
    case installPercentage = "install_perc"
    case version
  }
}
