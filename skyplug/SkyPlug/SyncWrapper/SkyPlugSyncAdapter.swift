//
//  SkyPlugSyncAdapter.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public protocol SkyPlugSyncAdapter: class {
  var lastReceivedState: SkyPlugAdapterState? { get }
  var searchTimeout: TimeInterval? { get set }
  func connect() throws
  func disconnect() throws
  func turnOn() throws
  func turnOff() throws
  func queryState() throws -> SkyPlugAdapterState?
}
