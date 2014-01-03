#!/bin/bash

# File to read coordinates from. A location is given in the format <longitude> <latitude> <altitude>, one location per line
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

    geo-fix $CONSOLE_PORT ${coordinate[0]} ${coordinate[1]} ${coordinate[2]}

    # Simulate a movement by waiting some time before the next update
    sleep 11s
done < $FILENAME
