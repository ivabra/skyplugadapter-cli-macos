//
//  ConfigFile.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

struct ConfigFile {

  enum Keys: String {
    case serviceUUID
    case notifyCharacteristicUUID
    case valueCharacteristicUUID
    case onHexData
    case offHexData
    case queryHexData
    case authorizationHexData
    static var all: Set<Keys> = [.serviceUUID,
                                 .notifyCharacteristicUUID,
                                 .valueCharacteristicUUID,
                                 .onHexData,
                                 .offHexData,
                                 .queryHexData,
                                 .authorizationHexData]
  }
  
  var serviceUUID: String!
  var notifyCharacteristicUUID: String!
  var valueCharacteristicUUID: String!
  var onHexData: Data!
  var offHexData: Data!
  var queryHexData: Data!
  var authorizationHexData: Data!
  
  init(file: URL) throws {
    var dict = [Keys : String]()
    let string = try String(contentsOf: file)
    
    Log.debug(string)
    
    string
      .components(separatedBy: .newlines)
      .filter { $0.isEmpty == false}
      .flatMap { string -> (String, String)? in
        Log.debug(string)
      let all = string.split(separator: "=").map { String($0) }
      if all.isEmpty {
        return nil
      }
      return (all[0], all[1])
    }.forEach { (key, value) in
      if let fileKey = Keys(rawValue: key) {
        dict[fileKey] = value
      }
    }
  
    let lostKeys = Keys.all.subtracting(dict.keys)
    guard lostKeys.isEmpty else {
      throw "No values for keys \(lostKeys)"
    }
    
    for (key, value) in dict {
      switch key {
      case .serviceUUID:
        serviceUUID = value
      case .notifyCharacteristicUUID:
        notifyCharacteristicUUID = value
      case .valueCharacteristicUUID:
        valueCharacteristicUUID = value
      case .onHexData:
        onHexData = value.asHexData
      case .offHexData:
        offHexData = value.asHexData
      case .queryHexData:
        queryHexData = value.asHexData
      case .authorizationHexData:
        authorizationHexData = value.asHexData
      }
    }
  }
 
}
