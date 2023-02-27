
import Foundation

public class Vehicle: Codable {
  public let backseatToken: String?
  public let backseatTokenUpdatedAt: Date?
  public let calendarEnabled: Bool
  public let color: String?
  public let displayName: String
  public let id: Int64
  public let idS: String?
  public let inService: Bool
  public let optionCodes: String?
  public let state: String
  public let tokens: [String]?
  public let vehicleID: Int64
  public let vin: String

  private enum CodingKeys: String, CodingKey {
    case backseatToken = "backseat_token"
    case backseatTokenUpdatedAt = "backseat_token_updated_at"
    case calendarEnabled = "calendar_enabled"
    case color = "color"
    case displayName = "display_name"
    case id = "id"
    case idS = "id_s"
    case inService = "in_service"
    case optionCodes = "option_codes"
    case state = "state"
    case tokens = "tokens"
    case vehicleID = "vehicle_id"
    case vin = "vin"
  }
}
