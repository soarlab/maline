#!/bin/bash

# Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
#
# This file is part of maline.
#
# maline is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# maline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with maline.  If not, see <http://www.gnu.org/licenses/>.


# This script takes an AVD name and architecture and as a result
# creates an image in the given architecture, loads the respective
# emulator, waits for it to get ready, and then saves a snapshot.

set -e

source $MALINE/lib/maline.lib
CURR_PID=$$

# before taking a snapshot, check how Jenkins makes sure the screen is
# unlocked and that there is a SIM card in the device

# The Android version/API we tested our tool against
ANDROID_API="android-19"

# Constant snapshot name
SNAPSHOT_NAME="maline"

# Script name
SCRIPTNAME=`basename $0`

while getopts "a:d:" OPTION; do
    case $OPTION in
	a)
	    ARCH="$OPTARG";;
	d)
	    AVD_NAME="$OPTARG";;
    esac
done

usage() {
    echo "usage: $0 -a <architecture> -d <avd-name>"
    echo "  -a <architecture>  Architecture can be x86 or armeabi-v7a"
    echo "  -d <avd-name>      AVD name can be any string without spaces"
}

check_and_exit() {
    if [ -z "$2" ]; then
	usage
	exit 1
    fi
}

# Check if all parameters are provided
check_and_exit "-a" $ARCH
check_and_exit "-d" $AVD_NAME

# Check if the -a parameter is valid
if [ $ARCH != "x86" ] && [ $ARCH != "armeabi-v7a" ]; then
    usage
    exit 1
fi

# Create an Android Virtual Device
# Say no to a question about a custom hardware profile
echo no | android create avd --force -a --sdcard 512M --skin WVGA800 --name $AVD_NAME --target $ANDROID_API --abi $ARCH

available_port CONSOLE_PORT
available_port ADB_PORT
available_port ADB_SERVER_PORT

rm -f $MALINE/.avd-create-$CURR_PID
echo "Console port: ${CONSOLE_PORT}" >> $MALINE/.avd-create-$CURR_PID
echo "ADB port: ${ADB_PORT}" >> $MALINE/.avd-create-$CURR_PID
echo "ADB server port: ${ADB_SERVER_PORT}" >> $MALINE/.avd-create-$CURR_PID

# Start emulator
echo "$SCRIPTNAME: Starting emulator ..."
BOOT_START=`date +"%s"`
emulator -no-boot-anim -ports $CONSOLE_PORT,$ADB_PORT -prop persist.sys.dalvik.vm.lib.1=libdvm.so -prop persist.sys.language=en -prop persist.sys.country=US -avd $AVD_NAME -no-snapshot-load -no-snapshot-save -wipe-data -no-window &
EMULATOR_PID=$!

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

BOOT_END=`date +"%s"`
BOOT_TIME=`expr $BOOT_END - $BOOT_START`

echo "Emulator boot time: $BOOT_TIME s"

# Make sure the screen is unlocked by pressing the Menu and the Back
# keys. For explanation, check AndroidEmulator.java:406 of the
# Jenkins' Android Emulator Plugin

# Wait some more time to make sure the system is ready to accept key
# inputs
echo "Giving the emulator some more time before unclocking the screen..."
sleep `echo "$BOOT_TIME * 0.25" | bc`

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

adb -P $ADB_SERVER_PORT -s localhost:$ADB_PORT shell input keyevent 82 # Menu key
adb -P $ADB_SERVER_PORT -s localhost:$ADB_PORT shell input keyevent 4  # Back key

# Wait a bit longer to make sure the system is ready
echo "Giving the emulator some more time before taking a snapshot..."
sleep `echo "$BOOT_TIME * 0.8" | bc`

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

# Clear the main log before creating a snapshot
echo "Clearing the main log before creating a snapshot..."
adb -P $ADB_SERVER_PORT -s localhost:$ADB_PORT logcat -c 2>&1 > /dev/null

# Write into log that we're about to take a snapshot
adb -P $ADB_SERVER_PORT -s localhost:$ADB_PORT shell log -p v -t maline 'Creating snapshot...'

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

# Kill adb; otherwise the image won't be usable
adb -P $ADB_SERVER_PORT kill-server

# Pause the AVD and take a snapshot
avd-save-snapshot $CONSOLE_PORT $SNAPSHOT_NAME
echo ""

# kill the adb server
adb -P $ADB_SERVER_PORT kill-server

# kill the emulator
kill-emulator $CONSOLE_PORT
kill $EMULATOR_PID

# Remove a temporary file with a list of ports used
rm $MALINE/.avd-create-$CURR_PID

echo ""
echo "Android virtual device ${AVD_NAME} created successfully"

exit 0
