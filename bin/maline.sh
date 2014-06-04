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


# This script boots a clean snapshot in a headless emulator with ports
# specified by parameters -c and -b for the console and adb bridge,
# respectively. An adb server uses a port specified by the -s
# parameter. All the port parameters are optional. A list of paths to
# Android apps - one path per line - is specified in a file given with
# the -f parameter. If -e is not specified, the script will not start
# an emulator.
#
# Example usage: maline.sh -f apk-list-file -d maline-android-19

set -e

source $MALINE/lib/maline.lib
CURR_PID=$$

MALINE_START_TIME=`date +"%s"`

SCRIPTNAME=`basename $0`

# Constant snapshot name
SNAPSHOT_NAME="maline"

while getopts "f:d:" OPTION; do
    case $OPTION in
	f)
	    APK_LIST_FILE="$OPTARG";;
	d)
	    AVD_NAME="$OPTARG";;
	\?)
	    echo "Invalid option: -$OPTARG" >&2;;
    esac
done

die()
{
    echo >&2 "$@"
    exit 1
}

check_and_exit() {
    if [ -z "$2" ]; then
	echo "$SCRIPTNAME: Parameter \"$1\" is missing"
	echo "Aborting ..."
	exit 1
    fi
}

# Check if all parameters are provided
check_and_exit "-f" $APK_LIST_FILE
check_and_exit "-d" $AVD_NAME

available_port CONSOLE_PORT
available_port ADB_PORT

# Start a log parsing process
loop-parse-new-logs.sh &
PARSE_PID=$!

rm -f $MALINE/.maline-$CURR_PID
echo "Console port: ${CONSOLE_PORT}" >> $MALINE/.maline-$CURR_PID
echo "ADB port: ${ADB_PORT}" >> $MALINE/.maline-$CURR_PID

# Start the emulator
echo "$SCRIPTNAME: Starting emulator ..."
emulator -no-boot-anim -ports $CONSOLE_PORT,$ADB_PORT -prop persist.sys.dalvik.vm.lib.1=libdvm.so -prop persist.sys.language=en -prop persist.sys.country=US -avd $AVD_NAME -snapshot $SNAPSHOT_NAME -no-snapshot-save -wipe-data -netfast -no-window &
EMULATOR_PID=$!

# Get the current time
TIMESTAMP=`date +"%Y-%m-%d-%H-%M-%S"`

# A timeout in seconds for app testing
TIMEOUT=600

# For every app, wait for the emulator to be avaiable, install the
# app, test it with Monkey, trace system calls with strace, fetch the
# strace log, and load a clean Android snapshot for the next app

FAILED_APPS_FILE="$MALINE/apk-list-file-$TIMESTAMP-maline-$CURR_PID"

# Reserve an adb server port only now that the emulator is up so as to
# minimize chances of someone else getting the port in the meantime
available_port ADB_SERVER_PORT
echo "ADB server port: ${ADB_SERVER_PORT}" >> $MALINE/.maline-$CURR_PID

# Get the emulator ready
get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

for APP_PATH in `cat $APK_LIST_FILE`; do

    date
    # measure time it will take to do everything for an app
    START_TIME=`date +"%s"`

    echo "$SCRIPTNAME: App under analysis: $APP_PATH"

    # Get the Emulator ready for the app
    get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

    # Check if a log file for this app already exists
    APK_FILE_NAME=`basename $APP_PATH .apk`
    APP_NAME=`getAppPackageName.sh $APP_PATH`
    LOGFILE="$MALINE/log/$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"
    rm -f $LOGFILE

    # Install, test, and remove the app
    set +e
    timeout $TIMEOUT inst-run-rm.sh $APP_PATH $ADB_PORT $ADB_SERVER_PORT $TIMESTAMP $CONSOLE_PORT
    set -e
    # If there is no log file of the app, it means something has went
    # wrong and the app hasn't been analyzed
    if [ ! -f $LOGFILE ]; then
	echo $APP_PATH >> $FAILED_APPS_FILE
    fi

    # Reload a clean snapshot
    avd-reload $CONSOLE_PORT $SNAPSHOT_NAME
    
    END_TIME=`date +"%s"`
    TOTAL_TIME=$((${END_TIME} - ${START_TIME}))
    echo "Total time for app `getAppPackageName.sh $APP_PATH`: $TOTAL_TIME s"
    echo ""
done

# Kill the emulator
kill-emulator $CONSOLE_PORT
kill -9 $EMULATOR_PID 2>&1 > /dev/null

# Kill the log parsing process
kill $PARSE_PID

# Remove a temporary file with a list of ports used
rm $MALINE/.maline-$CURR_PID

MALINE_END_TIME=`date +"%s"`
MALINE_TOTAL_TIME=$((${MALINE_END_TIME} - ${MALINE_START_TIME}))

NUM_OF_APPS=`cat $APK_LIST_FILE | wc -l`
if [ ! -z "$NUM_OF_APPS" ]; then
    PER_APP_TIME=`echo "scale=3; $MALINE_TOTAL_TIME / $NUM_OF_APPS" | bc`
    echo ""
    echo "Per app time: $PER_APP_TIME s"
fi

echo
date
echo "Total tool time: $MALINE_TOTAL_TIME s"
