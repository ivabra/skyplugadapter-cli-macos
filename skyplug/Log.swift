//
//  Log.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

enum Log {
  
  static var debugMode: Bool = false
  static var dateFormat: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    return df
  }()
  
  static func debug<T>(_ arg: @autoclosure () -> T) {
    if debugMode {
      let date = Date()
      print(dateFormat.string(from: date), arg(), separator: " -> ")
    }
  }
  
  static func debug<T>(_ arg: @autoclosure () -> (T, Error?)) {
    if debugMode {
      let date = Date()
      let (value, error) = arg()
      if let error = error {
        print(dateFormat.string(from: date), value, error, separator: " -> ")
      } else {
        print(dateFormat.string(from: date), value, separator: " -> ")
      }
    }
  }
  
}
