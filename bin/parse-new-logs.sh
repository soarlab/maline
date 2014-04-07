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

# Check if there is another instance of this script and exist if it
# does
LOCK_FILE="$MALINE/.parse-new-logs.lock"

if [ -e "$LOCK_FILE" ]; then
    # echo "Another instance of $0 already running! Exiting ..."
    exit 0
else
    echo $$ > $LOCK_FILE
fi

LOG_DIR_DEFAULT="$MALINE/log"

if [ ! -z "$1" ]; then
    LOG_DIR="$1"
fi

: ${LOG_DIR=$LOG_DIR_DEFAULT}

LOG_FILES_COUNT=`ls -1 $LOG_DIR/*log 2>&1 | wc -l`
GRAPH_FILES_COUNT=`ls -1 $LOG_DIR/*graph 2>&1 | wc -l`
if [ $LOG_FILES_COUNT != $GRAPH_FILES_COUNT ]; then
    date
    echo "Total number of log files: $LOG_FILES_COUNT"
    echo ""
fi

# Set the strace parsing command name and use a compiled version when
# possible
STRACE_PY_SRC="$MALINE/bin/parse-strace-log.py"
COMMAND="python $STRACE_PY_SRC"
COMMAND_COMPILED="$MALINE/bin/parse-strace-log.pyc"

if hash pycompile 2>/dev/null && [ ! -e "$COMMAND_COMPILED" ]; then
    cd $MALINE/bin
    pycompile $COMMAND
    chmod +x $COMMAND_COMPILED
    cd -
fi

# if [ -e "$COMMAND_COMPILED" ]; then
#     COMMAND="$COMMAND_COMPILED"
# fi

COUNTER=0

for LOG in `ls -1 $LOG_DIR/*log`; do
    base_name=$(basename $LOG .log)

    if [ -e "$LOG_DIR/$base_name.graph" ]; then
	# Skipping $LOG because it was already parsed ...
	# echo "Skipping $LOG because it was already parsed ..."
	continue
    fi

    echo "Parsing $LOG ..."
    $COMMAND $LOG
    let COUNTER++
done

if [ $COUNTER -gt 0 ]; then
    echo ""
    date
    echo "Parsed $COUNTER new log files"
fi

rm $LOCK_FILE
