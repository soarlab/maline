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
# MERCHANTABILITY or FITNESS FOR A PARTIsCULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with maline.  If not, see <http://www.gnu.org/licenses/>.

if [ "$#" -lt 3 ]; then
    echo "Usage: get-cv-params.sh FOLDERS_LIST INDEX_FILE TYPE[freq,graph]"
    exit
fi

explist=$1
index_file=$2
type=$3
dirint=$(dirname $explist)
filename="feature-matrix-"$type
easy=$(which easy.py)
grid=$(which grid.py)

while read line
do
    cd $line
    dir=$line/transformed_data
    mkdir -p $dir
    transforms_data $filename $dir
    cd $dir
    for fold in 1 2 3 4 5
    do
	create_datasets_cv $filename.sparse ../../$index_file $fold
	svm-scale $filename.sparse.training.$fold > $filename.sparse.training.$fold.scale
	svm-scale $filename.sparse.testing.$fold > $filename.sparse.testing.$fold.scale
	python $grid $filename.sparse.training.$fold 
	acc=$(cat $filename.sparse.training.$fold.scale.out | awk -F" " '{print $3}' | awk -F"=" '{ print $2 }' | sort -nr | head -1)
	csvc=$(cat $filename.sparse.training.$fold.scale.out | grep $acc | head -1 | awk -F" " '{ print $1 }' | awk -F"=" '{print $2 }')
	gamma=$(cat $filename.sparse.training.$fold.scale.out | grep $acc | head -1 | awk -F" " '{ print $2 }' | awk -F"=" '{print $2 }')
	run-classdroid_cv.sh $filename.sparse.training.$fold.scale $filename.sparse.testing.$fold.scale $fold $type $((2**$csvc)) $((2**$gamma)) 1
    done
done < $explist
