#!/bin/bash

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
	    killall adb 2>&1 > /dev/null
	    adb -P $ADB_SERVER_PORT start-server
	fi
	
	echo "Connecting to the device ..."
	adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT
	
	echo "Checking if the device has booted ..."
	EMU_READY=`adb -P $ADB_SERVER_PORT -e -s localhost:$ADB_PORT shell getprop dev.bootcomplete 2>&1 & sleep 5; kill $!`
	EMU_READY=${EMU_READY:0:1}
	echo "EMU_READY: \"$EMU_READY\""
	
	let COUNTER=COUNTER+1
    done
}

# Kill adb server(s)
adb -P $ADB_SERVER_PORT kill-server
killall adb 2>&1 > /dev/null

# Start an adb server
adb -P $ADB_SERVER_PORT start-server

# Wait for the device
echo "Waiting for the device ..."
wait_for_emu

adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT
