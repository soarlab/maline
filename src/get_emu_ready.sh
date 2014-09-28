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


ADB_PORT="$1"
ADB_SERVER_PORT="$2"
SH_SCRIPT="$3"
SH_SCRIPT_IN_ANDROID="$4"

STATUS_FILE=$MALINE/.emulator-$ADB_PORT

# Clean up upon exiting from the process
function __sig_func {
    kill $ADB_PID &>/dev/null
    adb -P $ADB_SERVER_PORT kill-server &>/dev/null
    exit 1
}

die() {
    echo >&2 "$@"
    exit 1
}

function wait_for_emu {
    COUNTER=0
    COUNTER_LIMIT=2

    EMU_READY=0
    echo "0" > $STATUS_FILE

    echo -n "Waiting for the device: "

    CURR_TIME=$((`date +"%s"`))
    TIME_TIMEOUT=$(($CURR_TIME + $EMU_TIMEOUT))

    while [ "$EMU_READY" != "1" ] && [ "$CURR_TIME" -lt "$TIME_TIMEOUT" ]; do
	echo -n "."
	sleep 3s
	
	if [ $COUNTER -eq $COUNTER_LIMIT ]; then
	    let COUNTER=0
	    adb -P $ADB_SERVER_PORT -e disconnect localhost:$ADB_PORT &>/dev/null 
	    adb -P $ADB_SERVER_PORT kill-server &>/dev/null
	    adb -P $ADB_SERVER_PORT start-server &>/dev/null &
	    ADB_PID=$!
	fi
	
	adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null
	
	EMU_READY=`timeout 5 adb -P $ADB_SERVER_PORT -e -s localhost:$ADB_PORT shell getprop dev.bootcomplete 2>&1`
	EMU_READY=${EMU_READY:0:1}
	
	let COUNTER=COUNTER+1
	CURR_TIME=$((`date +"%s"`))
    done

    if [ "$EMU_READY" = "1" ]; then
	echo " ready"
	echo "1" > $STATUS_FILE
    else
	echo " failed"
    fi
}

# Set traps
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

# Kill the adb server
adb -P $ADB_SERVER_PORT kill-server &>/dev/null
ADB_PID=`ps -ef | grep "adb -P $ADB_SERVER_PORT" | head -1 | awk -F" " '{print $2}' | tr "\n" " "`
kill $ADB_PID &>/dev/null

# Start an adb server
adb -P $ADB_SERVER_PORT start-server &>/dev/null &
ADB_PID=$!

# TODO: Change this parameter if ARM is ever to be supported again or
# if running on a slower machine
EMU_TIMEOUT=180

# Wait for the device
wait_for_emu
if [ "`cat $STATUS_FILE 2>/dev/null`" != "1" ]; then
    exit 0
fi

# Push a patched version of Monkey to the device. We need to do this
# because we are using a prebuilt image of x86, which doesn't come
# with the patched version of Monkey. Do the same with a tiny shell
# script that starts the app and traces its system calls.
JAR="$ANDROID_SDK_ROOT/monkey/monkey.jar"
ODEX="$ANDROID_SDK_ROOT/monkey/monkey.odex"
[ -f $JAR ] || die "$JAR file does not exist. Use a custom build of Android SDK pointed to in the documentation."
[ -f $ODEX ] || die "$ODEX file does not exist. Use a custom build of Android SDK pointed to in the documentation."

echo -n "Pushing a patched version of Monkey... "
let COUNTER=0
OK=0
while [ $OK -eq 0 ] && [ "$COUNTER" -lt 3 ]; do
    OK=1
    adb -P $ADB_SERVER_PORT shell mount -o rw,remount /system &>/dev/null || OK=0
    sleep 1
    adb -P $ADB_SERVER_PORT push $JAR /system/framework &>/dev/null || OK=0
    adb -P $ADB_SERVER_PORT push $ODEX /system/framework &>/dev/null || OK=0
    adb -P $ADB_SERVER_PORT push $SH_SCRIPT $SH_SCRIPT_IN_ANDROID &>/dev/null || OK=0
    adb -P $ADB_SERVER_PORT shell chmod 6755 $SH_SCRIPT_IN_ANDROID &>/dev/null || OK=0
    sleep 1
    adb -P $ADB_SERVER_PORT shell mount -o ro,remount /system &>/dev/null || OK=0

    adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null || OK=0

    let COUNTER=COUNTER+1
done

if [ $OK -eq 1 ]; then
    echo "done"
else
    echo "failed"
    exit 1
fi
echo ""

exit 0
