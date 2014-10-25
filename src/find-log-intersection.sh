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

if [ "$#" -lt 1 ]; then
    echo "Usage: find-log-intersection.sh LIST-OF-EXPERIMENTS-LOG-DIRS"
    exit 1
fi

explist=$1
dirint=$(dirname $explist)

while read line
do
    dir=$line
    name=$(echo $dir | awk -F"/android-logs" '{ print $1}' | awk -F/ '{ print $NF}' )
    find $dir -name "*.log" | awk -F/ '{ print $NF }' | awk -F"-" '{ print $2"-"$3}' | sort | uniq > $dirint/$name.int
done < $explist

FILES=$dirint/*.int
intersection=/tmp/intersection-$(date +"%s").txt
first=1
for file in $FILES
do
    if [ $first -eq 0 ]; then
	comm -12 $intersection $file > $intersection.tmp
	mv $intersection.tmp $intersection
    else
	cat $file > $intersection
	first=0
    fi
done

cat $intersection
rm -f $intersection
rm -f $dirint/*.int
