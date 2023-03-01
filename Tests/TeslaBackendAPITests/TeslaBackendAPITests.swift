import XCTest
@testable import TeslaBackendAPI
import Foundation

final class TeslaBackendAPITests: XCTestCase {
  lazy var onRefresh: OnRefreshBlock = {
    self.token = $0
  }
  var token: AuthToken! {
    set {
      guard let data = try? TeslaAPI.teslaJSONEncoder.encode(newValue) else {
        return
      }
      UserDefaults.standard.set(data, forKey: "token")
    }
    get {
      guard let data = UserDefaults.standard.data(forKey: "token") else {
        return nil
      }
      return try? TeslaAPI.teslaJSONDecoder.decode(AuthToken.self, from: data)
    }
  }
  let api = TeslaBackendAPI()
  var vehicleID: Int64!
  
  override class func setUp() {
    loggingEnabled = true
    if UserDefaults.standard.data(forKey: "token") == nil  {
      let str =
"""
{"expires_in":28800,"refresh_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im5ZdVZJWTJTN3gxVHRYM01KMC1QMDJad3pXQSJ9.eyJpc3MiOiJodHRwczovL2F1dGgudGVzbGEuY29tL29hdXRoMi92MyIsImF1ZCI6Imh0dHBzOi8vYXV0aC50ZXNsYS5jb20vb2F1dGgyL3YzL3Rva2VuIiwiaWF0IjoxNjc3NDMxMzk0LCJzY3AiOlsib3BlbmlkIiwib2ZmbGluZV9hY2Nlc3MiXSwiZGF0YSI6eyJ2IjoiMSIsImF1ZCI6Imh0dHBzOi8vb3duZXItYXBpLnRlc2xhbW90b3JzLmNvbS8iLCJzdWIiOiI2ZTI2NGFlNy02ZTBmLTRkNDctYTY0My1mNGY4MjM4MzBlNzciLCJzY3AiOlsib3BlbmlkIiwiZW1haWwiLCJvZmZsaW5lX2FjY2VzcyJdLCJhenAiOiJvd25lcmFwaSIsImFtciI6WyJwd2QiLCJtZmEiLCJvdHAiXSwiYXV0aF90aW1lIjoxNjc3NDMxMzkzfX0.o5duOWm1BwH1Em5o9Ioijio838bZ_UuLkttbkidLRai4WNbz4zU_LnNdgV0V1Oo9DIlDmh7D5RbkVHo3qj-QNKOk2gHX-hvbG6UmMvhAprjGdra8bp7pn_9pkN5XzUyHuABu1JN7yr8gNouxj8FexHCsUdJjdsld7brvReoDPP7SFpvdTdw4PM0l4BOBUR9cWIpSzUPjPjHv48g2VvM_B7rPhyfNqR_fxJaHpiFyQJvQQdkVdIk4Id3pjjPiu6GSs4wR6pxti1KzYPNtY8g6pSXUT6EQOWdZ8SuFTtpx_qThydRrEFrr1MUmUCCzxj8W2kVyNixD-sqQ1QVyZZJPbQ","id_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im5ZdVZJWTJTN3gxVHRYM01KMC1QMDJad3pXQSJ9.eyJpc3MiOiJodHRwczovL2F1dGgudGVzbGEuY29tL29hdXRoMi92MyIsImF1ZCI6Im93bmVyYXBpIiwic3ViIjoiNmUyNjRhZTctNmUwZi00ZDQ3LWE2NDMtZjRmODIzODMwZTc3IiwiZXhwIjoxNjc3NDYwMTk0LCJpYXQiOjE2Nzc0MzEzOTQsImF1dGhfdGltZSI6MTY3NzQzMTM5MywidXBkYXRlZF9hdCI6MTY1ODA1MzMyMiwiZW1haWwiOiJndXlAc2hhdml2Lm9yZyIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZX0.a7eClis8wA31ETuDZ341n3JLlvDMP1hIolilRPOR4CKxrmd4gG-2wet5iU_tq0AYWdo4QYd6VYDmMur5zj9v9wclOyJ3BneTdTJIEB7kwyiaPmeQEhaRv1Z8_s_XhKTS5qzhjp-vTFCL946vchFKD11MSJ2rNj0iXTqurgWNufKnJV0CbBK9Cf4gMijBLU5o4aJZMIp7fp7j9Yyr_It1ymcNqE6Ds_NsfTet850lcGXHEPBoe0Ed8dhQ6H1uGZ07IzteLrvxf7JgTFdhqrTiF8yMwo3b5Ocy6gmhnP0B6MW5iaUO8FgBELxyZ1vWSVyUrjaM0-_6fWh31M-gXqGcZw","token_type":"Bearer","access_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im5ZdVZJWTJTN3gxVHRYM01KMC1QMDJad3pXQSJ9.eyJpc3MiOiJodHRwczovL2F1dGgudGVzbGEuY29tL29hdXRoMi92MyIsImF1ZCI6WyJodHRwczovL293bmVyLWFwaS50ZXNsYW1vdG9ycy5jb20vIiwiaHR0cHM6Ly9hdXRoLnRlc2xhLmNvbS9vYXV0aDIvdjMvdXNlcmluZm8iXSwiYXpwIjoib3duZXJhcGkiLCJzdWIiOiI2ZTI2NGFlNy02ZTBmLTRkNDctYTY0My1mNGY4MjM4MzBlNzciLCJzY3AiOlsib3BlbmlkIiwiZW1haWwiLCJvZmZsaW5lX2FjY2VzcyJdLCJhbXIiOlsicHdkIiwibWZhIiwib3RwIl0sImV4cCI6MTY3NzQ2MDE5NCwiaWF0IjoxNjc3NDMxMzk0LCJhdXRoX3RpbWUiOjE2Nzc0MzEzOTN9.TytJ_4BA2tCW6aq-9Bf7dlMeOQ0LvgKD28RRr_cqVsoDbZWuTSNK5ceT21MjfqgKswXm4qJItFduW2Wi7yCgKw0WKBYrjPnInxo26oNa0x3nECOWcayblC-ug9axDn7_dVeIcr8OBZXkPdJnb-Wf1rElHWW-O8tIirkmma67-p21U_nRWzNe1jMtbnwSjhLJ8sCyMhrbrXUMgjkQVA9HAfTJkTXIyEJzPyniybn6z4dL7nTyEB4HQ4FM6tlNPDNF68ze36LXJlX5xR_baL2YQmyIly2Ow6v46OBDZzYcquHXVXJ-0-4R71CTGvOm4_RgVFOQPy8BSX_D47k2IXl4BA","created_at":699124194.52382803}
"""
      let data = str.data(using: .utf8)
      UserDefaults.standard.set(data, forKey: "token")
    }
    
  }
  
