#!/bin/bash

rm -rf ../DerivedData
xcodebuild -workspace ../flips/flips.xcworkspace/ -scheme flips-cal -configuration Debug -sdk iphonesimulator
xcodebuild -workspace ../flips/flips.xcworkspace/ -scheme flips-cal -configuration Release -sdk iphonesimulator
