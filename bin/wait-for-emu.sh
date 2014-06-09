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


function __sig_func {
    echo "Exiting from wait-for-emu.sh"
    kill $ADB_PID &>/dev/null
    exit 1
}

# Set traps
trap __sig_func SIGQUIT
trap __sig_func SIGKILL
trap __sig_func SIGTERM

ADB_PORT="$1"
ADB_SERVER_PORT="$2"

COUNTER=0
COUNTER_LIMIT=2

STATUS_FILE=$MALINE/.emulator-$ADB_PORT
echo "0" > $STATUS_FILE

echo -n "Waiting for the device: "

EMU_READY="0"
while [ "$EMU_READY" != "1" ]; do
    echo -n "."
    sleep 3s
    
    if [ $COUNTER -eq $COUNTER_LIMIT ]; then
	let COUNTER=0
	
	# echo "Disconnecting from the device ..."
	adb -P $ADB_SERVER_PORT -e disconnect localhost:$ADB_PORT &>/dev/null 
	
	# echo "Killing and starting the adb server ..."
	adb -P $ADB_SERVER_PORT kill-server &>/dev/null
	
	adb -P $ADB_SERVER_PORT start-server &>/dev/null &
	export ADB_PID=$!
    fi
    
    adb -P $ADB_SERVER_PORT -e connect localhost:$ADB_PORT &>/dev/null
    
    EMU_READY=`timeout 5 adb -P $ADB_SERVER_PORT -e -s localhost:$ADB_PORT shell getprop dev.bootcomplete 2>&1`
    EMU_READY=${EMU_READY:0:1}

    let COUNTER=COUNTER+1
done

echo " ready"
echo "1" > $STATUS_FILE

exit 0
