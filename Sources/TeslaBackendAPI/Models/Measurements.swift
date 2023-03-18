//
//  File.swift
//
//
//  Created by Guy on 25/02/2023.
//

import Foundation

public struct Distance: Codable {
  public var value: Measurement<UnitLength>
  
  public init(kms value: Double = 0) {
    self.value = Measurement(value: value, unit: .kilometers)
  }
  
  public init(miles value: Double) {
    self.value = Measurement(value: value, unit: .miles)
  }
    
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let tempValue = try? container.decode(Double.self) {
      value = Measurement(value: tempValue, unit: UnitLength.miles)
    } else {
      value = Measurement(value: 0, unit: UnitLength.miles)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value.converted(to: .miles).value)
  }
  
  public var miles: Double { value.converted(to: .miles).value }
  public var kms: Double { value.converted(to: .kilometers).value }
}

public struct Speed: Codable {
  public var value: Measurement<UnitSpeed>
  
  public init(kmh value: Double = 0) {
    self.value = Measurement(value: value, unit: .kilometersPerHour)
  }
  
  public init(mph value: Double) {
    self.value = Measurement(value: value, unit: .milesPerHour)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let tempValue = try? container.decode(Double.self) {
      value = Measurement(value: tempValue, unit: UnitSpeed.milesPerHour)
    } else {
      value = Measurement(value: 0, unit: UnitSpeed.milesPerHour)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value.converted(to: .milesPerHour).value)
  }
  
  public var mph: Double { value.converted(to: .milesPerHour).value }
  public var kmh: Double { value.converted(to: .kilometersPerHour).value }
}

public struct Pressure: Codable {
  public var value: Measurement<UnitPressure>
  
  public init(psi value: Double = 0) {
    self.value = Measurement(value: value, unit: .poundsForcePerSquareInch)
  }
  
  public init(bar value: Double) {
    self.value = Measurement(value: value, unit: .bars)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let tempValue = try? container.decode(Double.self) {
      value = Measurement(value: tempValue, unit: UnitPressure.bars)
    } else {
      value = Measurement(value: 0, unit: UnitPressure.bars)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value.converted(to: .bars).value)
  }
  
  public var bar: Double { value.converted(to: .bars).value }
  public var psi: Double { value.converted(to: .poundsForcePerSquareInch).value }
}

public struct Temperature: Codable {
  public var value: Measurement<UnitTemperature>
  
  init(celsius value: Double = 0) {
    self.value = Measurement(value: value, unit: .celsius)
  }
  
  init(fahrenheit value: Double) {
    self.value = Measurement(value: value, unit: .fahrenheit)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let tempValue = try container.decode(Double?.self) {
      value = Measurement<UnitTemperature>(value: tempValue, unit: .celsius)
    } else {
      value = Measurement<UnitTemperature>(value: 0, unit: .celsius)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value.converted(to: .celsius).value)
  }
  
  public var celsius: Double { value.converted(to: .celsius).value }
  public var fahrenheit: Double { value.converted(to: .fahrenheit).value }
}

public struct TimeStamp: Codable {
  public var value: TimeInterval
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let tempValue = try container.decode(Double.self)
    value = tempValue / 1000
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value * 1000)
  }
  
  public var ms: Int { Int(value * 1000) }
  public var timeInterval: Double { value }
  public var seconds: Double { value }
}
