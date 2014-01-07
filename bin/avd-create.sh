#!/bin/bash

# This script takes an AVD name and architecture and as a result
# creates an image in such architecture, loads the respective
# emulator, waits for it to get ready, and then saves a snapshot by
# running the following in telnet:

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

# TODO: remove these hard-coded port values and write a script that
# will randomly select such available ports
CONSOLE_PORT="55432"
ADB_PORT="55184"
ADB_SERVER_PORT="13234"

# Start emulator
echo "$SCRIPTNAME: Starting emulator ..."
BOOT_START=`date +"%s"`
emulator -no-boot-anim -ports $CONSOLE_PORT,$ADB_PORT -prop persist.sys.language=en -prop persist.sys.country=US -avd $AVD_NAME -no-snapshot-load -no-snapshot-save -wipe-data -no-window &

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
adb  -P $ADB_SERVER_PORT -s localhost:$ADB_PORT shell log -p v -t maline 'Creating snapshot...'

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

# Pause the AVD and take a snapshot
avd-save-snapshot $CONSOLE_PORT $SNAPSHOT_NAME
echo ""

# kill the emulator
kill-emulator $CONSOLE_PORT

echo ""
