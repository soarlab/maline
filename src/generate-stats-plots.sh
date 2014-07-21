#!/bin/bash

# Directory where all app stats files are
INPUT_DIR=$1

# A file to write a table to
STATS_FILE=$2

for app in $(find $INPUT_DIR -type f -name "*txt"); do
    TIME=$(head -n 1 $app)
    LINES=$(wc -l $app | awk -F" " '{print $1}')
    if [ "$LINES" -eq 2 ]; then
	COUNT=$(tail -n 1 $app)
    else
	COUNT=0
    fi
    echo -e "$TIME\t$COUNT" >> $STATS_FILE
done

R --no-restore --no-save --args $STATS_FILE < $MALINE/src/draw-stats-graphs.R
