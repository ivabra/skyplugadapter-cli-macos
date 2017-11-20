[![Swift version](https://img.shields.io/badge/Swift-4.0-orange.svg?style=for-the-badge)]()
[![iOS version](https://img.shields.io/badge/iOS-9.0-blue.svg?style=for-the-badge)]()
[![macOS version](https://img.shields.io/badge/macOS-10.0-lightgray.svg?style=for-the-badge)]()
[![watchOS version](https://img.shields.io/badge/watchOS-2.2-red.svg?style=for-the-badge)]()
[![tvOS version](https://img.shields.io/badge/tvOS-10.0-green.svg?style=for-the-badge)]()

# skyplugadapter-cli-macos
The console app for controlling a Redmond Sky Plug power socket for macOS (10.10 and above).

## Using
```sh
#!/bin/bash
./skyplug on # Turn on the socket. No output.

./skyplug off  # Turn off the socket. No output.

./skyplug query # Query a status of the socket. Output can be 'on', 'off' or 'unknown'
```
### Tracing
 Sometimes it can out an error
```sh
#!/bin/bash
./skyplug on
error: A device is not found within 5.0 seconds
```

Use `--debug` flag to get more output.
```
#!/bin/bash
./skyplug on --debug
2017-11-20 00:09:29.653802+0300 skyplug[48886:21256310] Got config file:
serviceUUID=6E400001-B5A3-F393-E0A9-E50E24DCCA9E
notifyCharacteristicUUID=6E400003-B5A3-F393-E0A9-E50E24DCCA9E
valueCharacteristicUUID=6E400002-B5A3-F393-E0A9-E50E24DCCA9E
onHexData=550103aa
offHexData=550204aa
queryHexData=550006aa
authorizationHexData=55aaffb54c75b1b40c88efaa
onStateName=on
offStateName=off
unknownStateName=unknown
searchTimeout=5

2017-11-20 00:09:29.668115+0300 skyplug[48886:21256363] CentralManager did update state: Powered on
2017-11-20 00:09:29.668344+0300 skyplug[48886:21256310] Checking connected devices...
2017-11-20 00:09:29.669117+0300 skyplug[48886:21256310] No connected devices. Begin scanning...
2017-11-20 00:09:34.669818+0300 skyplug[48886:21256363] Fail! -> Error: A device is not found within 5.0 seconds
Did disconnect
2017-11-20 00:09:34.671378+0300 skyplug[48886:21256310] Finished with errors -> Error: A device is not found within 5.0 seconds
error: A device is not found within 5.0 seconds
```
## Building
It requires to have installed XCode on your build machine.
Use the build script `build.sh`:
```sh
#!/bin/bash
cd path/to/project_dir
./build-cli.sh
```
After successful completion of script you can find the build at the `project_dir/build/Release` directory

## Configuration
The app uses the skyplugfile as a configuration file.
```
serviceUUID=6E400001-B5A3-F393-E0A9-E50E24DCCA9E
notifyCharacteristicUUID=6E400003-B5A3-F393-E0A9-E50E24DCCA9E
valueCharacteristicUUID=6E400002-B5A3-F393-E0A9-E50E24DCCA9E
onHexData=550103aa
offHexData=550204aa
queryHexData=550006aa
authorizationHexData=55aaffb54c75b1b40c88efaa
onStateName=on
offStateName=off
unknownStateName=unknown
searchTimeout=5
```
### Configuration keys
* `serviceUUID`: GATT service identifier.
* `notifyCharacteristicUUID`:  GATT notification characteristic identifier.
* `valueCharacteristicUUID`: GATT value characteristic identifier.
* `onHexData`: Bytes string in hex format that should be sended to **truning on** the socket.
* `offHexData`: Same as `onHexData` but for **turning off**.
* `queryHexData`: Same but for **requesting the status** of socket.
* `onStateName`: Overrides the default "on" output name of the `ON` socket status.
* `offStateName`: Overrides the default "off" output name of the `OFF` socket status.
* `unknownStateName`: Overrides the default "unknown" name of the state when the socket is not responding.
* `searchTimeout`: A optional paramenter for stopping the app if it can't find the lock within given duration.

By default, the app uses `skyplugfile` or `.skyplugfile` names for looking for configuration file in its directory.
You can override this by putting argument `--configfile /path/to/your/configfile`:
```sh
#!/bin/bash
./skyplug on --configfile /path/to/your/configfile
```
