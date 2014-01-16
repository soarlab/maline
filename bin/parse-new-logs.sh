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
