#!/bin/sh

../lib/apktool/apktool d $1 1>/dev/null 2>/dev/null
filepath=$(basename $1 .apk)
filename=./$filepath/AndroidManifest.xml
package=$(grep -e "package" $filename | grep -o -P '(?<=package=").*(?=\")')
echo $package
rm -rf $filepath
