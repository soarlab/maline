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


# App under test
APP_NAME=`getAppPackageName.sh $1`

# Console port
CONSOLE_PORT="$2"

# ADB server port
ADB_SERVER_PORT="$3"

# Get the current time
TIMESTAMP="$4"

# Status file where send-sms.sh and send-locations.sh PID's should be
# written to
GPS_SMS_STATUS_FILE="$5"

# Get apk file name
APK_FILE_NAME=`basename $1 .apk`

# Log file names
LOGFILE="$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"
LOGCATFILE="$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.logcat"

MONKEY_SEED=42

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
GEO_PID=$!
echo -n "${GEO_PID} " > $GPS_SMS_STATUS_FILE

echo "Spoofing SMS text messages in paralell too ..."
MESSAGES_FILE="$MALINE/data/sms-list"
send-all-sms.sh $MESSAGES_FILE $CONSOLE_PORT &
SMS_PID=$!
echo -n "${SMS_PID}" >> $GPS_SMS_STATUS_FILE

for (( i=0; i<$ITERATIONS; i++ )) do

    ACTIVE=`adb -P $ADB_SERVER_PORT shell "ps" | grep $APP_PID`
    # Check if the app is still running. If not, stop testing and stracing
    if [ -z "$ACTIVE" ]; then
	echo "App not running any more ..."
	echo "Stopping testing ..."
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
    timeout 45 adb -P $ADB_SERVER_PORT shell "monkey --throttle 100 -p $APP_NAME -s $MONKEY_SEED $COUNT_PER_ITER && $STRACE_KILL_CMD"

done

sleep 1s

# Pull the logfile to the host machine
mkdir -p $MALINE/log
adb -P $ADB_SERVER_PORT pull /sdcard/$LOGFILE $MALINE/log/

# Remove the logfile from the device
RM_CMD="rm /sdcard/$LOGFILE"

adb -P $ADB_SERVER_PORT shell "$RM_CMD" 

# Fetch logcat log and remove it from the phone
adb -P $ADB_SERVER_PORT shell "logcat -d > /sdcard/$LOGCATFILE"
adb -P $ADB_SERVER_PORT pull /sdcard/$LOGCATFILE $MALINE/log/
RM_CAT_CMD="rm /sdcard/$LOGCATFILE"
adb -P $ADB_SERVER_PORT shell "$RM_CAT_CMD"
