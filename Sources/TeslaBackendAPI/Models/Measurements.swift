//
//  File.swift
//
//
//  Created by Guy on 25/02/2023.
//

import Foundation

public struct Distance: Codable {
  public var value: Measurement<UnitLength>
  
  public init(miles: Double?) {
    let tempValue = miles ?? 0.0
    value = Measurement(value: tempValue, unit: UnitLength.miles)
  }

  public init(kms: Double) {
    value = Measurement(value: kms, unit: UnitLength.kilometers)
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
  
  public var miles: Double { return value.converted(to: .miles).value }
  public var kms: Double { return value.converted(to: .kilometers).value }
}

public struct Speed: Codable {
  public var value: Measurement<UnitSpeed>
  
  public init(milesPerHour: Double?) {
    let tempValue = milesPerHour ?? 0.0
    value = Measurement(value: tempValue, unit: UnitSpeed.milesPerHour)
  }

  public init(kilometersPerHour: Double) {
    value = Measurement(value: kilometersPerHour, unit: UnitSpeed.kilometersPerHour)
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
  
  public var mph: Double { return value.converted(to: .milesPerHour).value }
  public var kmh: Double { return value.converted(to: .kilometersPerHour).value }
}

public struct Pressure: Codable {
  public var value: Measurement<UnitPressure>
  
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
  
  public var bar: Double { return value.converted(to: .bars).value }
  public var psi: Double { return value.converted(to: .poundsForcePerSquareInch).value }
}

public struct Temperature: Codable {
  public var value: Measurement<UnitTemperature>
  
  public init(celsius: Double?) {
    let tempValue = celsius ?? 0.0
    value = Measurement<UnitTemperature>(value: tempValue, unit: .celsius)
  }
  
  public init(fahrenheit: Double) {
    value = Measurement<UnitTemperature>(value: fahrenheit, unit: .fahrenheit)
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
  
  public var celsius: Double { return value.converted(to: .celsius).value }
  public var fahrenheit: Double { return value.converted(to: .fahrenheit).value }
}
