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


# Clean up upon exiting from the process
function __sig_func {
    kill $SMS_PID &>/dev/null
    kill $GEO_PID &>/dev/null
    exit 1
}

function get_app_pid {
    # This function will try to fetch app's PID for at most 15s
    RETRY_COUNT=60
    __APP_PID=
    for i in $(seq 1 $RETRY_COUNT); do
	# Fetch the app PID
	__APP_PID=`adb -P $ADB_SERVER_PORT shell "ps" | grep -v "USER " | grep $APP_NAME | head -1 | awk -F" " '{print $2}'`
	if [ ! -z "$__APP_PID" ]; then
    	    break
	fi
	sleep 0.25s
    done
    eval "$1=$__APP_PID"
}

# Set traps
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

# App under test
APP_NAME=`getAppPackageName.sh $1`

# Console port
CONSOLE_PORT="$2"

# ADB server port
ADB_SERVER_PORT="$3"

# ADB port
ADB_PORT="$4"

# Get the current time
TIMESTAMP="$5"

# Directory where Android log files should be stored
LOG_DIR="$6"

# get apk file name
APK_FILE_NAME=`basename $1 .apk`

# Log file names
LOGFILE="$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"
LOGCATFILE="$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.logcat"

MONKEY_SEED=42

# Send an event to the app to start it
echo "Starting the app... "
adb -P $ADB_SERVER_PORT shell monkey -p $APP_NAME 1 &>/dev/null

# Fetch app's PID
get_app_pid APP_PID

COUNT_PER_ITER=100
ITERATIONS=10

echo "Testing the app..."
echo "There will be up to $ITERATIONS iterations, each sending $COUNT_PER_ITER random events to the app"

echo "Also sending geo-location updates in parallel..."
LOCATIONS_FILE="$MALINE/data/locations-list"
GEO_COUNT=$(cat $LOCATIONS_FILE | wc -l)
send-locations.sh $LOCATIONS_FILE 0 $GEO_COUNT $CONSOLE_PORT &
GEO_PID=$!

echo "Spoofing SMS text messages in paralell too..."
MESSAGES_FILE="$MALINE/data/sms-list"
send-all-sms.sh $MESSAGES_FILE $CONSOLE_PORT &
SMS_PID=$!

# WARNING: linker: libdvm.so has text relocations. This is wasting memory and is a security risk. Please fix.
WARNING_MSG_PART="Please"

for i in $(seq 1 $ITERATIONS); do
    # Check if the user has interrupted the execution in the meantime
    check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

    ACTIVE=`adb -P $ADB_SERVER_PORT shell "ps" | grep $APP_PID`
    # Check if the app is still running. If not, stop testing and stracing
    if [ -z "$ACTIVE" ]; then
	echo "App not running any more. Stopping testing... "
	break
    fi
    
    # Check if the user has interrupted the execution in the meantime
    check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

    # Start tracing system calls the app makes
    STRACE_CMD="strace -ff -F -tt -T -p $APP_PID &>> /sdcard/$LOGFILE"
    adb -P $ADB_SERVER_PORT shell "$STRACE_CMD" &

    # Give some time to the emulator to start strace
    sleep 2s

    # Get the PID of the strace instance
    STRACE_PID=`adb -P $ADB_SERVER_PORT shell "ps -C strace" | grep -v "USER " | awk -F" " '{print $2}'`

    STRACE_KILL_CMD="kill $STRACE_PID"

    # Check if the user has interrupted the execution in the meantime
    check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

    # Send $COUNT_PER_ITER random events to the app with Monkey, with
    # a delay between consecutive events because the Android emulator
    # is slow, and kill strace once Monkey is done
    echo "Iteration $i, sending $COUNT_PER_ITER random events to the app..."
    timeout 45 adb -P $ADB_SERVER_PORT shell "monkey --throttle 100 -p $APP_NAME -s $MONKEY_SEED $COUNT_PER_ITER 2>&1 | grep -v $WARNING_MSG_PART && $STRACE_KILL_CMD"
    # increase the seed for the next round of events
    let MONKEY_SEED=MONKEY_SEED+1
done

kill $SMS_PID &>/dev/null
kill $GEO_PID &>/dev/null

check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

sleep 1s

# Pull the logfile to the host machine
echo -n "Pulling the app system calls log file... "
mkdir -p $LOG_DIR
timeout 300 adb -P $ADB_SERVER_PORT pull /sdcard/$LOGFILE $LOG_DIR &>/dev/null && echo "done" || echo "failed"

# Remove the logfile from the device
RM_CMD="rm /sdcard/$LOGFILE"

adb -P $ADB_SERVER_PORT shell "$RM_CMD" 

# Fetch logcat log and remove it from the phone
echo -n "Pulling the app execution logcat file... "
adb -P $ADB_SERVER_PORT shell "logcat -d > /sdcard/$LOGCATFILE 2>/dev/null" && \
adb -P $ADB_SERVER_PORT pull /sdcard/$LOGCATFILE $LOG_DIR &>/dev/null && echo "done" || echo "failed"
RM_CAT_CMD="rm /sdcard/$LOGCATFILE"
adb -P $ADB_SERVER_PORT shell "$RM_CAT_CMD"

exit 0
