//
//  SkyPlugAdapter.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation
import CoreBluetooth

public final class SkyPlugAdapter: NSObject {
  
  public weak var delegate: SkyPlugAdapterDelegate?
  
  // MARK: Public constants
  
  let serviceUUID: CBUUID
  let notifyCharacteristicUUID: CBUUID
  let valueCharacteristicUUID: CBUUID
  
  // MARK: Public properties
  
  public var onData: Data
  public var offData: Data
  public var queryData: Data
  public var authrorizationData: Data
  public var searchTimeout: TimeInterval?
  
 
  // MARK: Private properties
  
  private var device: CBPeripheral? { didSet { Log.debug("Device: \(device?.description ?? "nil")") } }
  private var service: CBService? { didSet { Log.debug("Service: \(service?.description ?? "nil")") } }
  private var valueCharacteristic: CBCharacteristic? { didSet { Log.debug("Value Characteristic: \(valueCharacteristic?.description ?? "nil")") } }
  private var notifyCharacteristic: CBCharacteristic? { didSet { Log.debug("Notify Characteristic: \(notifyCharacteristic?.description ?? "nil")") } }
  
  // MARK: Private flags
  
  private var isEnablingDevice: Bool = false
  private var isDisablingDevice: Bool = false
  private var isQueryingsState: Bool = false
  private var isAuthorizing: Bool = false
  

  private(set) var lastReceivedState: SkyPlugAdapterState?
 
  var deviceName: String? {
    return device?.name
  }

  private var manager: CBCentralManager!
  
  private(set) var enabled: Bool = false {
    didSet {
      if oldValue == enabled {
        return
      }
      invalidateEnabledState()
    }
  }
  
  private let queue: DispatchQueue
  
  public init(serviceUUID: CBUUID,
       notifyCharacteristicUUID: CBUUID,
       valueCharacteristicUUID: CBUUID,
       onData: Data,
       offData: Data,
       queryData: Data,
       authorizationData: Data,
       queue: DispatchQueue = .global()
       ) {
    self.serviceUUID = serviceUUID
    self.notifyCharacteristicUUID = notifyCharacteristicUUID
    self.valueCharacteristicUUID = valueCharacteristicUUID
    self.authrorizationData = authorizationData
    self.onData = onData
    self.offData = offData
    self.queryData = queryData
    self.queue = queue
    super.init()
    self.manager = CBCentralManager(delegate: self, queue: queue)
  }
 
  
}

// MARK: Public symbols
extension SkyPlugAdapter {
  
  public func connect() {
    self.enabled = true
  }
  
  public func disconnect() {
    self.enabled = false
  }
  
  public final func turnOn() {
    send(bytes: onData) {
      isEnablingDevice = true
    }
  }
  
  public final func turnOff() {
    send(bytes: offData) {
      isDisablingDevice = true
    }
  }
  
  public final func queryState() {
    send(bytes: queryData) {
      isQueryingsState = true
    }
  }
  
}

// MARK: Private symbols
private extension SkyPlugAdapter {

  private func invalidateEnabledState() {
    if enabled {
      search()
    } else {
      if let device = device {
        manager.cancelPeripheralConnection(device)
      } else {
        didDisconnect(error: nil)
      }
    }
  }
  
  private func search() {
    guard manager.state == .poweredOn else {
      return
    }
    Log.debug("Checking connected devices...")
    if let device = manager.retrieveConnectedPeripherals(withServices: [serviceUUID]).first {
      Log.debug("Found one connected device!")
      self.device = device
      device.delegate = self
    }
    if device == nil {
      Log.debug("No connected devices. Begin scanning...")
      manager.scanForPeripherals(withServices: [serviceUUID], options: nil)
      if let timeout = searchTimeout {
        watchDeviceSearchTimeout(timeout)
      }
    } else {
      Log.debug("Device was found. Connecting to them")
      connectDevice()
    }
  }
  
  private func watchDeviceSearchTimeout(_ duration: TimeInterval) {
    queue.asyncAfter(deadline: .now() + duration) { [weak self] in
      guard let `self` = self else { return }
      if self.device == nil {
        self.didFail(cause:  "A device is not found within \(duration) seconds")
      }
    }
  }
  
  private func authorize() {
    Log.debug("Authorizing your device on the remote device...")
    havingDeviceOrFail { device in
      guard let valueCharacteristic = valueCharacteristic else {
        didFail(cause: "No value characteristic")
        return
      }
      isAuthorizing = true
      device.writeValue(authrorizationData, for: valueCharacteristic, type: .withResponse)
    }
  }
  
  private func subscribeOnUpdate() {
    Log.debug("Subscribing on update characteristic")
    havingDeviceOrFail { device in
      guard let notifyCharacteristic = self.notifyCharacteristic else {
        didFail(cause: "No notify characteristic")
        return
      }
      device.setNotifyValue(true, for: notifyCharacteristic)
    }
  }
  
  private func connectDevice() {
    Log.debug("Connecting device...")
    havingDeviceOrFail { device in
      manager.connect(device, options: nil)
    }
  }
  
  private func discoverDevice() {
    Log.debug("Discovering device services...")
    havingDeviceOrFail {  device in
      device.discoverServices([serviceUUID])
    }
  }
  
