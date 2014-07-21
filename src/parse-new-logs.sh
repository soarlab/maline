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


# If providing an optional parameter (path to a log directory), make
# sure not to include the ending slash

LOG_DIR_DEFAULT="$MALINE/log"

if [ ! -z "$1" ]; then
    LOG_DIR="$1"
fi

: ${LOG_DIR=$LOG_DIR_DEFAULT}

PER_APP_TIME_CALLS_DIR=$2

APK_LIST_FILE=$3

while :
do
    for LOG in $(find $LOG_DIR -name "*log" 2>/dev/null); do
	BASE_NAME=$(basename $LOG .log | awk -F"-" '{ print $2 }')
	if [ "$(grep $BASE_NAME $APK_LIST_FILE | wc -l)" -eq 0 ]; then
	    continue
	fi
	parse-log-lock.sh $LOG_DIR $LOG $PER_APP_TIME_CALLS_DIR
    done

    sleep 42s
done
