public typealias OnRefreshBlock = (AuthToken) -> Void

public struct TeslaBackendAPI {
  public init(logger: ((String, String?, HTTPStatusCode?) -> Void)? = nil) {
    TeslaAPI.logger = logger
  }
  
  public func command(_ cmd: TeslaCommand, id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> CommandResult {
    
    switch cmd {
    case .wake:
      let r: Vehicle = try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, token: token, onTokenRefresh: onRefresh)
      return CommandResult(response: CommandResult.CommandResponse(result: r.state == .online, reason: r.state == .online ? "" : "failed to wakup"))
    default:
      return try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, token: token, onTokenRefresh: onRefresh)
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
}

private extension TeslaCommand {
  var path: String {
    switch self {
    case .wake:
      return "wake_up"
    case .start(password: let password):
      if let password {
        return "ommand/remote_start_drive?password=\(password)"
      } else {
        return "ommand/remote_start_drive"
      }
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
    case .setTemprature(driver: let d, passenger: let p):
      return "command/set_temps?driver_temp=\(d)&passenger_temp=\(p)"
    case .chargeLimit(percent: let p):
      return "command/set_charge_limit?percent=\(p)"
    case .openChargePort:
      return "command/charge_port_door_open"
    case .closeChargePort:
      return "command/charge_port_door_close"
    case .startCharging:
      return  "command/charge_start"
    case .stopCharging:
      return "command/charge_stop"
    case .valet(on: let on, password: let pass) where pass == nil:
      return "command/set_valet_mode?on=\(on)"
    case .valet(on: let on, password: let pass):
      return "command/set_valet_mode?on=\(on)&password=\(pass ?? "")"
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
