#!/bin/zsh

cd "$(dirname "$0")"

[ -x ../PyTerminal/install.sh ] && ../PyTerminal/install.sh

xcodebuild

echo "copying .."
D="/System/Library/Application Support/SIMBL/Plugins/"
sudo rm -rf "$D/Pyjector.bundle"
sudo cp -a "build/Release/Pyjector.bundle" "$D"

# debugging:
# defaults write net.culater.SIMBL SIMBLLogLevel -int 0
# disable with ... -int 2
