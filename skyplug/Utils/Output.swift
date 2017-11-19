//
//  Output.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

enum Output {
  static func convert(_ adapterState: SkyPlugAdapterState?) -> String {
    switch adapterState {
    case .some(let wrapped):
      switch wrapped {
      case .on:
        return Arguments.config["onStateName"] ?? SkyPlugAdapterState.on.description
      case .off:
        return Arguments.config["offStateName"] ?? SkyPlugAdapterState.off.description
      }
    case .none:
      return Arguments.config["unknownStateName"] ?? SkyPlugAdapterState.unknownStateDescription
    }
  }
}
