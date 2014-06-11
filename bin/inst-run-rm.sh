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
    rm -f $APP_STATUS_FILE
    rm -f $GPS_SMS_STATUS_FILE
    exit 1
}

# Set traps
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

# Path to the app under test
APP_PATH="$1"

# Extract app's name
APP_NAME=`getAppPackageName.sh $1`

# ADB port
ADB_PORT="$2"

# ADB server port
ADB_SERVER_PORT="$3"

# Timestamp
TIMESTAMP="$4"

CONSOLE_PORT="$5"

# Constant snapshot name
SNAPSHOT_NAME="maline"

# Current process ID
CURR_PID=$$

# Temporary status files
APP_STATUS_FILE=$MALINE/.app_status-$CURR_PID
GPS_SMS_STATUS_FILE=$MALINE/.inst-run-rm-$CURR_PID
rm -f $GPS_SMS_STATUS_FILE

# Install the app. Make 3 attempts
ATTEMPT=0
ATTEMPT_LIMIT=3

while [ $ATTEMPT -lt $ATTEMPT_LIMIT ]; do
    echo -n "Installing the app: attempt $ATTEMPT... "
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
    avd-reload $CONSOLE_PORT $SNAPSHOT_NAME &>/dev/null || exit 1

    sleep 2s

    get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT || exit 1
done

rm -f $APP_STATUS_FILE

# Abort if the app is not installed
if [ $ATTEMPT -eq $ATTEMPT_LIMIT ]; then
    echo "Failed to install the app in $ATTEMPT_LIMIT attempts"
    echo "Aborting."
    echo ""
    exit 0
fi

# Extract trace from the app
extract-trace.sh $APP_PATH $CONSOLE_PORT $ADB_SERVER_PORT $ADB_PORT $TIMESTAMP || exit 1

check-adb-status.sh $ADB_SERVER_PORT $ADB_PORT || __sig_func

sleep 1s

# Uninstall the app from the device
echo "Uninstalling the app..."
adb -P $ADB_SERVER_PORT uninstall $APP_NAME &>/dev/null

exit 0
