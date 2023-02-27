public typealias OnRefreshBlock = (AuthToken) -> Void

public struct TeslaBackendAPI {
  public init() {}

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
  
  public func getAllVehicleStates(id: Int64, token: AuthToken, onRefresh: @escaping OnRefreshBlock) async throws -> VehicleWithStates {
    try await TeslaAPI.call(endpoint: "api/1/vehicles", id, "vehicle_data", token: token, onTokenRefresh: onRefresh)
  }
}
