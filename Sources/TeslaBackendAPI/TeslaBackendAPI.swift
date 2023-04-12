import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias OnRefreshBlock = (AuthToken) -> Void

public struct TeslaBackendAPI {
  public init(logger: ((URLRequest, String?, HTTPStatusCode?) -> Void)? = nil) {
    TeslaAPI.logger = logger
  }
  
  public func command(_ cmd: TeslaCommand, id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> CommandResult {
    
    switch cmd {
    case .wake:
      let r: Vehicle = try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, token: token, onTokenRefresh: onRefresh)
      return CommandResult(response: CommandResult.CommandResponse(result: r.state == .online, reason: r.state == .online ? "" : "failed to wakup"))
    default:
      return try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, body: cmd.postParams, token: token, onTokenRefresh: onRefresh)
    }
  }

  public func vehicles(token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> [Vehicle] {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicle(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> Vehicle {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleChargeState(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> ChargeState {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/charge_state", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleDriveState(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> DriveState {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/drive_state", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleClimateState(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> ClimateState {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/climate_state", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleGuiSettings(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> GuiSettings {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/gui_settings", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleState(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> VehicleState {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/vehicle_state", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getVehicleConfig(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> VehicleConfig {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "data_request/vehicle_config", token: token, onTokenRefresh: onRefresh)
  }
  
  public func getAllVehicleStates(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> VehicleStates {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "vehicle_data", token: token, onTokenRefresh: onRefresh)
  }
}

public enum TeslaCommand: Codable {
  case wake
  case start(password: String?)
  case unlock
  case lock
  case honk
  case flash
  case startAC
  case stopAC
  case setTemprature(driver: Double, passenger: Double)
  case chargeLimit(percent: Int)
  case openChargePort
  case closeChargePort
  case startCharging
  case stopCharging
  case valet(on: Bool, password: String?)
  case actuateTrunk(whichTrunk: String)
}

private extension TeslaCommand {
  var path: String {
    switch self {
    case .actuateTrunk:
      return "command/actuate_trunk"
    case .wake:
      return "wake_up"
    case .start:
        return "ommand/remote_start_drive"
    case .unlock:
      return "command/door_unlock"
    case .lock:
      return "command/door_lock"
    case .honk:
      return "command/honk_horn"
    case .flash:
      return "command/flash_lights"
    case .startAC:
      return "command/auto_conditioning_start"
    case .stopAC:
      return "command/auto_conditioning_stop"
    case .setTemprature:
      return "command/set_temps"
    case .chargeLimit:
      return "command/set_charge_limit"
    case .openChargePort:
      return "command/charge_port_door_open"
    case .closeChargePort:
      return "command/charge_port_door_close"
    case .startCharging:
      return  "command/charge_start"
    case .stopCharging:
      return "command/charge_stop"
    case .valet:
      return "command/set_valet_mode"
    }
  }
  
  var postParams: [String: Any] {
    switch self {
    case .valet(on: let on, password: let pwd) where pwd == nil:
      return ["on": on]
    case .valet(on: let on, password: let pwd):
      return ["on": on, "password": pwd ?? ""]
    case .setTemprature(driver: let d, passenger: let p):
      return ["driver_temp": d, "passenger_temp": p]
    case .chargeLimit(percent: let p):
      return ["percent": p]
    case .start(password: let password) where password != nil:
      return ["password": password ?? ""]
    case .actuateTrunk(whichTrunk: let which):
      return ["which_trunk": which]
    default:
      return [:]
    }
  }
}

public struct CommandResult: Codable {
  public struct CommandResponse: Codable {
    public let result: Bool
    public let reason: String
  }
  public let response: CommandResponse
}
