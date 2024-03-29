
import Foundation

extension Tesla {
  final public class VehicleStates: Vehicle {
    public let userId: Int64
    public let chargeState: ChargeState?
    public let climateState: ClimateState?
    public let driveState: DriveState?
    public let guiSettings: GuiSettings?
    public let vehicleConfig: VehicleConfig?
    public let vehicleState: VehicleState?
    
    private enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case chargeState = "charge_state"
      case climateState = "climate_state"
      case driveState = "drive_state"
      case guiSettings = "gui_settings"
      case vehicleConfig = "vehicle_config"
      case vehicleState = "vehicle_state"
    }
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      userId = try container.decode(Int64.self, forKey: .userId)
      chargeState = try container.decodeIfPresent(ChargeState.self, forKey: .chargeState)
      climateState = try container.decodeIfPresent(ClimateState.self, forKey: .climateState)
      driveState = try container.decodeIfPresent(DriveState.self, forKey: .driveState)
      guiSettings = try container.decodeIfPresent(GuiSettings.self, forKey: .guiSettings)
      vehicleState = try container.decodeIfPresent(VehicleState.self, forKey: .vehicleState)
      vehicleConfig = try container.decodeIfPresent(VehicleConfig.self, forKey: .vehicleConfig)
      try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(userId, forKey: .userId)
      try container.encodeIfPresent(chargeState, forKey: .chargeState)
      try container.encodeIfPresent(climateState, forKey: .climateState)
      try container.encodeIfPresent(driveState, forKey: .driveState)
      try container.encodeIfPresent(guiSettings, forKey: .guiSettings)
      try container.encodeIfPresent(vehicleConfig, forKey: .vehicleConfig)
      try container.encodeIfPresent(vehicleState, forKey: .vehicleState)
      try super.encode(to: container.superEncoder())
    }
  }
}
