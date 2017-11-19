//
//  SkyPlugAdapter.swift
//  PowerAdapterConnector
//
//  Created by Ivan Brazhnikov on 18/11/2017.
//  Copyright © 2017 Go About. All rights reserved.
//

import Foundation
import CoreBluetooth

final class SkyPlugAdapter: NSObject {
  
  weak var delegate: SkyPlugAdapterDelegate?
  
  private var device: CBPeripheral?
  private var service: CBService? { didSet { Log.debug("Service: \(service as Any)") } }
  private var valueCharacteristic: CBCharacteristic? { didSet { Log.debug("Value Characteristic: \(valueCharacteristic as Any)") } }
  private var notifyCharacteristic: CBCharacteristic? { didSet { Log.debug("Notify Characteristic: \(notifyCharacteristic as Any)") } }
  
  fileprivate var isEnablingDevice: Bool = false
  fileprivate var isDisablingDevice: Bool = false
  fileprivate var isQueryingsState: Bool = false
  fileprivate var isAuthorizing: Bool = false

  private(set) var lastState: SkyPlugAdapterState?
  
  private let serviceUUID: CBUUID
  private let notifyCharacteristicUUID: CBUUID
  private let valueCharacteristicUUID: CBUUID
  
  private let onData: Data
  private let offData: Data
  private let queryData: Data
  private let authrorizationData: Data

  private var manager: CBCentralManager!
  
  init(serviceUUID: CBUUID,
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
    super.init()
    self.manager = CBCentralManager(delegate: self, queue: queue)
  }
  
  func connect() {
    self.enabled = true
  }
  
  func disconnect() {
    self.enabled = false
  }
  
  private(set) var enabled: Bool = false {
    didSet {
      if oldValue == enabled {
        return
      }
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
  }
  
  
  private func search() {
    guard manager.state == .poweredOn else {
      return
    }
    if let device = manager.retrieveConnectedPeripherals(withServices: [serviceUUID]).first {
      self.device = device
      device.delegate = self
    }
    if device == nil {
      manager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    } else {
      connectDevice()
    }
  }
  
  private func authorize() {
    isAuthorizing = true
    guard let device = device, let valueCharacteristic = valueCharacteristic else {
      return
    }
    device.writeValue(authrorizationData, for: valueCharacteristic, type: .withResponse)
  }
  
  private func subscribeOnUpdate() {
    if let device = self.device, let notifyCharacteristic = self.notifyCharacteristic {
      device.setNotifyValue(true, for: notifyCharacteristic)
    }
  }
  
  private func connectDevice() {
    guard let device = device else {
      Log.debug("No device")
      return
    }
    manager.connect(device, options: nil)
  }
  
  private func discoverDevice() {
    guard let device = device else {
      Log.debug("No device")
      return
    }
    device.discoverServices([serviceUUID])
  }
  
  
  final func turnOn() {
    send(bytes: onData) {
      isEnablingDevice = true
    }
  }
  
  final func turnOff() {
    send(bytes: offData) {
      isDisablingDevice = true
    }
  }
  
  final func queryState() {
    send(bytes: queryData) {
      isQueryingsState = true
    }
  }
  
  func send(bytes: Data, before: () -> Void) {
    guard let device = device, let valueCharacteristic = valueCharacteristic else {
      didFail(error: "No device")
      return
    }
    before()
    device.writeValue(bytes, for: valueCharacteristic, type: .withResponse)
  }
  
  func didReady() {
    delegate?.scannedDidReady(self)
  }
  
  func didFail(error: Error? = nil) {
    delegate?.scannedDidFailWithError(self, fail: error)
  }
  
  func didOff(error: Error?) {
    delegate?.scannedDidOff(self, error: error)
  }
  
  func didOn(error: Error?) {
    delegate?.scannedDidOn(self, error: error)
  }
  
  func didReadState(data: Data) {
    delegate?.scannedDidReadState(self, data: data)
  }
  
  func didDisconnect(error: Error?) {
    delegate?.scannedDidDisconnect(self, error: error)
  }
  
  func didFinishQuering(error: Error?) {
    delegate?.scannedDidFinishedQuery(self, error: error)
  }
  
}

extension SkyPlugAdapter: CBCentralManagerDelegate, CBPeripheralDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    Log.debug("centralManagerDidUpdateState: \(central.state)")
    if enabled {
      if central.state != .poweredOn {
        didFail(error: "Invalid adapter state \"\(central.state)\"")
      }
      search()
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    Log.debug((peripheral, advertisementData))
    manager.stopScan()
    device = peripheral
    peripheral.delegate = self
    connectDevice()
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    Log.debug("Connected")
    peripheral.delegate = self
    discoverDevice()
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    Log.debug(("Disconnected", error))
    device = nil
    peripheral.delegate = nil
    didDisconnect(error: error)
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    Log.debug(("Failed to conenct", error))
    if let error = error {
      didFail(error: error)
      return
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    Log.debug(("Services were discovered", error))
    if let error = error {
      didFail(error: error)
      return
    }
    guard let service = peripheral.services?.first (where: { $0.uuid == serviceUUID }) else {
      didFail(error: "No service")
      return
    }
    self.service = service
    Log.debug(service)
    peripheral.discoverCharacteristics([valueCharacteristicUUID, notifyCharacteristicUUID], for: service)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(("didUpdateValueForCharacteristic \(characteristic.uuid)", error))
    
    if let data = characteristic.value {
      Log.debug(("Received data: ", data.map { $0.hexString }))
    }
    
    if isAuthorizing {
      isAuthorizing = false
      if error == nil {
        didReady()
      } else {
        didFail(error: error)
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
      if let data = characteristic.value, data.count >= 12 {
        isQueryingsState = false
        let byte = data[11]
        if let state = SkyPlugAdapterState(rawValue: byte) {
          self.lastState = state
          didFinishQuering(error: error)
        } else {
          didFinishQuering(error: "Invalid format")
        }
      }
    }
    
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(("didUpdateValueForCharacteristic  \(characteristic.uuid)", error))
    if let error = error {
      didFail(error: error)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    Log.debug(("didDiscoverCharacteristics  \(service.uuid)", error))
    if let error = error {
      didFail(error: error)
      return
    }
    self.notifyCharacteristic = service.characteristics?.first { $0.uuid == notifyCharacteristicUUID }
    self.valueCharacteristic = service.characteristics?.first { $0.uuid == valueCharacteristicUUID }
    subscribeOnUpdate()
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    Log.debug(("didUpdateNotificationStateForCharacteristic \(characteristic.uuid)", error))
    if let error = error {
      didFail(error: error)
      return
    }
    Log.debug("Prepared!")
    authorize()
  }
}