  override func setUp() async throws {
    if let id = UserDefaults.standard.object(forKey: "vid") as? Int64 {
      vehicleID = id
    }
  }
  
  func testVehicles() async throws {
    do {
      let v = try await api.vehicles(token: token, onRefresh: onRefresh)
      XCTAssert(v.count == 1, "expected one vehicle")
      let vid = v.first?.id
      XCTAssertNotNil(vid, "expected ID for first vehicle")
      UserDefaults.standard.set(vid, forKey: "vid")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testVehicle() async {
    do {
      let v = try await api.getVehicle(id: vehicleID, token: token, onRefresh: onRefresh)
      XCTAssert(v.displayName == "Tess", "Vehicle name mismatch")
      XCTAssertEqual(v.vin, "LRW3E7FA5MC306961", "vin mismatch")
      XCTAssert(v.inService == false, "expected inService false")
      XCTAssert(v.calendarEnabled == true, "calendarEnabled mismatch")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testChargeState() async {
    do {
      let cs = try await api.getVehicleChargeState(id: vehicleID, token: token, onRefresh: onRefresh)
      XCTAssert(cs.batteryLevel > 10, "low battery level")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testDriveState() async {
    do {
      let ds = try await api.getVehicleDriveState(id: vehicleID, token: token, onRefresh: onRefresh)
      XCTAssert(ds.shiftState == .park || ds.shiftState == nil, "not in park")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testClimateState() async {
    do {
      let _ = try await api.getVehicleClimateState(id: vehicleID, token: token, onRefresh: onRefresh)
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testGuiSettings() async {
    do {
      let _ = try await api.getVehicleGuiSettings(id: vehicleID, token: token, onRefresh: onRefresh)
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testVehicleState() async {
    do {
      let x = try await api.getVehicleState(id: vehicleID, token: token, onRefresh: onRefresh)
      print("\(x.frontRightTirePressure?.psi ?? -1)")
      XCTAssert((x.frontRightTirePressure?.psi ?? 0) > 0, "no tire pressure")
      XCTAssertEqual(x.vehicleName, "Tess", "not tess?")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testVehicleConfig() async {
    do {
      let x = try await api.getVehicleConfig(id: vehicleID, token: token, onRefresh: onRefresh)
      XCTAssertEqual(x.euVehicle, true, "not eu vehiclee")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
  
  func testAllStates() async {
    do {
      let a = try await api.getAllVehicleStates(id: vehicleID, token: token, onRefresh: onRefresh)
      XCTAssertNotNil(a.driveState,"nil drive state")
      XCTAssertNotNil(a.climateState, "nil climate state")
      XCTAssertNotNil(a.chargeState, "nil chargeState")
      XCTAssertNotNil(a.vehicleState,"nil vehicle state")
      XCTAssertEqual(a.vin, "LRW3E7FA5MC306961", "vin mismatch")
    } catch let e as DecodingError {
      XCTFail("Decoding Error: \(e.description)")
    } catch {
      XCTFail("Error: \(error.localizedDescription)")
    }
  }
}

extension DecodingError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .typeMismatch(_, let context):
      return "type mismatch: \(context.debugDescription)"
    case .valueNotFound(_, let context):
      return "value not found: \(context.debugDescription)"
    case .keyNotFound(_, let context):
      return "key not found: \(context.debugDescription)"
    case .dataCorrupted(let context):
      return "data corrupted: \(context.debugDescription))"
    @unknown default:
      return "unknown error"
    }
  }
}
