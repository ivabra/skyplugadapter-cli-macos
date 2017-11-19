//
//  CBManagerState+Description.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation
import CoreBluetooth

@available(iOS 10.0, tvOS 10, OSX 10.13, watchOS 3.0, *)
extension CBManagerState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unknown: return "Unknown"
    case .resetting: return "Resetting"
    case .unsupported: return "Unsupported"
    case .unauthorized: return "Unauthorized"
    case .poweredOff: return "Powered off"
    case .poweredOn: return "Powered on"
    }
  }
}

@available(iOS, deprecated: 10.0)
@available(OSX, deprecated: 10.13)
@available(watchOS, deprecated: 3.0)
@available(tvOS, deprecated: 10.0)
extension CBCentralManagerState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unknown: return "Unknown"
    case .resetting: return "Resetting"
    case .unsupported: return "Unsupported"
    case .unauthorized: return "Unauthorized"
    case .poweredOff: return "Powered off"
    case .poweredOn: return "Powered on"
    }
  }
}

