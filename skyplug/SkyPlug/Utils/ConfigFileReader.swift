//
//  ConfigFileReader.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public struct ConfigurationFileReaderError: Error, CustomStringConvertible {
  public let description: String
  var underlyingError: Error?
  var localizedDescription: String {
    return description
  }
}

public func readConfigFile(fileUrl: URL) throws -> [String: String] {
  
  let configString: String = try {
    do {
      return try String(contentsOf: fileUrl)
    }
    catch {
      Log.debug(error, "Failed reading the configuration file")
      throw ConfigurationFileReaderError(description: "Can't load configuration file", underlyingError: error)
    }
  }()
  
  Log.debug("Got config file:\n\(configString)")
  
  var dictionary = [String : String]()
  configString.components(separatedBy: .newlines)
    .filter { $0.isEmpty == false}
    .forEach { string in
      let all = string.split(separator: "=").map { String($0) }
      if all.count < 2 {
        return
      }
      dictionary[all[0]] = all[1]
  }
  return dictionary
}
