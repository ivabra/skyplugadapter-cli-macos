//
//  CBManagerState+Description.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation
import CoreBluetooth

@available(OSX 10.13, *)
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
