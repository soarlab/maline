#!/bin/bash

# If providing an optional parameter (path to a log directory), make
# sure not to include the ending slash

LOG_DIR_DEFAULT="log"

if [ ! -z "$1" ]; then
    LOG_DIR="$1"
fi

: ${LOG_DIR=$LOG_DIR_DEFAULT}

date
echo "Number of log files: `ls -1 $LOG_DIR/*log | wc -l`"
echo ""

COMMAND="python parse-strace-log.py"

if [ -e "parse-strace-log.pyc" ]; then
    COMMAND="./parse-strace-log.pyc"
fi

for LOG in `ls -1 $LOG_DIR/*log`; do
    base_name=$(basename $LOG .log)

    if [ -e "$LOG_DIR/$base_name.graph" ]; then
	echo "Skipping $LOG because it was already parsed ..."
	continue
    fi

    echo "Parsing $LOG ..."
    $COMMAND $LOG
done
