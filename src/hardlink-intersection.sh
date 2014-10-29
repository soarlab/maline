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

if [ "$#" -lt 3 ]; then
    echo "Usage: hardlink-intersection.sh ANDROID-LOGS INTERSECTION-SET-LIST INTERSECTED-ANDROID-LOGS"
    exit 1
fi

androidlogs=$1
intersectionlist=$2
intersectedlogs=$3

mkdir -p $intersectedlogs

filelist=$(find $androidlogs -name "*.log")

while read line
do
    hl=$(echo "$filelist" | grep --max-count=1 "$line")
    if [ ! -z "$hl" ]; then
        bname=$(basename $hl ".log")
        ln $hl $intersectedlogs/${bname}.log
        if [ -f "$androidlogs/${bname}.graph" ]; then
            ln $androidlogs/${bname}.graph $intersectedlogs/${bname}.graph
        fi
        if [ -f "$androidlogs/${bname}.freq" ]; then
            ln $androidlogs/${bname}.freq $intersectedlogs/${bname}.freq
        fi
    fi
done < $intersectionlist
