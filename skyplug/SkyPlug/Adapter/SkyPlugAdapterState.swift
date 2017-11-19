//
//  SkyPlugAdapterState.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

enum SkyPlugAdapterState: UInt8, CustomStringConvertible {
  
  case off = 0x00
  case on = 0x02
  
  static let unknownStateDescription: String = "unknown"
  
  var description: String {
    switch self {
    case .on: return "on"
    case .off: return "off"
    }
  }
}
