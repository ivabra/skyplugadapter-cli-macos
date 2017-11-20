//
//  main.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Cocoa

Log.debugMode = Arguments.debug

func main() throws {
  guard let action = Arguments.action else {
    throw "No actions"
  }
  let adapter = try initializeAdapter()
  var deviceName: String?
  defer {
    disconnectAdapter(adapter)
    if let device = deviceName {
      disconnectDevice(name: device)
    }
  }
  try adapter.connect()
  deviceName = adapter.deviceName
  switch action {
  case .on:
    try adapter.turnOn()
  case .off:
    try adapter.turnOff()
  case .query:
    let state = try adapter.queryState()
    print(Output.convert(state))
  }
}

func initializeAdapter() throws -> SkyPlugSyncAdapter {
  let config = try SkyPlugAdapterConfig(configDictionary: Arguments.config)
  let adapter = SkyPlugAdapterMakeDefault(config: config)
  if let timeoutString = Arguments.config["searchTimeout"], let timeout = TimeInterval(timeoutString) {
    adapter.searchTimeout = timeout
  }
  return adapter
}

func disconnectDevice(name: String) {
  do {
    try SystemBluetooth.unpairAllDevicesWithName { $0.contains(name) }
  } catch {
    Log.debug(error, "Failed to unpair device")
  }
}

func disconnectAdapter(_ adapter: SkyPlugSyncAdapter) {
  do {
    try adapter.disconnect()
  } catch {
    Log.debug(error, "Failed to disconnect BLE device")
  }
}

do {
  try main()
} catch {
  Log.debug(error, "Finished with errors")
  print("error:", error)
  exit(1)
}


