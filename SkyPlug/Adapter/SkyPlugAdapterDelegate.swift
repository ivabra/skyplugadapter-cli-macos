//
//  SkyPlugAdapterDelegate.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public protocol SkyPlugAdapterDelegate: class {
  func scannedDidReady(_ scanner: SkyPlugAdapter)
  func scannedDidOn(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidOff(_ scanner: SkyPlugAdapter, error: Error?) 
  func scannedDidDisconnect(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidFinishQueryDeviceState(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidFailWithError(_ scanner: SkyPlugAdapter, fail: Error?)
}
