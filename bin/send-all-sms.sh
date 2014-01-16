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


# File to read phone numbers and messages from. Phone numbers contain numbers only and the rest of the line is an SMS text message
FILENAME="$1"

CONSOLE_PORT="$2"

while read line
do
    A=( $line )

    LEN=${#A[@]}

    MSG=""
    
    for (( i=1; i<$LEN; i++ ))
    do
	MSG="${MSG}${A[${i}]} "
    done

    PHONE_NUM=${A[0]}

    send-sms $CONSOLE_PORT $PHONE_NUM "$MSG"

    sleep 7s
done < $FILENAME
