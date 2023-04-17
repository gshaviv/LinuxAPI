
import Foundation

public struct ChargeState: Codable {
  public enum ChargingState: String, Codable {
    case complete = "Complete"
    case charging = "Charging"
    case disconnected = "Disconnected"
    case stopped = "Stopped"
    case starting = "Starting"
  }
    
  public enum ScheduledChargingTimes: String, Codable {
    case allWeek = "all_week"
    case weekdays
  }
	
  public let batteryHeaterOn: Bool
  /**
   Percentage of the battery
   */
  public let batteryLevel: Int
  /**
   Rated Miles
   */
  public let ratedBatteryRange: Distance
  public let chargeCurrentRequest: Int?
  public let chargeCurrentRequestMax: Int?
  public let chargeEnableRequest: Bool?
  public let chargeEnergyAdded: Double?
	
  public let chargeLimitSOC: Int?
  public let chargeLimitSOCMax: Int?
  public let chargeLimitSOCMin: Int?
  public let chargeLimitSOCStandard: Int?

  public let chargeDistanceAddedIdeal: Distance?
  public let chargeDistanceAddedRated: Distance?
	
  /**
   Vehicle charging port is open?
   */
  public let chargePortDoorOpen: Bool
  public let chargePortLatch: String?
  public let chargePortColdWeatherMode: Bool?
	
  /**
   miles/hour while charging or 0 if not charging
   */
  public let chargeRate: Speed?
  /**
   Charge to max rate or standard
   */
  public let chargeToMaxRange: Bool?
	
  /**
   Current actually being drawn
   */
  public let chargerActualCurrent: Int?
  public let chargerPhases: Int?
  /**
   Max current allowed by charger and adapter
   */
  public let chargerPilotCurrent: Int?
  /**
   KW of charger
   */
  public let chargerPower: Int?
  /**
   Voltage. Only has value while charging
   */
  public let chargerVoltage: Int?
	
  /**
   Current state of the charging
   */
  public let chargingState: ChargingState?
	
  public let connChargeCable: String?
	
  /**
   Range estimated from recent driving
   */
  public let estimatedBatteryRange: Distance?
	
  public let euVehicle: Bool?
	
  public let fastChargerBrand: String?
  /**
   Vehicle connected to supercharger?
   */
  public let fastChargerPresent: Bool?
  public let fastChargerType: String?
	
  /**
   Ideal Miles
   */
  public let idealBatteryRange: Distance?
  public let managedChargingActive: Bool?
  public let managedChargingStartTime: Date?
  public let managedChargingUserCanceled: Bool?
	
  public let maxRangeChargeCounter: Int?
	
  public let notEnoughPowerToHeat: Bool?
	
  public let scheduledChargingPending: Bool?
  public let scheduledChargingStartTime: Date?
  public let scheduledDepartureTime: Date?
  public let offPeakChargingEnabled: Bool?
  public let offPeakChargingTimes: ScheduledChargingTimes?
  public let offPeakHoursEndTime: Int?
  public let preconditioningEnabled: Bool?
  public let preconditioningTimes: ScheduledChargingTimes?
	
  /**
   Only valid while charging
   */
  public let timeToFullCharge: Double?
  public let timeStamp: TimeStamp
	
  public let tripCharging: Bool?
	
  public let usableBatteryLevel: Int?
  public let userChargeEnableRequest: Bool?
	
  private enum CodingKeys: String, CodingKey {
    case batteryHeaterOn = "battery_heater_on"
    case batteryLevel = "battery_level"
    case ratedBatteryRange = "battery_range"
    case chargeCurrentRequest = "charge_current_request"
    case chargeCurrentRequestMax = "charge_current_request_max"
    case chargeEnableRequest = "charge_enable_request"
    case chargeEnergyAdded = "charge_energy_added"
    case chargeLimitSOC = "charge_limit_soc"
    case chargeLimitSOCMax = "charge_limit_soc_max"
    case chargeLimitSOCMin = "charge_limit_soc_min"
    case chargeLimitSOCStandard = "charge_limit_soc_std"
    case chargeDistanceAddedIdeal = "charge_miles_added_ideal"
    case chargeDistanceAddedRated = "charge_miles_added_rated"
    case chargePortDoorOpen = "charge_port_door_open"
    case chargePortLatch = "charge_port_latch"
    case chargePortColdWeatherMode = "charge_port_cold_weather_mode"
    case chargeRate = "charge_rate"
    case chargeToMaxRange = "charge_to_max_range"
    case chargerActualCurrent = "charger_actual_current"
    case chargerPhases = "charger_phases"
    case chargerPilotCurrent = "charger_pilot_current"
    case chargerPower = "charger_power"
    case chargerVoltage = "charger_voltage"
    case chargingState = "charging_state"
    case connChargeCable = "conn_charge_cable"
    case estimatedBatteryRange = "est_battery_range"
    case euVehicle = "eu_vehicle"
    case fastChargerBrand = "fast_charger_brand"
    case fastChargerPresent = "fast_charger_present"
    case fastChargerType = "fast_charger_type"
    case idealBatteryRange = "ideal_battery_range"
    case managedChargingActive = "managed_charging_active"
    case managedChargingStartTime = "managed_charging_start_time"
    case managedChargingUserCanceled = "managed_charging_user_canceled"
    case maxRangeChargeCounter = "max_range_charge_counter"
    case notEnoughPowerToHeat = "not_enough_power_to_heat"
    case scheduledChargingPending = "scheduled_charging_pending"
    case scheduledChargingStartTime = "scheduled_charging_start_time"
    case scheduledDepartureTime = "scheduled_departure_time"
    case offPeakChargingEnabled = "off_peak_charging_enabled"
    case offPeakChargingTimes = "off_peak_charging_times"
    case offPeakHoursEndTime = "off_peak_hours_end_time"
    case preconditioningEnabled = "preconditioning_enabled"
    case preconditioningTimes = "preconditioning_times"
    case timeToFullCharge = "time_to_full_charge"
    case timeStamp = "timestamp"
    case tripCharging = "trip_charging"
    case usableBatteryLevel = "usable_battery_level"
    case userChargeEnableRequest = "user_charge_enable_request"
  }
}
