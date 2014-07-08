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


# File to read coordinates from. A location is given in the format
# <longitude> <latitude> <altitude>, one location per line
FILENAME="$1"

# Only coordinates in a certain list range will be sent
START="$2"
END="$3"

# Console port
CONSOLE_PORT="$4"

COUNTER=-1

while read line
do
    let COUNTER++
    if [ $COUNTER -lt $START ]; then
	continue
    fi
    if [ $COUNTER -ge $END ]; then
	break
    fi

    coordinate=( $line )

    echo "Delivering a location update"
    geo-fix $CONSOLE_PORT ${coordinate[0]} ${coordinate[1]} ${coordinate[2]} &>/dev/null

    # Simulate a movement by waiting some time before the next update
    sleep 11s
done < $FILENAME
