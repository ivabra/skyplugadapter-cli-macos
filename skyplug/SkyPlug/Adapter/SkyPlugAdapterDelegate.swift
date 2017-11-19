//
//  SkyPlugAdapterDelegate.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

protocol SkyPlugAdapterDelegate: class {
  func scannedDidReady(_ scanner: SkyPlugAdapter)
  func scannedDidOn(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidOff(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidReadState(_ scanner: SkyPlugAdapter, data: Data)
  func scannedDidDisconnect(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidFinishedQuery(_ scanner: SkyPlugAdapter, error: Error?)
  func scannedDidFailWithError(_ scanner: SkyPlugAdapter, fail: Error?)
}
