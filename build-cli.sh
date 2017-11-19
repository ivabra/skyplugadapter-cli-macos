#!/bin/bash
xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project skyplug.xcodeproj -target skyplug -configuration Release -quiet