  private func send(bytes: Data, before: () -> Void) {
    Log.debug("Sending bytes: \(bytes.map { $0.hexString }) to device")
    havingDeviceOrFail { device in
      guard let valueCharacteristic = valueCharacteristic else {
        didFail(cause: "No value characteristic")
        return
      }
      before()
      device.writeValue(bytes, for: valueCharacteristic, type: .withResponse)
    }
  }
  
  private func havingDeviceOrFail(whenHasDevice: (CBPeripheral)->Void) {
    guard let device = device else {
      didFail(cause: "No device")
      return
    }
    whenHasDevice(device)
  }
}

extension SkyPlugAdapter {
  
  private func didReady() {
    Log.debug("Did ready to interact with remote device!")
    delegate?.scannedDidReady(self)
  }
  
  private func didFail(error: Error) {
    Log.debug(error, "Fail!")
    delegate?.scannedDidFailWithError(self, fail: error)
  }
  
  private func didFail(cause: String) {
    let error = SkyPlugAdapterError(description: cause)
    didFail(error: error)
  }
  
  private func didOff(error: Error?) {
    Log.debug(error, "Did finished \"OFF\" operation.")
    delegate?.scannedDidOff(self, error: error)
  }
  
  private func didOn(error: Error?) {
     Log.debug(error, "Did finished \"ON\" operation.")
    delegate?.scannedDidOn(self, error: error)
  }
  
  private func didDisconnect(error: Error?) {
    Log.debug(error, "Did disconnect")
    delegate?.scannedDidDisconnect(self, error: error)
  }
  
  private func didFinishQueringDeviceState(error: Error?) {
    Log.debug(error, "Did finish querying device state")
    delegate?.scannedDidFinishQueryDeviceState(self, error: error)
  }
  
  private func didHandleNotifyCharacteristicValueUpdate(_ value: Data?, error: Error?) {
    Log.debug(error, "Did handle update of the notify characteristic: \(value?.map { $0.hexString }.description ?? "nil")")
    
    if isAuthorizing {
      isAuthorizing = false
      if let error = error {
        didFail(error: error)
      } else {
        didReady()
      }
    }
    
    if isEnablingDevice {
      isEnablingDevice = false
      didOn(error: error)
    }
    
    if isDisablingDevice {
      isDisablingDevice = false
      didOff(error: error)
    }
    
    if isQueryingsState {
      if let data = value, data.count >= 12 {
        isQueryingsState = false
        let byte = data[11]
        if let state = SkyPlugAdapterState(rawValue: byte) {
          self.lastReceivedState = state
          didFinishQueringDeviceState(error: error)
        } else {
          didFinishQueringDeviceState(error: SkyPlugAdapterError(description: "Invalid bytes format"))
        }
      }
    }
    
  }
}

// MARK: CBCentralManagerDelegate

extension SkyPlugAdapter: CBCentralManagerDelegate {
  
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    Log.debug("CentralManager did update state: \(central.state)")
    if enabled {
      if central.state != .poweredOn {
        didFail(cause: "Invalid adapter state \"\(central.state)\"")
      }
      search()
    }
  }
  
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    Log.debug(("Central manager did disconver peripheral", peripheral, advertisementData))
    manager.stopScan()
    device = peripheral
    peripheral.delegate = self
    connectDevice()
  }
  
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    Log.debug("Central manager did connect peripheral \(peripheral)")
    peripheral.delegate = self
    discoverDevice()
  }
  
  public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    Log.debug(error, "Central manager did disconnect peripheral \(peripheral)")
    device = nil
    peripheral.delegate = nil
    didDisconnect(error: error)
  }
  
  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    Log.debug(error, "Central manager did fail to connect peripheral \(peripheral)")
    if let error = error {
      didFail(error: error)
      return
    }
  }
}

// MARK: CBPeripheralDelegate

extension SkyPlugAdapter : CBPeripheralDelegate {
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    Log.debug(error, "Peripheral did disconver services \(peripheral.services?.description ?? "nil")")
    if let error = error {
      didFail(error: error)
      return
    }
    guard let service = peripheral.services?.first (where: { $0.uuid == serviceUUID }) else {
      didFail(cause: "No service")
      return
    }
    self.service = service
    peripheral.discoverCharacteristics([valueCharacteristicUUID, notifyCharacteristicUUID], for: service)
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(error, "Peripheral \(peripheral.nameOrUUID)"
      + "did update value for characteristic \(characteristic.uuid), "
      + "value: \(characteristic.value?.map { $0.hexString }.description ?? "nil")")
    
    if characteristic.uuid == notifyCharacteristicUUID {
      didHandleNotifyCharacteristicValueUpdate(characteristic.value, error: error)
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(error, "Peripheral \(peripheral.nameOrUUID) did write value for characteristic  \(characteristic.uuid)")
    if let error = error {
      didFail(error: error)
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    Log.debug(error, "Peripheral \(peripheral.nameOrUUID) did discover characteristics \(service.characteristics?.description ?? "nil") of service \(service.uuid)")
    if let error = error {
      didFail(error: error)
      return
    }
    self.notifyCharacteristic = service.characteristics?.first { $0.uuid == notifyCharacteristicUUID }
    self.valueCharacteristic = service.characteristics?.first { $0.uuid == valueCharacteristicUUID }
    subscribeOnUpdate()
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(error, "Peripheral \(peripheral.nameOrUUID) did update notification state for characteristic \(characteristic.uuid)")
    if let error = error {
      didFail(error: error)
      return
    }
    authorize()
  }
}
