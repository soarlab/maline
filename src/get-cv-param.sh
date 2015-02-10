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

classification()
{
    item=$1
    name=$2
    transforms_data $item $dir
    cd $dir
    python $easy $item.sparse 
    csvc=$(sort -t= -nr -k3 $item.sparse.scale.out | head -1 | awk -F" " '{ print $1 }' | awk -F"=" '{print $2 }')
    gamma=$(sort -t= -nr -k3 $item.sparse.scale.out | head -1 | awk -F" " '{ print $2 }' | awk -F"=" '{print $2 }')
    run-classdroid_cv.sh $item 0 $name ../../folds.csv $csvc $gamma 1 &
}

if [ "$#" -lt 1 ]; then
    echo "Usage: get-cv-params.sh FOLDERS_LIST"
    exit
fi

explist=$1
dirint=$(dirname $explist)
graph="feature-matrix-graph"
freq="feature-matrix-freq"
easy=$(which easy.py)

while read line
do
    dir=$line/transformed_data
    mkdir -p $dir
    cd $line
    classification $freq freq
    classification $graph graph
done < $explist
