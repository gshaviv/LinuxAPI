import Foundation

public typealias OnRefreshBlock = (AuthToken) -> Void

public struct TeslaBackendAPI {
  public init(logger: ((String, String, Data?, String?, HTTPStatusCode?) -> Void)? = nil) {
    TeslaAPI.logger = logger
  }
  
  public func releaseNotes(staged: Bool, id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> ReleaseNotes {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "release_notes?staged=\(staged)", token: token, onTokenRefresh: onRefresh)
  }
  
  public func command(_ cmd: TeslaCommand, id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> CommandResponse {
    switch cmd {
    case .wake:
      let r: Vehicle = try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, token: token, onTokenRefresh: onRefresh)
      return CommandResponse(result: r.state == .online, reason: r.state == .online ? "" : "failed to wakup")
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
  case sentry(on: Bool)
  case vent(close: Bool, lat: Double, long: Double)
  case seatHeater(seat: Int, level: Int)
  case climateKeeperMode(Int)
  case cabinOverheatPtoection(ClimateState.CabinOverheatProtection)
  case chargeCurrent(Int)
  case scheduleCharge(enable: Bool, minutesSinceMidnight: Int)
  case scheduledDepart(enable: Bool, when: Int, precondition: Bool, preconditionWeekdaysOnly: Bool, offpeak: Bool, offpearWeekdaysOnly: Bool, offpeakEndTime: Int)
  case scheduleUpdate(Int)
  case cancelScheduledUpdate
}

private extension TeslaCommand {
  var path: String {
    switch self {
    case .cancelScheduledUpdate:
      return "command/cancel_software_update"
    case .scheduleUpdate:
      return "command/schedule_software_update"
    case .scheduledDepart:
      return "command/set_scheduled_departure"
    case .scheduleCharge:
      return "command/set_scheduled_charging"
    case .chargeCurrent:
      return "command/set_charging_amps"
    case .cabinOverheatPtoection:
      return "command/set_cabin_overheat_protection"
    case .climateKeeperMode:
      return "command/set_climate_keeper_mode"
    case .seatHeater:
      return "command/remote_seat_heater_request"
    case .vent:
      return "command/window_control"
    case .sentry:
      return "command/set_sentry_mode"
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
      return "command/charge_start"
    case .stopCharging:
      return "command/charge_stop"
    case .valet:
      return "command/set_valet_mode"
    }
  }
  
  var postParams: [String: Any] {
    switch self {
    case .scheduleUpdate(let sec):
      return ["offset_sec": sec]
    case let .scheduledDepart(enable: enable, when: when, precondition: precondition, preconditionWeekdaysOnly: prew, offpeak: offpeak, offpearWeekdaysOnly: offpeakW, offpeakEndTime: offpeakTime):
      return [
        "enable": enable,
        "departure_time": when,
        "preconditioning_enabled": precondition,
        "preconditioning_weekdays_only": prew,
        "off_peak_charging_enabled": offpeak,
        "off_peak_charging_weekdays_only": offpeakW,
        "end_off_peak_time": offpeakTime
      ]
    case .scheduleCharge(enable: let enable, minutesSinceMidnight: let minutes):
      return ["enable": enable, "time": minutes]
    case .chargeCurrent(let current):
      return ["charging_amps": current]
    case .cabinOverheatPtoection(let value):
      return ["on": value != .off, "fan_only": value == .fanOnly]
    case .climateKeeperMode(let value):
      return ["climate_keeper_mode": value]
    case .seatHeater(seat: let seat, level: let level):
      return ["heater": seat, "level": level]
    case .vent(close: let close, lat: let lat, long: let long):
      return ["command": close ? "close" : "vent",
              "lon": long,
              "lat": lat]
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
    case .sentry(on: let on):
      return ["on": on]
    default:
      return [:]
    }
  }
}

public struct CommandResponse: Codable {
  public let result: Bool
  public let reason: String
}
