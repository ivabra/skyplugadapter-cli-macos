# skyplugadapter-cli-macos
The console app for controlling a Redmond Sky Plug power socket for macOS (10.10 and above).

## Using
```sh
#!/bin/bash
# Turn on the socket
./skyplug on 

# Turn off the socket
./skyplug off 

# Query a status of the socket
./skyplug query 
on # can be 'on', 'off' or 'unknown'
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
2017-11-19 06:59:06.667 -> Got config file:
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

2017-11-19 06:59:06.679 -> CentralManager did update state: Powered on
2017-11-19 06:59:06.680 -> Checking connected devices...
2017-11-19 06:59:06.681 -> No connected devices. Begin scanning...
2017-11-19 06:59:11.681 -> Fail! -> Error: A device is not found within 5.0 seconds
2017-11-19 06:59:11.682 -> Did disconnect
2017-11-19 06:59:11.682 -> Finished with errors -> Error: A device is not found within 5.0 seconds
error: A device is not found within 5.0 seconds
```
## Build
It requires to have installed XCode on your build machine.
Use the build script `build.sh`:
```sh
#!/bin/bash
cd path/to/project_dir
./build.sh
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
* `serviceUUID`: GATT service identifier
* `notifyCharacteristicUUID`:  GATT notification characteristic identifier;
* `valueCharacteristicUUID`: GATT value characteristic identifier;
* `onHexData`: Bytes string in hex format that should be sended for **truninig on** the socket;
* `offHexData`: Same as for `onHexData` but for **trunning off**;
* `queryHexData`: Same but just for *requesting the status* of socket;
* `onStateName`: Overrides the default "on" name of the `ON` socket status;
* `offStateName`: Overrides the default "off" name of the `OFF` socket status;
* `unknownStateName`: Overrides the default "unknown" name of the state when the socket is not responding.
* `searchTimeout`: A optional paramenter for stopping the app if it can't find the lock within given duration.

By default, the app uses `skyplugfile` or `.skyplugfile` names for looking for configuration file in its directory.
You can override this by putting argument `--configfile /path/to/your/configfile`:
```sh
#!/bin/bash
./skyplug on --configfile /path/to/your/configfile
```
