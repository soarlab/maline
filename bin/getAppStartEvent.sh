#!/bin/sh

$MALINE/lib/apktool/apktool d $1 1>/dev/null 2>/dev/null
filepath=$(basename $1 .apk)
filename=./$filepath/AndroidManifest.xml
echo $filename
event=$(grep -e "category" $filename | grep -o -P '(?<=category android:name=").*(?=\")' | grep LAUNCHER)
echo $event
rm -rf $filepath
