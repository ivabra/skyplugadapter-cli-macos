//
//  Log.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public enum Log {
  
  public static var debugMode: Bool = false
  
  static func debug<T>(_ arg: @autoclosure () -> T) {
    if debugMode {
      NSLog("\(arg())")
    }
  }
  
  static func debug<T>(_ error: Error?, _ arg: @autoclosure () -> T) {
    if debugMode {
      if let error = error {
        NSLog("\(arg()); Error: \(error)")
      } else {
        print("\(arg())")
      }
    }
  }
  
}
