//
//  CBPeripheral+Name.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
  var nameOrUUID: String {
    if #available(OSX 10.13, *) {
      return name ?? identifier.description
    } else {
      return name ?? "Untitled"
    }
  }
}
