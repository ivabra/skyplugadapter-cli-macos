//
//  SystemBluetoothDevice.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 20/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

private extension String {
  static let deviceNameKey = "Name"
  static let deviceDisplayNameKey = "displayName"
}

public extension SystemBluetooth {
  public struct Device {
    let address: String
    let info: [String : Any]
  }
}

extension SystemBluetooth.Device {
  public var name: String? {
    return info[.deviceNameKey] as? String
  }
  public var displayName: String? {
    return info[.deviceDisplayNameKey] as? String
  }
}

extension SystemBluetooth.Device : Hashable {
  public var hashValue: Int {
    return address.hashValue
  }
  public static func == (left: SystemBluetooth.Device, right: SystemBluetooth.Device) -> Bool {
    return left.address == right.address
  }
}
