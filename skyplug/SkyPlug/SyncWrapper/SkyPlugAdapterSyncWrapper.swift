//
//  SkyPlugAdapterSyncWrapper.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation

final class SkyPlugAdapterSyncWrapper {
  
  private let wrapped: SkyPlugAdapter
  private var semaphoreMap = [String: DispatchSemaphore]()
  private var errorMap = [String : Error]()
  private var resultMap = [String : Any]()

  
  init(wrapped: SkyPlugAdapter) {
    self.wrapped = wrapped
    wrapped.delegate = self
  }
  
  @discardableResult
  private func wait(for event: String, action: ()->Void) throws -> Any? {
    errorMap.removeValue(forKey: event)
    resultMap.removeValue(forKey: event)
    let semaphore = DispatchSemaphore(value: 0)
    semaphoreMap[event] = semaphore
    action()
    semaphoreMap[event]?.wait()
    if let error = errorMap.removeValue(forKey: event) {
      throw error
    }
    return resultMap.removeValue(forKey: event)
  }
  
  private func finish(_ event: String, result: Any? = nil) {
    resultMap[event] = result
    if let semaphore = semaphoreMap.removeValue(forKey: event) {
      semaphore.signal()
    }
  }
  
  private func finish(_ event: String, error: Error?) {
    errorMap[event] = error
    if let semaphore = semaphoreMap.removeValue(forKey: event) {
      semaphore.signal()
    }
  }
  
  private func finishAll(error: Error? = nil) {
    for key in semaphoreMap.keys {
      finish(key, error: error)
    }
  }
  
}

extension SkyPlugAdapterSyncWrapper : SkyPlugSyncAdapter {
  
  func connect() throws {
    try wait(for: "ready") {
      wrapped.connect()
    }
  }
  
  func turnOn() throws {
    try wait(for: "on") {
      wrapped.turnOn()
    }
  }
  
  func turnOff() throws {
    try wait(for: "off") {
      wrapped.turnOff()
    }
  }
  
  func queryState() throws -> SkyPlugAdapterState?  {
    return try wait(for: "query") {
      wrapped.queryState()
      } as? SkyPlugAdapterState
  }
  
  func disconnect() throws {
    try wait(for: "disconnect") {
      wrapped.disconnect()
    }
  }
}

extension SkyPlugAdapterSyncWrapper : SkyPlugAdapterDelegate {
  
  func scannedDidDisconnect(_ scanner: SkyPlugAdapter, error: Error?) {
    finish("disconnect", result: error)
  }

  func scannedDidOn(_ scanner: SkyPlugAdapter, error: Error?) {
    finish("on", error: error)
  }
  
  func scannedDidOff(_ scanner: SkyPlugAdapter, error: Error?) {
    finish("off", error: error)
  }
  
  func scannedDidReady(_ scanner: SkyPlugAdapter) {
    finish("ready")
  }
  
  func scannedDidDisconnect(_ scanner: SkyPlugAdapter) {
    finish("disconnect")
  }
  
  func scannedDidFinishedQuery(_ scanner: SkyPlugAdapter, error: Error?) {
    if let error = error {
      finish("query", error: error)
    } else {
      finish("query", result: scanner.lastState)
    }
  }
  
  func scannedDidReadState(_ scanner: SkyPlugAdapter, data: Data) {
    finish("data", result: data)
  }
  
  func scannedDidFailWithError(_ scanner: SkyPlugAdapter, fail: Error?) {
    finishAll(error: fail)
  }
}

extension String : Error {}
