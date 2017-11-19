//
//  SkyPlugAdapterMakeDefault.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation
import CoreBluetooth

func SkyPlugAdapterMakeDefault(configFile file: ConfigFile) -> SkyPlugSyncAdapter {
  return SkyPlugAdapterSyncWrapper(wrapped: SkyPlugAdapter(serviceUUID: CBUUID(string: file.serviceUUID),
                                                           notifyCharacteristicUUID: CBUUID(string: file.notifyCharacteristicUUID),
                                                           valueCharacteristicUUID: CBUUID(string: file.valueCharacteristicUUID),
                                                           onData: file.onHexData,
                                                           offData: file.offHexData,
                                                           queryData: file.queryHexData,
                                                           authorizationData: file.authorizationHexData))
}
