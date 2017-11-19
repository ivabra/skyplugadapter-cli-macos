//
//  main.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Cocoa

Log.debugMode = Arguments.debug

func initializeAdapter() throws -> SkyPlugSyncAdapter {
  let config = try SkyPlugAdapterConfig(configDictionary: Arguments.config)
  let adapter = SkyPlugAdapterMakeDefault(config: config)
  if let timeoutString = Arguments.config["searchTimeout"], let timeout = TimeInterval(timeoutString) {
    adapter.searchTimeout = timeout
  }
  return adapter
}

func main() throws {
  guard let action = Arguments.action else {
    throw "No actions"
  }
  let adapter = try initializeAdapter()
  defer {
    try? adapter.disconnect()
  }
  try adapter.connect()
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

do {
 try main()
} catch {
  Log.debug(error, "Finished with errors")
  print("error:", error)
  exit(1)
}


