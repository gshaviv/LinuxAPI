
import Foundation

extension Tesla {
  public struct DriveState: Codable {
    public enum ShiftState: String, Codable {
      case drive = "D"
      case park = "P"
      case reverse = "R"
      case neutral = "N"
    }
    
    public let shiftState: ShiftState?
    public let speed: Speed?
    public let latitude: Double?
    public let longitude: Double?
    public let heading: Double?
    public let nativeLatitude: Double?
    public let nativeLongitude: Double?
    private var nativeLocationSupportedInt: Int?
    public var nativeLocationSupported: Bool { return nativeLocationSupportedInt == 1 }
    public let nativeType: String?
    public let gpsDate: Date?
    public let timeStamp: TimeStamp
    public let power: Int?
    public let activeRouteDestination: String?
    public let activeRouteEnergyAtArrival: Int?
    public let activeRouteMilesToArrival: Double?
    public let activeRouteMinutesToArrival: Double?
    
    private enum CodingKeys: String, CodingKey {
      case shiftState = "shift_state"
      case speed
      case latitude
      case longitude
      case power
      case heading
      case gpsDate = "gps_as_of"
      case timeStamp = "timestamp"
      case nativeLatitude = "native_latitude"
      case nativeLongitude = "native_longitude"
      case nativeLocationSupportedInt = "native_location_supported"
      case nativeType = "native_type"
      case activeRouteDestination = "active_route_destination"
      case activeRouteEnergyAtArrival = "active_route_energy_at_arrival"
      case activeRouteMilesToArrival = "active_route_miles_to_arrival"
      case activeRouteMinutesToArrival = "active_route_minutes_to_arrival"
    }
  }
}
