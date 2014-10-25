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


function die() {
    echo >&2 "$@"
    exit 1
}

function perform_init_checks() {
    # Check if needed variables have been set
    
    [ ! -z $COUNT ] || die "Number of maline instances not provided"

    [ -d $LOG_DIR ] || die "Non-existing log directory!"
    
    [ ! -z $PARSING_TYPE ] || die "Parsing type hasn't been provided!"

    [ ! -z $MALINE ] || die "Environment variable MALINE not set"

    [ ! -z $EXP_ROOT ] || die "Environment variable EXP_ROOT not set"
}

# Number of parsing instances to start
COUNT=$1

# A directory with log files to be parsed
LOG_DIR=$2

# Paring type: it can be regular, noncut, or frequency
PARSING_TYPE=$3

perform_init_checks

LOG_EXT=".log"
TMP_FILE=$MALINE/parsing-$(date +"%s")


# Write down the complete list of log files to be parsed and then
# split it $COUNT ways
find $LOG_DIR -name "*$LOG_EXT" > $TMP_FILE
split-file.sh $TMP_FILE $COUNT

# Start a screen daemon in the detached mode
SCREEN_SESSION="parsing-$PARSING_TYPE"
screen -dmS "$SCREEN_SESSION" -t "0"

# Keep track of what files haven't been parsed so far
NON_PARSED_DIR=$LOG_DIR/../non-parsed/$PARSING_TYPE
mkdir -p $NON_PARSED_DIR


for i in $(seq 0 $(($COUNT-1))); do
    if [ $i -ne 0 ]; then
	# Open a new window
	screen -S "$SCREEN_SESSION" -X screen -t "$i"
    fi

    INPUT_LIST=$TMP_FILE.$(printf "%02d" $i)
    CMD="sequential-parsing.sh $INPUT_LIST $PARSING_TYPE $NON_PARSED_DIR"
    echo -n "Starting instance #$i in a detached screen... "
    # \\r is there to avoid a window being closed once the command
    # finishes
    screen -S "$SCREEN_SESSION" -p $i -X stuff "$CMD$(printf \\r)" && echo "done" || echo "failed"
done

echo ""
echo "Use the following command to watch progress:"
echo "  screen -x $USER/$SCREEN_SESSION"
echo ""

# Remove all temporary files
rm -f $TMP_FILE &>/dev/null
