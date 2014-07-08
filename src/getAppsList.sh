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


APPS_PATH=$1

malwareList=( $APPS_PATH/malware/*/*.apk )
goodwareList=( $APPS_PATH/goodware/*.apk )
malwareListSize=$( find $APPS_PATH/malware -type f -name "*.apk" | wc -l)
goodwareListSize=$( find $APPS_PATH/goodware -type f -name "*.apk" | wc -l)

size=`expr $goodwareListSize + $malwareListSize`

i=0
mIndex=0
gIndex=0
while [ $i -lt $size ]
do
    if [ $(( $i % 2 )) -eq 0 ] || [ $gIndex -ge $goodwareListSize ] ; then
	if [ $mIndex -lt $malwareListSize ] ; then
	    echo "Malware"
	    echo ${malwareList[$mIndex]} >> appList.txt
	    mIndex=`expr $mIndex + 1`
	fi
    else
	if [ $gIndex -lt $goodwareListSize ] ; then
	    echo "Goodware"
	    echo ${goodwareList[$gIndex]} >> appList.txt
	    gIndex=`expr $gIndex + 1`
	fi
    fi
    i=`expr $i + 1`
done
