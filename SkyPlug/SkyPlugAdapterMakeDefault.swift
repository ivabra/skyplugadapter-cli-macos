//
//  SkyPlugAdapterMakeDefault.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation
import CoreBluetooth

public func SkyPlugAdapterMakeDefault(bundle: Bundle = .main, fileName: String = "skyplugfile" ) throws -> SkyPlugSyncAdapter? {
  guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
    return nil
  }
  return try SkyPlugAdapterMakeDefault(configFileURL: url)
}

public func SkyPlugAdapterMakeDefault(configFileURL: URL) throws -> SkyPlugSyncAdapter {
  let file = try readConfigFile(fileUrl: configFileURL)
  let config = try SkyPlugAdapterConfig(configDictionary: file)
  return SkyPlugAdapterMakeDefault(config: config)
}

public func SkyPlugAdapterMakeDefault(config: SkyPlugAdapterConfig) -> SkyPlugSyncAdapter {
  return SkyPlugAdapterSyncWrapper(wrapped: SkyPlugAdapter(serviceUUID: CBUUID(string: config.serviceUUID),
                                                           notifyCharacteristicUUID: CBUUID(string: config.notifyCharacteristicUUID),
                                                           valueCharacteristicUUID: CBUUID(string: config.valueCharacteristicUUID),
                                                           onData: config.onHexData,
                                                           offData: config.offHexData,
                                                           queryData: config.queryHexData,
                                                           authorizationData: config.authorizationHexData))
}
