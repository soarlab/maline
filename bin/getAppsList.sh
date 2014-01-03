#!/bin/bash

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
