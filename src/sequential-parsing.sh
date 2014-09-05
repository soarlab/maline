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


# File with a list of log files to be parsed
LIST_FILE=$1

# Parsing type
PARSING_TYPE=$2

# Directory where temporary stats about non-parsed files should be
# kept
NON_PARSED_DIR=$3


NON_PARSED_LIST=$NON_PARSED_DIR/$(basename $LIST_FILE)

cp $LIST_FILE $NON_PARSED_LIST


for LOG in $(cat $LIST_FILE); do
    date
    echo -n "Parsing log file $LOG... "

    if [ ! -f "$LOG" ]; then
	echo "$LOG is not a regular file"
	continue
    fi

    parse-strace-log $LOG i386 . $PARSING_TYPE

    if [ -f "$LOG" ]; then
	echo "done"
	# Remove the log file from the list of non-parsed logs
	sed -i "s|$LOG||g" $NON_PARSED_LIST
	# Delete empty lines
	sed -i '/^$/d' $NON_PARSED_LIST
    else
	echo "invalid log file. It has been deleted."
    fi

done

rm $LIST_FILE
