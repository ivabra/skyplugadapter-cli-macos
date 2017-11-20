//: Playground - noun: a place where people can play

import Foundation
import SkyPlug
import PlaygroundSupport

func main() throws {
  let adapter = try SkyPlugAdapterMakeDefault()!
  adapter.searchTimeout = 3
  var deviceName: String? = ""
  defer {
    do {
      try adapter.disconnect()
    } catch {
      print(error)
    }
  }
  try adapter.connect()
  deviceName = adapter.deviceName
  try adapter.turnOn()
  try adapter.turnOff()
}
do {
  try main()
} catch {
  print(error)
}