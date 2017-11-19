//
//  Log.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

extension String {
  static let logSeparator = " -> "
}

enum Log {
  
  static var debugMode: Bool = false
  
  static var dateFormat: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    return df
  }()
  
  private static var nowString: String {
    return dateFormat.string(from: Date())
  }
  
  static func debug<T>(_ arg: @autoclosure () -> T) {
    if debugMode {
      print(nowString, arg(), separator: .logSeparator)
    }
  }
  
  static func debug<T>(_ error: Error?, _ arg: @autoclosure () -> T) {
    if debugMode {
      if let error = error {
        print(nowString, arg(), "Error: \(error)", separator: .logSeparator)
      } else {
        print(nowString, arg(), separator: .logSeparator)
      }
    }
  }
  
}
