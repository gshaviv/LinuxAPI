
import Foundation

extension Tesla {
  public class Vehicle: Codable {
    public enum State: Codable, Equatable, CustomStringConvertible {
      case online
      case sleeping
      case other(String)
      
      public var description: String {
        switch self {
        case .online: return "online"
        case .sleeping: return "asleep"
        case .other(let v): return v
        }
      }
      
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        switch string {
        case "online": self = .online
        case "asleep": self = .sleeping
        default: self = .other(string)
        }
      }
      
      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
      }
      
      public var isSleeping: Bool {
        switch self {
        case .sleeping: return true
        default: return false
        }
      }
      
      public var isOnline: Bool {
        switch self {
        case .online: return true
        default: return false
        }
      }
      
      public static func == (lhs: State, rhs: String) -> Bool {
        switch lhs {
        case .online where rhs == "online",
            .sleeping where rhs == "asleep" || rhs == "sleeping":
          return true
        case .other(let value) where rhs == value:
          return true
        default: return false
        }
      }
      
      public static func == (lhs: State, rhs: State) -> Bool {
        switch (lhs, rhs) {
        case (.online, .online),
          (.sleeping, .sleeping):
          return true
        case (.other(let l), .other(let r)) where l == r:
          return true
        default:
          return false
        }
      }
    }
    
    public let backseatToken: String?
    public let backseatTokenUpdatedAt: Date?
    public let calendarEnabled: Bool
    public let color: String?
    public let displayName: String?
    public let id: Int64
    public let idS: String?
    public let inService: Bool?
    public let optionCodes: String?
    public let state: State
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
}
