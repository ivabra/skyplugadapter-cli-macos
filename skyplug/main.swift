//
//  main.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Cocoa

Log.debugMode = Arguments.debug

func main() throws {
  
  guard let action = Arguments.action else {
    throw "No actions"
  }
  
  let file = try ConfigFile(configDictionary: Arguments.config)
  
  let adapter = SkyPlugAdapterMakeDefault(configFile: file)
  if let timeoutString = Arguments.config["searchTimeout"], let timeout = TimeInterval(timeoutString) {
    adapter.searchTimeout = timeout
  }
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
    print(state?.description ?? SkyPlugAdapterState.unknownStateDescription)
  }
}

do {
 try main()
} catch {
  Log.debug(error)
  fatalError(String(describing: error))
}


