#!/bin/zsh

cd "$(dirname "$0")"

xcodebuild

echo "copying .."
rm -rf ~"/Library/Application Support/SIMBL/Plugins/Pyjector.bundle"
cp -a "build/Release/Pyjector.bundle" ~"/Library/Application Support/SIMBL/Plugins/"

# debugging:
# defaults write net.culater.SIMBL SIMBLLogLevel -int 0
# disable with ... -int 2
