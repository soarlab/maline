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

while getopts "a:i:" OPTION; do
    case $OPTION in
	a)
	    ARCH="$OPTARG";;
	i)
	    IMAGE_NAME="$OPTARG";;
    esac
done

usage() {
    echo "usage: $0 -a <architecture> -i <image-name>"
    echo "  -a <architecture>  Architecture can be x86 or armeabi-v7a"
    echo "  -i <image-name>    Image name can be any string without spaces"
}

check_and_exit() {
    if [ -z "$2" ]; then
	usage
	exit 1
    fi
}

# Check if all parameters are provided
check_and_exit "-a" $ARCH
check_and_exit "-i" $IMAGE_NAME

# Check if the -a parameter is valid
if [ $ARCH != "x86" ] && [ $ARCH != "armeabi-v7a" ]; then
    usage
    exit 1
fi

# Create an Android Virtual Device
# Say no to a question about a custom hardware profile
echo no | android create avd --force -a --sdcard 512M --skin WVGA800 --name $IMAGE_NAME --target $ANDROID_API --abi $ARCH

# TODO: remove these hard-coded port values and write a script that
# will randomly select such available ports
CONSOLE_PORT="55432"
ADB_PORT="55184"
ADB_SERVER_PORT="13234"

# Start emulator
echo "$SCRIPTNAME: Starting emulator ..."
emulator -no-boot-anim -ports $CONSOLE_PORT,$ADB_PORT -prop persist.sys.language=en -prop persist.sys.country=US -avd $IMAGE_NAME -no-snapshot-load -no-snapshot-save -wipe-data -netfast -no-window &

# Wait for the emulator
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

# Pause the emulator and take a snapshot
avd-save-snapshot $CONSOLE_PORT $SNAPSHOT_NAME

# kill the emulator
kill-emulator $CONSOLE_PORT

echo ""
