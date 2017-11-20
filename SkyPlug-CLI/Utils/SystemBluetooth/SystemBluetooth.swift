//
//  SystemBluetooth.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 20/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation
import SystemConfiguration

private extension CFString {
  static let pairedDevicesKey = "PairedDevices" as CFString
  static let lePairedDevicesKey = "LEPairedDevices" as CFString
  static let deviceCacheKey = "DeviceCache" as CFString
  
  static let preferencesName  = "SkyPlug" as CFString
  static let bluetoothPlist  = "/Library/Preferences/com.apple.Bluetooth.plist" as CFString
}


enum SystemBluetooth {
  
  enum Errors: Error, LocalizedError {
    case noAccessToSystemConfiguration
    case systemError(error: CFErrorWrapper)
    
    var errorDescription: String? {
      switch self {
      case .noAccessToSystemConfiguration:
        return "No access to system configuration"
      case .systemError(let error):
        return error.errorDescription ?? error.localizedDescription
      }
    }
  }
  
  private static func bluetoothPreferences() throws -> SCPreferences {
    guard let prefs = SCPreferencesCreate(kCFAllocatorDefault, .preferencesName, .bluetoothPlist) else {
      throw Errors.noAccessToSystemConfiguration
    }
    return prefs
  }
  
  static func findPairedDevices() throws -> Set<SystemBluetooth.Device> {
    
    let prefs = try bluetoothPreferences()
    
    let pairedDevices: Set<String> = {
      let pairedDevices = SCPreferencesGetValue(prefs, .pairedDevicesKey) as? [String] ?? []
      let blePairedDevices = SCPreferencesGetValue(prefs, .lePairedDevicesKey) as? [String] ?? []
      return Set(pairedDevices + blePairedDevices)
    }()
    
    guard let cachedDevices = SCPreferencesGetValue(prefs, .deviceCacheKey) as? NSDictionary else {
      return []
    }
    
    let filtered = Set(cachedDevices
      .filter { pairedDevices.contains($0.key as! String) }
      .map { SystemBluetooth.Device(address: $0.key as! String, info: $0.value as! [String : Any]) })
    
    return filtered
  }
  
  static func findPairedDevices(byName: (String) -> Bool) throws -> Set<Device> {
    return Set(try findPairedDevices().filter { $0.name.map(byName) == true })
  }
  
  static func unpairAllDevicesWithName(_ name: (String) -> Bool) throws {
    for device in try findPairedDevices(byName: name) {
      try unpairDevice(withAddress: device.address)
    }
  }
  
  static func unpairDevice(withAddress address: String) throws {
    try unpairClassicDevice(withAddress: address)
    try unpairLEDevice(withAddress: address)
  }
  
  static func unpairClassicDevice(withAddress address: String) throws {
    try unpairDevice(withAddress: address, preferencesKey: .pairedDevicesKey)
  }
  
  static func unpairLEDevice(withAddress address: String) throws {
    try unpairDevice(withAddress: address, preferencesKey: .lePairedDevicesKey)
  }
  
  static func unpairDevice(withAddress address: String, preferencesKey: CFString) throws {
    let prefs = try bluetoothPreferences()
    guard var pairedDevices = SCPreferencesGetValue(prefs, preferencesKey) as? [String] else {
      return
    }
    if let index = pairedDevices.index (where: { $0 == address }) {
      pairedDevices.remove(at: index)
      guard SCPreferencesSetValue(prefs, .pairedDevicesKey, pairedDevices as CFPropertyList), SCPreferencesCommitChanges(prefs) else {
        throw Errors.systemError(error: SCCopyLastError().wrapping())
      }
    }
  }
  
}


