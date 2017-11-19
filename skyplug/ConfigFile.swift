//
//  ConfigFile.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

struct ConfigFile {
  
  var serviceUUID: String!
  var notifyCharacteristicUUID: String!
  var valueCharacteristicUUID: String!
  var onHexData: Data!
  var offHexData: Data!
  var queryHexData: Data!
  var authorizationHexData: Data!
  
  init(configDictionary: [String : String]) throws {
    let configKeys = configDictionary.keys.flatMap { Keys(rawValue: $0) }
    let lostKeys = Keys.required.subtracting(configKeys)
    guard lostKeys.isEmpty else {
      throw "Configuration file assert failure. No values for keys \(lostKeys.map { "'\($0.rawValue)'" }.joined(separator: ", "))"
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

private extension ConfigFile {
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
