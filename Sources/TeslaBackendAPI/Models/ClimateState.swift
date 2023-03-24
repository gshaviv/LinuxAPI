
import Foundation

public struct ClimateState: Codable {
  /*
   * Fan speed 0-6 or nil
   */
  public let fanStatus: Int?

  public let isAutoConditioningOn: Bool?
  public let isClimateOn: Bool?
  public let climateKeeperMode: String?

  public let batteryHeater: Bool?
  public let batteryHeaterNoPower: Bool?

  public let isFrontDefrosterOn: Bool?
  public let isRearDefrosterOn: Bool?
  private let defrostMode: Int? // 2 = on, 0 = off
  public var isDefrostModeIn: Bool { defrostMode != 0 }

  /*
   * Temp directions 0 at least 583...
   */
  public let leftTemperatureDirection: Int?
  public let rightTemperatureDirection: Int?

  public let driverTemperatureSetting: Temperature?
  public let passengerTemperatureSetting: Temperature?

  public let maxAvailableTemperature: Temperature?
  public let minAvailableTemperature: Temperature?

  public let remoteHeaterControlEnabled: Bool?

  public let seatHeaterLeft: Int?
  public let seatHeaterRearCenter: Int?
  public let seatHeaterRearLeft: Int?
  public let seatHeaterRearLeftBack: Int?
  public let seatHeaterRearRight: Int?
  public let seatHeaterRearRightBack: Int?
  public let seatHeaterRight: Int?

  public let sideMirrorHeaters: Bool?
  public let steeringWheelHeater: Bool?
  public let wiperBladeHeater: Bool?

  public let insideTemperature: Temperature?
  public let outsideTemperature: Temperature?

  public let isPreconditioning: Bool?
  public let smartPreconditioning: Bool?

  public let timeStamp: TimeStamp
  public enum CabinOverheatProtection: String, Codable {
    case on = "On"
    case off = "Off"
    case fanOnly = "FanOnly"
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = CabinOverheatProtection(rawValue: rawValue) ?? .off
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(self.rawValue)
    }
  }
  public let cabinOverheatProtection: CabinOverheatProtection
  public let copActivelyCooling: Bool

  private enum CodingKeys: String, CodingKey {
    case batteryHeater = "battery_heater"
    case batteryHeaterNoPower = "battery_heater_no_power"
    case driverTemperatureSetting = "driver_temp_setting"
    case passengerTemperatureSetting = "passenger_temp_setting"
    case fanStatus = "fan_status"
    case insideTemperature = "inside_temp"
    case isAutoConditioningOn = "is_auto_conditioning_on"
    case isClimateOn = "is_climate_on"
    case climateKeeperMode = "climate_keeper_mode"
    case isFrontDefrosterOn = "is_front_defroster_on"
    case isRearDefrosterOn = "is_rear_defroster_on"
    case defrostMode = "defrost_mode"
    case isPreconditioning = "is_preconditioning"
    case leftTemperatureDirection = "left_temp_direction"
    case maxAvailableTemperature = "max_avail_temp"
    case minAvailableTemperature = "min_avail_temp"
    case outsideTemperature = "outside_temp"
    case remoteHeaterControlEnabled = "remote_heater_control_enabled"
    case rightTemperatureDirection = "right_temp_direction"
    case seatHeaterLeft = "seat_heater_left"
    case seatHeaterRearCenter = "seat_heater_rear_center"
    case seatHeaterRearLeft = "seat_heater_rear_left"
    case seatHeaterRearLeftBack = "seat_heater_rear_left_back"
    case seatHeaterRearRight = "seat_heater_rear_right"
    case seatHeaterRearRightBack = "seat_heater_rear_right_back"
    case seatHeaterRight = "seat_heater_right"
    case sideMirrorHeaters = "side_mirror_heaters"
    case steeringWheelHeater = "steering_wheel_heater"
    case wiperBladeHeater = "wiper_blade_heater"
    case smartPreconditioning = "smart_preconditioning"
    case timeStamp = "timestamp"
    case cabinOverheatProtection = "cabin_overheat_protection"
    case copActivelyCooling = "cabin_overheat_protection_actively_cooling"
  }
}
