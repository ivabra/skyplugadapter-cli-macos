//
//  String+Hex.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

extension String {
  
  var asHexBytes: [UInt8]? {
    let length = self.count
    if length & 1 != 0 {
      return nil
    }
    var bytes = [UInt8]()
    bytes.reserveCapacity(length/2)
    var index = self.startIndex
    for _ in 0..<length/2 {
      let nextIndex = self.index(index, offsetBy: 2)
      if let b = UInt8(self[index..<nextIndex], radix: 16) {
        bytes.append(b)
      } else {
        return nil
      }
      index = nextIndex
    }
    return bytes
  }
  
  var asHexData: Data? {
    if let bytes = asHexBytes {
      return Data(bytes: bytes)
    }
    return nil
  }
  
}
