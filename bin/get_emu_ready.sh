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

wait_for_emu()
{
    EMU_READY="0"
    COUNTER=0

    while [ "$EMU_READY" != "1" ]; do
	sleep 5s
	date
	
	if [ $COUNTER -eq 3 ]; then
	    let COUNTER=0

	    echo "Disconnecting from the device ..."
	    adb -P $ADB_SERVER_PORT -e disconnect localhost:$ADB_PORT

	    echo "Killing and starting the adb server ..."
	    adb -P $ADB_SERVER_PORT kill-server
	    # killall adb 2>&1 > /dev/null
	    kill $ADB_PID 2>&1 > /dev/null

	    adb -P $ADB_SERVER_PORT start-server
	    ADB_PID=$!
	fi
	
	echo "Connecting to the device ..."
	adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT
	
	echo "Checking if the device has booted ..."
	EMU_READY=`timeout 5 adb -P $ADB_SERVER_PORT -e -s localhost:$ADB_PORT shell getprop dev.bootcomplete 2>&1`
	EMU_READY=${EMU_READY:0:1}
	echo "EMU_READY: \"$EMU_READY\""

	let COUNTER=COUNTER+1
    done
}

# Kill the adb server
adb -P $ADB_SERVER_PORT kill-server
ADB_PID=`ps -ef | grep "adb -P $ADB_SERVER_PORT" | head -1 | awk -F" " '{print $2}'`
kill $ADB_PID 2>&1 > /dev/null

# Start an adb server
adb -P $ADB_SERVER_PORT start-server
ADB_PID=$!

# Wait for the device
echo "Waiting for the device ..."
wait_for_emu

adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT

exit 0
