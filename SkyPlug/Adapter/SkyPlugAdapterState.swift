//
//  SkyPlugAdapterState.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public enum SkyPlugAdapterState: UInt8, CustomStringConvertible {
  
  case off = 0x00
  case on = 0x02
  
  public static let unknownStateDescription: String = "unknown"
  
  public var description: String {
    switch self {
    case .on: return "on"
    case .off: return "off"
    }
  }
}
