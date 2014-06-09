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

STATUS_FILE=$MALINE/.emulator-$ADB_PORT

# Clean up upon exiting from the process
function __sig_func {
    kill $ADB_PID &>/dev/null
    exit 1
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
export ADB_PID=$!

# TODO: Change this parameter if ARM is ever to be supported again or
# if running on a slower machine
EMU_TIMEOUT=180

# Wait for the device
timeout $EMU_TIMEOUT wait-for-emu.sh $ADB_PORT $ADB_SERVER_PORT
EXIT_STATUS=$?
# check if there was a timeout
if [ $EXIT_STATUS -eq 124 ]; then
    echo "There was a timeout for wait-for-emu.sh"
    exit 0
fi
# check if the user interrupted the execution
if [ $EXIT_STATUS -eq 1 ]; then
    echo "User interrupted wait-for-emu.sh"
    kill $ADB_PID &>/dev/null
    exit 1
fi
# Exit if the device is not ready
if [ "`cat $STATUS_FILE 2>/dev/null`" != "1" ]; then
    echo "wait-for-emu.sh terminated, but the device is not ready"
    exit 0
fi

# Push a patched version of Monkey to the device. We need to do this
# because we are using a prebuilt image of x86, which doesn't come
# with the patched version of Monkey
JAR="$ANDROID_SDK_ROOT/monkey/monkey.jar"
ODEX="$ANDROID_SDK_ROOT/monkey/monkey.odex"
[ -f $JAR ] || die "$JAR file does not exist. Use a custom build of Android SDK pointed to in the documentation."
[ -f $ODEX ] || die "$ODEX file does not exist. Use a custom build of Android SDK pointed to in the documentation."
echo -n "Pushing a patched version of Monkey... "
adb -P $ADB_SERVER_PORT shell mount -o rw,remount /system &>/dev/null || exit 1
sleep 1
adb -P $ADB_SERVER_PORT push $JAR /system/framework &>/dev/null || exit 1
adb -P $ADB_SERVER_PORT push $ODEX /system/framework &>/dev/null || exit 1
adb -P $ADB_SERVER_PORT shell mount -o ro,remount /system &>/dev/null || exit 1

adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null || exit 1

echo "done"
echo ""

exit 0
