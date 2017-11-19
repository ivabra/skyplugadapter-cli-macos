//
//  Enviroment.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 19/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
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
    if let index = CommandLine.arguments.index(where: { $0.starts(with: configFileFlag) }) {
      let file = CommandLine.arguments[index]
      urls.append(URL(fileURLWithPath: file))
      urls.append(executionDirectory.appendingPathComponent(file))
    }
    let fm = FileManager.default
    return urls.first { fm.fileExists(atPath: $0.path) }
  }
}