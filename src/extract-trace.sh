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
    if [ $SPOOF -eq 1 ]; then
	kill $SMS_PID &>/dev/null
	kill $GEO_PID &>/dev/null
    fi
    exit 1
}

function get_app_pid {
    # This function will try to fetch app's PID for at most 15s
    RETRY_COUNT=60
    __APP_PID=
    for i in $(seq 1 $RETRY_COUNT); do
	# Fetch the app PID
	__APP_PID=`adb -P $ADB_SERVER_PORT shell "ps" | grep -v "USER " | grep $PROC_NAME | head -1 | awk -F" " '{print $2}'`
	if [ ! -z "$__APP_PID" ]; then
    	    break
	fi
    done
    eval "$1=$__APP_PID"
}

# Set traps
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

# App under test
#
# App file name
APK_FILE_NAME=$1
shift
# Package name
APP_NAME=$1
shift
# App process name
PROC_NAME=$1
shift
# Main app's activity name
ACTIVITY_NAME=$1
shift
# A shell script that will start the app and strace tool
SH_SCRIPT_IN_ANDROID=$1
shift

# Console port
CONSOLE_PORT=$1
shift

# ADB server port
ADB_SERVER_PORT=$1
shift

# ADB port
ADB_PORT=$1
shift

# Get the current time
TIMESTAMP=$1
shift

# Directory where Android log files should be stored
LOG_DIR=$1
shift

# Main loop counter from maline.sh
COUNTER=$1
shift

# Number of events that should be sent to each app
EVENT_NUM=$1
shift

# A flag indicating whether we should spoof text messages and location
# updates
SPOOF=$1
shift

# Log file names
LOGFILE="$COUNTER-$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"
LOGCATFILE="$COUNTER-$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.logcat"

MONKEY_SEED=42

# Start the app and start tracing its system calls
echo "About to start the app with the following command:"
echo "  am start -n ${APP_NAME}/${ACTIVITY_NAME}"
echo "The main app process name is: $PROC_NAME"
echo "Starting the app and strace... "
adb -P $ADB_SERVER_PORT shell $SH_SCRIPT_IN_ANDROID &>/dev/null &

# Fetch app's PID
get_app_pid APP_PID

# Get the PID of the strace instance
STRACE_PID=`adb -P $ADB_SERVER_PORT shell "ps -C strace" | grep -v "USER " | awk -F" " '{print $2}'`

if [ $SPOOF -eq 1 ]; then
    echo "Also sending geo-location updates in parallel..."
    LOCATIONS_FILE="$MALINE/data/locations-list"
    GEO_COUNT=$(cat $LOCATIONS_FILE | wc -l)
    send-locations.sh $LOCATIONS_FILE 0 $GEO_COUNT $CONSOLE_PORT &
    GEO_PID=$!
    echo "Spoofing SMS text messages in paralell too..."
    MESSAGES_FILE="$MALINE/data/sms-list"
    send-all-sms.sh $MESSAGES_FILE $CONSOLE_PORT &
    SMS_PID=$!
fi

COUNT_PER_ITER=100
ITERATIONS=$(($EVENT_NUM/$COUNT_PER_ITER))

echo "Testing the app..."
echo "There will be up to $ITERATIONS iteration(s), each sending $COUNT_PER_ITER random events to the app"

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

    # Send $COUNT_PER_ITER random events to the app with Monkey, with
    # a delay between consecutive events because the Android emulator
    # is slow
    echo "Iteration $i, sending $COUNT_PER_ITER random events to the app..."
    timeout 45 adb -P $ADB_SERVER_PORT shell "monkey --throttle 100 -p $APP_NAME -s $MONKEY_SEED $COUNT_PER_ITER 2>&1 | grep -v $WARNING_MSG_PART"
    # increase the seed for the next round of events
    let MONKEY_SEED=MONKEY_SEED+1
done

if [ $SPOOF -eq 1 ]; then
    kill $SMS_PID &>/dev/null
    kill $GEO_PID &>/dev/null
fi

check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

adb -P $ADB_SERVER_PORT shell "kill $STRACE_PID" &>/dev/null

# Pull the logfile to the host machine
echo -n "Pulling the app system calls log file... "
mkdir -p $LOG_DIR

DEFAULT_EVENT_NUM=1000
TIME_OUT=$(echo "60 + 420 * $EVENT_NUM / $DEFAULT_EVENT_NUM" | bc)
timeout $TIME_OUT adb -P $ADB_SERVER_PORT pull /sdcard/$LOGFILE $LOG_DIR &>/dev/null && echo "done" || echo "failed"

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
