
import Foundation

public struct VehicleConfig: Codable {
  public let canAcceptNavigationRequests: Bool?
  public let canActuateTrunks: Bool?
  public let carSpecialType: String?
  public let carType: String?
  public let chargePortType: String?
  public let euVehicle: Bool?
  public let exteriorColor: String?
  public let hasAirSuspension: Bool?
  public let hasLudicrousMode: Bool?
  public let motorizedChargePort: Bool?
  public let perfConfig: String?
  public let plg: Bool?
  public let rearSeatHeaters: Int?
  public let rearSeatType: Int?
  public let rhd: Bool?
  public let roofColor: String? // "None" for panoramic roof
  public let seatType: Int?
  public let spoilerType: String?
  public let sunRoofInstalled: Int?
  public let thirdRowSeats: String?
  public let timeStamp: TimeStamp
  public let trimBadging: String?
  public let wheelType: String?

  enum CodingKeys: String, CodingKey {
    case canAcceptNavigationRequests = "can_accept_navigation_requests"
    case canActuateTrunks = "can_actuate_trunks"
    case carSpecialType = "car_special_type"
    case carType = "car_type"
    case chargePortType = "charge_port_type"
    case euVehicle = "eu_vehicle"
    case exteriorColor = "exterior_color"
    case hasAirSuspension = "has_air_suspension"
    case hasLudicrousMode = "has_ludicrous_mode"
    case motorizedChargePort = "motorized_charge_port"
    case perfConfig = "perf_config"
    case plg = "plg"
    case rearSeatHeaters = "rear_seat_heaters"
    case rearSeatType = "rear_seat_type"
    case rhd = "rhd"
    case roofColor = "roof_color"
    case seatType = "seat_type"
    case spoilerType = "spoiler_type"
    case sunRoofInstalled = "sun_roof_installed"
    case thirdRowSeats = "third_row_seats"
    case timeStamp = "timestamp"
    case trimBadging = "trim_badging"
    case wheelType = "wheel_type"
  }
}
