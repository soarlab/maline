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

ADB_PID=

COUNTER_LIMIT=2

# Clean up upon exiting from the process
function __sig_func {
    kill $ADB_PID
    exit 1
}

wait_for_emu()
{
    EMU_READY="0"
    COUNTER=0

    date
    echo -n "Waiting for the device: "

    while [ "$EMU_READY" != "1" ]; do
	sleep 3s
	# date
	
	if [ $COUNTER -eq $COUNTER_LIMIT ]; then
	    let COUNTER=0
	   
	    # echo "Disconnecting from the device ..."
	    adb -P $ADB_SERVER_PORT -e disconnect localhost:$ADB_PORT &>/dev/null 

	    # echo "Killing and starting the adb server ..."
	    adb -P $ADB_SERVER_PORT kill-server &>/dev/null
	    # killall adb 2>&1 > /dev/null
	    # kill $ADB_PID 2>&1 > /dev/null

	    adb -P $ADB_SERVER_PORT start-server &>/dev/null &
	    ADB_PID=$!
	fi
	
	# echo "Connecting to the device ..."
	adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null
	# ADB_PID=$!
	# echo "adb pid: $ADB_PID"
	
	# echo "Checking if the device has booted ..."
	EMU_READY=`timeout 5 adb -P $ADB_SERVER_PORT -e -s localhost:$ADB_PORT shell getprop dev.bootcomplete 2>&1`
	EMU_READY=${EMU_READY:0:1}
	if [ "$EMU_READY" != "1" ]; then
	    echo -n "."
	fi
	# echo -n "$EMU_READY"

	let COUNTER=COUNTER+1
    done

    echo " ready"
    date
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

# Wait for the device
wait_for_emu

# Push the patched version of Monkey to the device. We need to do this
# because we are using a prebuilt image of x86, which doesn't come
# with the patched version of Monkey
JAR="$ANDROID_SDK_ROOT/monkey/monkey.jar"
ODEX="$ANDROID_SDK_ROOT/monkey/monkey.odex"
[ -f $JAR ] || die "$JAR file does not exist. Use a custom build of Android SDK pointed to in the documentation."
[ -f $ODEX ] || die "$ODEX file does not exist. Use a custom build of Android SDK pointed to in the documentation."
echo ""
echo -n "Pushing a patched version of Monkey... "
adb -P $ADB_SERVER_PORT shell mount -o rw,remount /system &>/dev/null || exit 1
sleep 1
adb -P $ADB_SERVER_PORT push $JAR /system/framework &>/dev/null || exit 1
adb -P $ADB_SERVER_PORT push $ODEX /system/framework &>/dev/null || exit 1
adb -P $ADB_SERVER_PORT shell mount -o ro,remount /system &>/dev/null || exit 1

adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null || exit 1

echo "done"

exit 0
