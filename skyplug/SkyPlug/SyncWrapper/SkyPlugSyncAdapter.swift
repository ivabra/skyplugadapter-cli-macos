//
//  SkyPlugSyncAdapter.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

protocol SkyPlugSyncAdapter: class {
  func connect() throws
  func disconnect() throws
  func turnOn() throws
  func turnOff() throws
  func queryState() throws -> SkyPlugAdapterState?
}
