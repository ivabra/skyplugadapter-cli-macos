//
//  Enviroment.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

private let defaultConfigFileNames = [".skyplugfile", "skyplugfile"]
private let configFileFlag = "--configfile"
private let debugFlag = "--debug"

enum Arguments {
  
  enum Action: String {
    case on
    case off
    case query
  }
  
  static var debug: Bool {
    return CommandLine.arguments.contains { $0.starts(with: debugFlag) }
  }
  
  static let executionDirectory = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
  
  static var action: Action? {
    guard CommandLine.arguments.count >= 2 else {
      return nil
    }
    return Action(rawValue: CommandLine.arguments[1])
  }
  
  static var configFileURL: URL? {
    var urls = defaultConfigFileNames.map { executionDirectory.appendingPathComponent($0) }
    if let index = CommandLine.arguments.index(where: { $0.starts(with: configFileFlag) }), CommandLine.arguments.count > index {
      let file = CommandLine.arguments[index + 1]
      urls.append(URL(fileURLWithPath: file))
      urls.append(executionDirectory.appendingPathComponent(file))
    }
    let fm = FileManager.default
    return urls.first { fm.fileExists(atPath: $0.path) }
  }
  
  static let config: [String: String] = {
   
    guard let file = configFileURL else {
      Log.debug("No configuration file")
      return [:]
    }
    
    guard let configString: String = {
      do {
        return try String(contentsOf: file)
      }
      catch {
        Log.debug(error, "Can't load configuration file because of error")
        return nil
      }
      }() else {
        return [:]
    }
    
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
  }()
}
