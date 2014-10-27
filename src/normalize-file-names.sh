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


dir=$1
i=1

for file in $(find $dir -name "*.log" | sort); do
    bname=$(basename $file .log)
    apkname=$(echo $bname | awk -F"-" '{ print $2 }')
    appname=$(echo $bname | awk -F"-" '{ print $3 }')
    if [ -f "$dir/$bname.graph" ]; then
	mv "$dir/$bname.graph" "$dir/$i-$apkname-$appname.graph"
    fi
    if [ -f "$dir/$bname.freq" ]; then
	mv "$dir/$bname.freq" "$dir/$i-$apkname-$appname.freq"
    fi
    mv $file "$dir/$i-$apkname-$appname.log"
    let i=i+1
done
