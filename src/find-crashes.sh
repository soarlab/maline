#!/bin/bash

# Copyright 2013-2015 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
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

# Usage: two ways:
# 1) it can read from stdin: ./find-crashes.sh 
# 2) it can read from a file: ./find-crashes.sh log-file.txt

goodware_count=0
malware_count=0

str_goodware_path_prefix="/mnt/storage/crawler/"
str_app_under_analysis="App under analysis"
str_app_not_running="App not running any more. Stopping testing"

while read line
do
    # Check if the line starts with "App under analysis". If so, store
    # the part after the column so that you can use later to tell if
    # it was a malware or goodware app that crashed
    if [[ $line == $str_app_under_analysis* ]]; then
	app_name=$(echo $line | awk -F": " '{print $2}')
	if [[ $app_name == $str_goodware_path_prefix* ]]; then
	    is_goodware=1
	else
	    is_goodware=0
	fi
	continue
    fi
    # Here check if the line starts with "App not running any
    # more. Stopping testing". If that is the case, increase the
    # resepective count
    if [[ $line == $str_app_not_running* ]]; then
	if [ "$is_goodware" -eq "1" ]; then
	    let goodware_count=goodware_count+1
	else
	    let malware_count=malware_count+1
	fi
    fi
done < "${1:-/dev/stdin}"

echo "goodware crash count: ${goodware_count}"
echo "malware crash count:  ${malware_count}"
