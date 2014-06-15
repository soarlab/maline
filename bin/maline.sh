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


# This script boots a clean snapshot in a headless emulator. A list of
# paths to Android apps - one path per line - is specified in a file
# given with the -f parameter.
#
# Example usage: maline.sh -f apk-list-file -d maline-android-19

set -e

# Clean up upon exiting from the process
function __sig_func {
    set +e
    # Kill the ADB server
    adb -P $ADB_SERVER_PORT kill-server

    # Kill the emulator
    kill-emulator $CONSOLE_PORT &>/dev/null
    sleep 1s
    kill -9 $EMULATOR_PID &>/dev/null
    sleep 1s
    # Remove lock files
    find $AVDDIR/$AVD_NAME.avd/ -name "*lock" | xargs rm -f
    
    # Kill the log parsing process
    kill $PARSE_PID &>/dev/null

    kill $(jobs -p) &>/dev/null
    
    MALINE_END_TIME=`date +"%s"`
    MALINE_TOTAL_TIME=$((${MALINE_END_TIME} - ${MALINE_START_TIME}))

    # Remove emulator-related files
    rm -f $STATUS_FILE
    rm -f $EMULATOR_OUTPUT_FILE
    rm -f $EMULATOR_NAND_FILE

    # NUM_OF_APPS=`cat $APK_LIST_FILE | wc -l`
    if [ $NUM_OF_APPS -ne 0 ]; then
	PER_APP_TIME=`echo "scale=3; $MALINE_TOTAL_TIME / $NUM_OF_APPS" | bc`
	echo ""
	echo "Per app time: $PER_APP_TIME s"
    fi
    
    echo
    date
    echo "Total tool time: $MALINE_TOTAL_TIME s"

    # Remove a temporary file with a list of ports used
    rm -f $PROC_INFO_FILE

    # Remove app testing files
    rm -f $APP_STATUS_FILE
    rm -f $GPS_SMS_STATUS_FILE

    echo "Exiting from $SCRIPTNAME..."
}

die() {
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

get_emu_ready() {
    # Get the emulator ready. If it is not ready after a time limit,
    # kill the emulator, start a new one, and wait for it. Repeat
    # until the emulator is ready.

    while [ "`cat $STATUS_FILE 2>/dev/null`" != "1" ]; do
	get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT || exit 1

	# Check if the device is ready
	if [ "`cat $STATUS_FILE 2>/dev/null`" != "1" ]; then
	    set +e
	    adb -P $ADB_SERVER_PORT kill-server
	    kill-emulator $CONSOLE_PORT &>/dev/null
	    sleep 1s
	    adb -P $ADB_SERVER_PORT kill-server
	    kill -9 $EMULATOR_PID &>/dev/null
	    kill $(jobs -p) &>/dev/null
	    rm -f $EMULATOR_OUTPUT_FILE
	    rm -f $EMULATOR_NAND_FILE
	    set -e
	    sleep 1s
	    # Remove lock files
	    find $AVDDIR/$AVD_NAME.avd/ -name "*lock" | xargs rm -f
	    EMULATOR_NAND_FILE=
	    $EMULATOR_CMD &>$EMULATOR_OUTPUT_FILE &
	    EMULATOR_PID=$!
	    find_emulator_nand_file
	fi
    done

    rm -f $STATUS_FILE
}

# A function for installing an app, running it, and removing it from
# the device
inst_run_rm() {
    set +e

    # Temporary status files
    APP_STATUS_FILE=$MALINE/.app_status-$CURR_PID
    GPS_SMS_STATUS_FILE=$MALINE/.inst-run-rm-$CURR_PID
    rm -f $GPS_SMS_STATUS_FILE

    # Install the app. Make 3 attempts
    ATTEMPT=0
    ATTEMPT_LIMIT=3

    while [ $ATTEMPT -lt $ATTEMPT_LIMIT ]; do
	echo -n "Installing the app: attempt $ATTEMPT... "
	rm -f $APP_STATUS_FILE
	timeout 25 adb -P $ADB_SERVER_PORT install $APP_PATH &>$APP_STATUS_FILE

	RES=`tail -n 1 $APP_STATUS_FILE`
	RES=${RES:0:7}
	
	if [ "$RES" = "Success" ]; then
	    echo "succeeded"
	    break
	else
	    echo "failed"
	fi
	
	let ATTEMPT=ATTEMPT+1
	if [ $ATTEMPT -eq $ATTEMPT_LIMIT ]; then
	    break
	fi

	# Reload a clean snapshot
	avd-reload $CONSOLE_PORT $SNAPSHOT_NAME &>/dev/null || return 1
	
	sleep 1s
	
	get_emu_ready
    done

    rm -f $APP_STATUS_FILE

    # Abort if the app is not installed
    if [ $ATTEMPT -eq $ATTEMPT_LIMIT ]; then
	echo "Failed to install the app in $ATTEMPT_LIMIT attempts"
	echo "Aborting."
	echo ""
	return 0
    fi

    # Extract trace from the app
    timeout $TIMEOUT extract-trace.sh $APP_PATH $CONSOLE_PORT $ADB_SERVER_PORT $ADB_PORT $TIMESTAMP $LOG_DIR || return 1
    
    check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func
    
    sleep 1s
    
    # Uninstall the app from the device
    echo -n "Uninstalling the app... "
    timeout 60 adb -P $ADB_SERVER_PORT uninstall $APP_NAME &>/dev/null && echo "done" || echo "failed"
    
    set -e

    return 0
}

# finds a system NAND image file of the emulator
find_emulator_nand_file() {
    
    while true; do
	if [ "$(grep -c "emulator: mapping 'system'" $EMULATOR_OUTPUT_FILE)" -gt 0 ]; then
	    EMULATOR_NAND_FILE=$(grep "emulator: mapping 'system'" $EMULATOR_OUTPUT_FILE | awk -F" " '{print $NF}')
	    break
	fi
	sleep 0.25s
    done
}

source $MALINE/lib/maline.lib
CURR_PID=$$

MALINE_START_TIME=`date +"%s"`

SCRIPTNAME=`basename $0`

# Constant snapshot name
SNAPSHOT_NAME="maline"

while getopts "f:d:l:" OPTION; do
    case $OPTION in
	f)
	    APK_LIST_FILE="$OPTARG";;
	d)
	    AVD_NAME="$OPTARG";;
	l)
	    LOG_DIR="$OPTARG";;
	\?)
	    echo "Invalid option: -$OPTARG" >&2;;
    esac
