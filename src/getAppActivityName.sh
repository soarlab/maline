#!/bin/sh

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

CURR_PID=$$
TMP_DIR=$MALINE/.getAppPackageName-$CURR_PID
$MALINE/lib/apktool/apktool d $1 $TMP_DIR 1>/dev/null 2>/dev/null
filename=$TMP_DIR/AndroidManifest.xml
process=$(grep -e "android:process" $filename | grep -o -P '(?<=android:process=").*(?=\")' | uniq)
activity=$(grep -e "activity" $filename | head -1 | grep -o -P '(?<=android:name=").*(?=\")')
package=$(grep -e "package" $filename | grep -o -P '(?<=package=").*(?=\")')
occurrences=$(grep -o "." <<< "$activity" | wc -l)
echo $occurrences
if [[ $activity == ".*" ]]; then
    activity=$(echo $package$activity)
elif [[ $occurrences > 1 ]]; then
    activity=$(echo $package)
else
    activity=$(echo $package.$activity)
fi
rm -rf $TMP_DIR
echo $TMP_DIR
rm -rf $HOME/apktool
if [ -z "$process" ]; then
  echo $package $package $activity
else
  echo $package $process $activity
fi
