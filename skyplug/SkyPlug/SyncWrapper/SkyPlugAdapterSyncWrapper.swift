//
//  SkyPlugAdapterSyncWrapper.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation


public final class SkyPlugAdapterSyncWrapper {
  
  private enum Event {
    case connect
    case ready
    case disconnect
    case on
    case off
    case query
  }
  
  private let wrapped: SkyPlugAdapter
  private var semaphoreMap = [Event: DispatchSemaphore]()
  private var errorMap = [Event : Error]()
  private var resultMap = [Event : Any]()

  private var safeQueue: DispatchQueue!
  
  init(wrapped: SkyPlugAdapter) {
    self.wrapped = wrapped
    safeQueue  = DispatchQueue(label: "com.dantelab.skyplugadapter.sync-queue-\(ObjectIdentifier(self).hashValue)" )
    wrapped.delegate = self
  }
  
  @discardableResult
  private func wait(for event: Event, action: ()->Void) throws -> Any? {
    safeQueue.sync {
      errorMap.removeValue(forKey: event)
      resultMap.removeValue(forKey: event)
      semaphoreMap[event] = DispatchSemaphore(value: 0)
    }
    action()
    safeQueue.sync { semaphoreMap[event] }?.wait()
    return try safeQueue.sync { () throws -> Any? in
      
      if let error = errorMap.removeValue(forKey: event) {
        throw error
      }
      return resultMap.removeValue(forKey: event)
    }
  }
  
  private func finish(_ event: Event, result: Any? = nil) {
    safeQueue.sync { () -> DispatchSemaphore? in
      resultMap[event] = result
      return semaphoreMap.removeValue(forKey: event)
    }?.signal()
  }
  
  private func finish(_ event: Event, error: Error?) {
    safeQueue.sync { () -> DispatchSemaphore? in
      errorMap[event] = error
      return semaphoreMap.removeValue(forKey: event)
    }?.signal()
  }
  
  private func finishAll(error: Error? = nil) {
    for key in semaphoreMap.keys {
      finish(key, error: error)
    }
  }
  
}

// MARK: SkyPlugSyncAdapter

extension SkyPlugAdapterSyncWrapper : SkyPlugSyncAdapter {
  
  public var searchTimeout: TimeInterval? {
    set {
      wrapped.searchTimeout = newValue
    }
    get {
      return wrapped.searchTimeout
    }
  }
  
  public var lastReceivedState: SkyPlugAdapterState? {
    return wrapped.lastReceivedState
  }
  
  public func connect() throws {
    try wait(for: .ready) {
      wrapped.connect()
    }
  }
  
  public func turnOn() throws {
    try wait(for: .on) {
      wrapped.turnOn()
    }
  }
  
  public func turnOff() throws {
    try wait(for: .off) {
      wrapped.turnOff()
    }
  }
  
  public func queryState() throws -> SkyPlugAdapterState?  {
    return try wait(for: .query) {
      wrapped.queryState()
      } as? SkyPlugAdapterState
  }
  
  public func disconnect() throws {
    try wait(for: .disconnect) {
      wrapped.disconnect()
    }
  }
}

extension SkyPlugAdapterSyncWrapper : SkyPlugAdapterDelegate {
  
  public func scannedDidReady(_ scanner: SkyPlugAdapter) {
    finish(.ready)
  }
  
  public func scannedDidDisconnect(_ scanner: SkyPlugAdapter, error: Error?) {
    finish(.disconnect, result: error)
  }

  public func scannedDidOn(_ scanner: SkyPlugAdapter, error: Error?) {
    finish(.on, error: error)
  }
  
  public func scannedDidOff(_ scanner: SkyPlugAdapter, error: Error?) {
    finish(.off, error: error)
  }
 
  public func scannedDidFinishQueryDeviceState(_ scanner: SkyPlugAdapter, error: Error?) {
    if let error = error {
      finish(.query, error: error)
    } else {
      finish(.query, result: scanner.lastReceivedState)
    }
  }
  
  public func scannedDidFailWithError(_ scanner: SkyPlugAdapter, fail: Error?) {
    finishAll(error: fail)
  }
}