done


# Check if all parameters are provided
check_and_exit "-f" $APK_LIST_FILE
check_and_exit "-d" $AVD_NAME

# Check if Android environment variables are set
[ ! -z "$ANDROID_SDK_HOME" ] || die "Environment variable ANDROID_SDK_HOME not set!"
[ ! -z "$ANDROID_SDK_ROOT" ] || die "Environment variable ANDROID_SDK_ROOT not set!"
[ ! -z "$AVDDIR" ] || die "Environment variable AVDDIR not set!"
[ ! -z "$MALINE" ] || die "Environment variable MALINE not set!"

if [ -z $LOG_DIR ]; then
    LOG_DIR=$MALINE/log
fi
mkdir -p $LOG_DIR

# Set traps
trap __sig_func EXIT
trap __sig_func INT
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

available_port CONSOLE_PORT
available_port ADB_PORT

# Start a log parsing process
loop-parse-new-logs.sh $LOG_DIR &
PARSE_PID=$!

PROC_INFO_FILE=$MALINE/.maline-$CURR_PID
rm -f $PROC_INFO_FILE

echo "Console port: ${CONSOLE_PORT}" >> $PROC_INFO_FILE
echo "ADB port: ${ADB_PORT}" >> $PROC_INFO_FILE

# Start the emulator
EMULATOR_OUTPUT_FILE=$MALINE/.emulator-output-$CURR_PID
rm -f $EMULATOR_OUTPUT_FILE
EMULATOR_NAND_FILE=
EMULATOR_CMD="emulator -verbose -no-boot-anim -ports $CONSOLE_PORT,$ADB_PORT -prop persist.sys.dalvik.vm.lib.1=libdvm.so -prop persist.sys.language=en -prop persist.sys.country=US -avd $AVD_NAME -snapshot $SNAPSHOT_NAME -no-snapshot-save -wipe-data -netfast -no-window"
# $EMULATOR_CMD &>/dev/null &
$EMULATOR_CMD &>$EMULATOR_OUTPUT_FILE &
EMULATOR_PID=$!
find_emulator_nand_file

# Get the current time
TIMESTAMP=`date +"%Y-%m-%d-%H-%M-%S"`

# A timeout in seconds for app testing
TIMEOUT=840

# Emulator status file
STATUS_FILE=$MALINE/.emulator-$ADB_PORT

# Number of apps analyzed so far
NUM_OF_APPS=0

# Reserve an adb server port only now that the emulator is up so as to
# minimize chances of someone else getting the port in the meantime
available_port ADB_SERVER_PORT
echo "ADB server port: ${ADB_SERVER_PORT}" >> $PROC_INFO_FILE

# Get the emulator ready
get_emu_ready

# Check if the input file exists
[ -f $APK_LIST_FILE ] || die "Non-existing input file!"
# Keep an ever-changing list of non-analyzed apps
NON_ANALYZED_FILE="$APK_LIST_FILE-non-analyzed"
cp $APK_LIST_FILE $NON_ANALYZED_FILE

# Initialize app testing files
APP_STATUS_FILE=
GPS_SMS_STATUS_FILE=

# For every app, wait for the emulator to be avaiable, install the
# app, test it with Monkey, trace system calls with strace, fetch the
# strace log, and load a clean Android snapshot for the next app
for APP_PATH in `cat $APK_LIST_FILE`; do

    date
    # measure the time it will take to do everything for an app
    START_TIME=`date +"%s"`

    echo "App under analysis: $APP_PATH"
    if [ ! -f $APP_PATH ]; then
	echo "$APP_PATH is not a regular file"
	continue
    fi

    # Get the Emulator ready for the app
    get_emu_ready

    # Check if a log file for this app already exists
    APK_FILE_NAME=`basename $APP_PATH .apk`
    APP_NAME=`getAppPackageName.sh $APP_PATH`
    
    LOGFILE="$LOG_DIR/$APK_FILE_NAME-$APP_NAME-$TIMESTAMP.log"
    rm -f $LOGFILE

    set +e
    inst_run_rm
    set -e

    # If there is no log file of the app at this point, it means
    # something has went wrong and the app hasn't been analyzed
    if [ -f $LOGFILE ]; then
	# Remove app from the list of non-analyzed apps
	sed -i "s|$APP_PATH||g" $NON_ANALYZED_FILE
	# Delete empty lines
	sed -i '/^$/d' $NON_ANALYZED_FILE

	let NUM_OF_APPS=NUM_OF_APPS+1
    fi

    # Reload a clean snapshot
    echo -n "Reloading a clean snapshot for the next app... "
    avd-reload $CONSOLE_PORT $SNAPSHOT_NAME &>/dev/null || exit 1
    echo "done"
    
    END_TIME=`date +"%s"`
    TOTAL_TIME=$((${END_TIME} - ${START_TIME}))
    echo "Total time for app `getAppPackageName.sh $APP_PATH`: $TOTAL_TIME s"
    echo ""
done

echo "Done analysing apps in $APK_LIST_FILE"
echo ""

exit 0
