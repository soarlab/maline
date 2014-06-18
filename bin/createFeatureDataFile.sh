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


die() {
    echo >&2 "$@"
    exit 1
}

# A directory where log and graph files are
LOG_DIR=$1

# A directory where files should be split based on app behavior
BEHAVIOR_DIR=$2

[ ! -z $LOG_DIR ] || LOG_DIR=$MALINE/log
[ -d $LOG_DIR ] || die "Non-existing log directory!"

[ ! -z $BEHAVIOR_DIR ] || BEHAVIOR_DIR=$MALINE/features

GOODWARE_DIR=$BEHAVIOR_DIR/goodware
MALWARE_DIR=$BEHAVIOR_DIR/malware

rm -rf $BEHAVIOR_DIR &>/dev/null

mkdir -p $GOODWARE_DIR
mkdir -p $MALWARE_DIR

# Separate goodware and malware files. Malware file names have to
# start with 64 hexadecimal digits
echo -n "Splitting goodware and malware based on file names... "
for FILE in $(ls -1 $LOG_DIR/*graph); do
    FIRST_PART=$(basename $FILE | awk -F"-" '{print $1}')
    if [[ $FIRST_PART =~ [0-9a-fA-F]{64} ]]; then
	ln -s $FILE $MALWARE_DIR/
    else
	ln -s $FILE $GOODWARE_DIR/
    fi
done
echo "done"

OUTPUT_FILE=$BEHAVIOR_DIR/features-file

echo "Generating a big feature data file from app trace logs..."
# CURR_DIR=$(pwd)
# cd $MALINE/bin
loaddata.m $BEHAVIOR_DIR $OUTPUT_FILE
# cd $CURR_DIR
