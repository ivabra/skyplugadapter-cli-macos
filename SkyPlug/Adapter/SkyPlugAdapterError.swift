//
//  SkyPlugAdapterError.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 20/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public struct SkyPlugAdapterError: Error, CustomStringConvertible {
  
  public let description: String
  public let underlyingError: Error?
  
  init(description: String, error: Error?) {
    self.description = description
    self.underlyingError = error
  }
  
  init(description: String) {
    self.description = description
    self.underlyingError = nil
  }
  
  init(error: Error) {
    self.description = error.localizedDescription
    self.underlyingError = error
  }
}
