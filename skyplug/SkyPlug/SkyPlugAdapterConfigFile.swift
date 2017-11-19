//
//  ConfigFile.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public struct SkyPlugAdapterConfig {
  
  public struct ParseError: Error, CustomStringConvertible {
    public let description: String
    var localizedDescription: String {
      return description
    }
  }
  
  public var serviceUUID: String!
  public var notifyCharacteristicUUID: String!
  public var valueCharacteristicUUID: String!
  public var onHexData: Data!
  public var offHexData: Data!
  public var queryHexData: Data!
  public var authorizationHexData: Data!
  
  public init(configDictionary: [String : String]) throws {
    let configKeys = configDictionary.keys.flatMap { Keys(rawValue: $0) }
    let lostKeys = Keys.required.subtracting(configKeys)
    guard lostKeys.isEmpty else {
      throw ParseError(description: "Configuration file assert failure. No values for keys \(lostKeys.map { "'\($0.rawValue)'" }.joined(separator: ", "))")
    }
    configKeys.forEach {
      let value = configDictionary[$0.rawValue]
      switch $0 {
      case .serviceUUID:
        serviceUUID = value
      case .notifyCharacteristicUUID:
        notifyCharacteristicUUID = value
      case .valueCharacteristicUUID:
        valueCharacteristicUUID = value
      case .onHexData:
        onHexData = value?.asHexData
      case .offHexData:
        offHexData = value?.asHexData
      case .queryHexData:
        queryHexData = value?.asHexData
      case .authorizationHexData:
        authorizationHexData = value?.asHexData
      }
    }
  }
 
}

private extension SkyPlugAdapterConfig {
  
  enum Keys: String {
    case serviceUUID
    case notifyCharacteristicUUID
    case valueCharacteristicUUID
    case onHexData
    case offHexData
    case queryHexData
    case authorizationHexData
    
    static let required: Set<Keys> = [.serviceUUID,
                                      .notifyCharacteristicUUID,
                                      .valueCharacteristicUUID,
                                      .onHexData,
                                      .offHexData,
                                      .queryHexData,
                                      .authorizationHexData]
  }
}
