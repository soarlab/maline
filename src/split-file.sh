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


# Input file to be split
FILE=$1

# Number of chunks the file should be split into
NUM_CHUNKS=$2

FILE_LINES=$(cat $FILE | wc -l)
BASIC_NUM_OF_LINES_PER_FILE=$(($FILE_LINES / $NUM_CHUNKS))
LEFTOVER=$(($FILE_LINES - $NUM_CHUNKS * $BASIC_NUM_OF_LINES_PER_FILE))

# Line pointers
START=1
END=$BASIC_NUM_OF_LINES_PER_FILE

for i in $(seq 0 $(($NUM_CHUNKS - 1))); do
    if [ $LEFTOVER -gt 0 ]; then
	END=$(($END + 1))
	LEFTOVER=$(($LEFTOVER - 1))
    fi

    # Extract respective lines from the input file
    sed -n $START,${END}p $FILE > ${FILE}.$(printf "%02d" $i)

    START=$(($END + 1))
    END=$(($START + $BASIC_NUM_OF_LINES_PER_FILE - 1))
done
