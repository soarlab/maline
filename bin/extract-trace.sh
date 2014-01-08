#!/bin/bash

# App under test
APP_NAME=`getAppPackageName.sh $1`

# Console port
CONSOLE_PORT="$2"

# ADB server port
ADB_SERVER_PORT="$3"

# Get the current time
TIMESTAMP="$4"

# Get apk file name
APK_FILE_NAME=`basename $1 .apk`

# Log file name
LOGFILE="$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"

cleanup()
{
    # Stop the send-locations.sh script if it's still running
    killall send-locations.sh
    # Stop the send-sms.sh script if it's still running
    killall send-sms.sh
}

# Send an event to the app to start it
echo "Starting the app ..."
adb -P $ADB_SERVER_PORT shell monkey -p $APP_NAME 1

# Give some time to the app to start
sleep 15s

# Fetch the app PID
APP_PID=`adb -P $ADB_SERVER_PORT shell "ps" | grep -v "USER " | grep $APP_NAME | head -1 | awk -F" " '{print $2}'`

echo "App's process ID: $APP_PID"

COUNT_PER_ITER=100
ITERATIONS=10

echo "Testing the app ..."
echo "There will be up to $ITERATIONS iterations, each sending $COUNT_PER_ITER random events to the app"

echo "Also sending geo-location updates in parallel ..."
LOCATIONS_FILE="$MALINE/data/locations-list"
send-locations.sh $LOCATIONS_FILE 0 `cat $LOCATIONS_FILE | wc -l` $CONSOLE_PORT &

echo "Spoofing SMS text messages in paralell too ..."
MESSAGES_FILE="$MALINE/data/sms-list"
send-all-sms.sh $MESSAGES_FILE $CONSOLE_PORT &

for (( i=0; i<$ITERATIONS; i++ )) do

    ACTIVE=`adb -P $ADB_SERVER_PORT shell "ps" | grep $APP_PID`
    # Check if the app is still running. If not, stop testing and stracing
    if [ -z "$ACTIVE" ]; then
	echo "App not running any more ..."
	echo "Stopping testing ..."
	cleanup
	break
    fi

    # Start tracing system calls the app makes
    STRACE_CMD="strace -ff -F -tt -T -p $APP_PID &>> /sdcard/$LOGFILE"
    adb -P $ADB_SERVER_PORT shell "$STRACE_CMD" &

    # Give some time to the emulator to start strace
    sleep 2s

    # Get the PID of the strace instance
    STRACE_PID=`adb -P $ADB_SERVER_PORT shell "ps -C strace" | grep -v "USER " | awk -F" " '{print $2}'`

    STRACE_KILL_CMD="kill $STRACE_PID"

    # Send $COUNT_PER_ITER random events to the app with Monkey, with
    # a delay between consecutive events because the Android emulator
    # is slow, and kill strace once Monkey is done
    echo "Iteration $i, sending $COUNT_PER_ITER random events to the app ..."
    timeout 45 adb -P $ADB_SERVER_PORT shell "monkey --throttle 100 -p $APP_NAME $COUNT_PER_ITER && $STRACE_KILL_CMD"

done

sleep 1s

# Pull the logfile to the host machine
mkdir -p log
adb -P $ADB_SERVER_PORT pull /sdcard/$LOGFILE $MALINE/log/

# Remove the logfile from the device
RM_CMD="rm /sdcard/$LOGFILE"

adb -P $ADB_SERVER_PORT shell "$RM_CMD" 

cleanup
