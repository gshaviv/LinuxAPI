import Foundation

public typealias OnRefreshBlock = (Tesla.AuthToken?, Error?) async -> Void

public enum Tesla {
  public struct BackendAPI {
    public init(logger: ((String, String, Data?, String?, HTTPStatusCode?) -> Void)? = nil) {
      TeslaAPI.logger = logger
    }
    
    public func releaseNotes(staged: Bool, id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> ReleaseNotes {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "release_notes?staged=\(staged)", token: token, onTokenRefresh: onRefresh)
    }
    
    public func command(_ cmd: TeslaCommand, id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> CommandResponse {
      switch cmd {
      case .wake:
        let r: Vehicle = try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, token: token, onTokenRefresh: onRefresh)
        return CommandResponse(result: r.state == .online, reason: r.state == .online ? "" : "failed to wakup")
      default:
        return try await TeslaAPI.call(endpoint: "api/1/vehicles", id, cmd.path, method: .post, body: cmd.postParams, token: token, onTokenRefresh: onRefresh)
      }
    }
    
    public struct Me: Decodable {
      public let email: String?
      public let fullName: String?
      public let profileImageUrl: String?
      
      private enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case profileImageUrl = "profile_image_url"
      }
    }
    
    public func me(token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> Me {
      try await TeslaAPI.call(endpoint: "api/1/users/me", token: token, onTokenRefresh: onRefresh)
    }
    
    public func share(location: String, id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> CommandResponse {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "command/share",
                              body: ["type": "share_ext_content_raw",
                                     "locale": "en-US",
                                     "timestamp_ms": Int(Date().timeIntervalSince1970 * 1000),
                                     "value": [
                                      "android.intent.extra.TEXT": location
                                     ]],
                              token: token,
                              onTokenRefresh: onRefresh)
    }
    
    public func vehicles(token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> [Vehicle] {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", token: token, onTokenRefresh: onRefresh)
    }
    
    public func getVehicle(id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> Vehicle {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", id, token: token, onTokenRefresh: onRefresh)
    }
    
    public func getAllVehicleStates(id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> VehicleStates {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "vehicle_data", token: token, onTokenRefresh: onRefresh)
    }
    
    public struct Chargers: Decodable {
      public let superchargers: [ChargingLocation]
      public let destination: [ChargingLocation]
      private enum CodingKeys: String, CodingKey {
        case superchargers
        case destination = "destination_charging"
      }
    }
    
    public func chargingLocations(id: Int64, token: () async -> AuthToken?, onRefresh: @escaping OnRefreshBlock) async throws -> Chargers {
      try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "nearby_charging_sites", token: token, onTokenRefresh: onRefresh)
    }
  }
}

extension Tesla.BackendAPI {
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
    case cabinOverheatPtoection(Tesla.ClimateState.CabinOverheatProtection)
    case chargeCurrent(Int)
    case scheduleCharge(enable: Bool, minutesSinceMidnight: Int)
    case scheduledDepart(enable: Bool, when: Int, precondition: Bool, preconditionWeekdaysOnly: Bool, offpeak: Bool, offpearWeekdaysOnly: Bool, offpeakEndTime: Int)
    case scheduleUpdate(Int)
    case cancelScheduledUpdate
    
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
      case .scheduledDepart(enable: let enable, when: let when, precondition: let precondition, preconditionWeekdaysOnly: let prew, offpeak: let offpeak, offpearWeekdaysOnly: let offpeakW, offpeakEndTime: let offpeakTime):
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
}
