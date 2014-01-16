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

# Install the app. Make 3 attempts
ATTEMPT=0
ATTEMPT_LIMIT=3
while [ $ATTEMPT -lt $ATTEMPT_LIMIT ]; do
    echo "Installing the app ..."
    echo "  Attempt $ATTEMPT ..."
    timeout 15 adb -P $ADB_SERVER_PORT install $APP_PATH 2>&1 > .app_status

    cat .app_status
    RES=`tail -n 1 .app_status`
    RES=${RES:0:7}

    if [ "$RES" = "Success" ]; then
	break
    fi

    let ATTEMPT=ATTEMPT+1
    if [ $ATTEMPT -eq 3 ]; then
	break
    fi

    echo ""

    # Reload a clean snapshot
    echo "Reloading a clean snapshot for the next attempt ..."
    avd-reload $CONSOLE_PORT $SNAPSHOT_NAME

    sleep 2s

    echo "Connecting to the emulator now ..."
    get_emu_ready.sh $ADB_PORT $ADB_SERVER_PORT

done

# Abort if the app is not installed
if [ $ATTEMPT -eq $ATTEMPT_LIMIT ]; then
    echo "Failed to install the app in $ATTEMPT_LIMIT attempts"
    echo "Aborting ..."
    echo ""
    exit 1
fi

sleep 2s

# Extract trace from the app
extract-trace.sh $APP_PATH $CONSOLE_PORT $ADB_SERVER_PORT $TIMESTAMP
echo "Done"

sleep 1s

# Uninstall the app from the device
echo "Uninstalling the app ..."
adb -P $ADB_SERVER_PORT uninstall $APP_NAME
echo "Done"
