//
//  UInt8+HexString.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

extension UInt8 {
  var hexString: String {
    return String(format: "%02X", self)
  }
}
