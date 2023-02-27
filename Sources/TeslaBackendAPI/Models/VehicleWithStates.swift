
import Foundation

final public class VehicleWithStates: Vehicle {
  public var userId: Int64?
  public var chargeState: ChargeState?
  public var climateState: ClimateState?
  public var driveState: DriveState?
  public var guiSettings: GuiSettings?
  public var vehicleConfig: VehicleConfig?
  public var vehicleState: VehicleState?
  
  private enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case chargeState = "charge_state"
    case climateState = "climate_state"
    case driveState = "drive_state"
    case guiSettings = "gui_settings"
    case vehicleConfig = "vehicle_config"
    case vehicleState = "vehicle_state"
  }
}
