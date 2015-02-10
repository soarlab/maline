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

svm()
{
    csvc=$1
    gamma=$2
    fold=$3
    
    echo "Testing Set Fold $fold" >> $results.$fold
    echo >> $results.$fold
        
    echo "Linear Kernel" >> $results.$fold
    
    svm-train -s $type -t 0 -c $csvc -g $gamma -h 0 -b 1 $filename.training.$fold $filename.training.$fold.linear.model
    svm-predict -b 1 $filename.testing.$fold $filename.training.$fold.linear.model $filename.$fold.linear.out >> $results.$fold
    
    echo >> $results.$fold
    
    echo "Confusion Matrix"
    confusion-matrix_cv.sh $filename $fold $dir >> $results.$fold
    echo >> $results.$fold
    
    echo "RBF - Radial Basis Function" >> $results.$fold
    
    svm-train -s $type -t 2 -c $csvc -g $gamma -h 0 -b 1 $filename.training.$fold $filename.training.$fold.rbf.model
    svm-predict -b 1 $filename.testing.$fold $filename.training.$fold.rbf.model $filename.$fold.rbf.out >> $results.$fold
    
    echo "Confusion Matrix"
    confusion-matrix_cv.sh $filename $fold $dir >> $results.$fold
    echo >> $results.$fold
    
    
    for deg in 1 2 3 4 5
    do 
	echo "Polynomial Kernel - Degree $deg" >> $results.$fold
	
	svm-train -s $type -t 1 -c $csvc -g $gamma -d $deg -h 0 -b 1 $filename.training.$fold $filename.training.$fold.k$deg.model
	svm-predict -b 1 $filename.testing.$fold $filename.training.$fold.k$deg.model $filename.$fold.k$deg.out >> $results.$fold
	
	echo >> $results.$fold
	
	echo "Confusion Matrix"
	confusion-matrix_cv.sh $filename $fold $dir >> $results.$fold
	echo >> $results.$fold
    done    
}

if [ "$#" -lt 7 ]; then
    echo "Usage: run-classdroid.sh FILENAME TRANSFORM_DATA TYPE(graph,freq) INDEX_FILE CSVC GAMMA SCALE"
    exit
fi

file=$1
transform=$2
index_file=$4
csvc=$5
gamma=$6
scale=$7

PWD=`pwd`
date=$(date +"%Y%m%d%H%M%S")
dir="svmresults_${date}_$3"
mkdir $dir

SCALE=""
if [ "$scale" -eq 1 ]; then
    SCALE=".scale"
fi

if [ "$transform" -eq 1 ]; then
    transforms_data $file $dir
else
    ln -s $PWD/$file.sparse$SCALE $dir/$file.sparse$SCALE
fi

export filename=$dir/$file.sparse$SCALE

results=$dir/results.dat

type=0
for fold in 1 2 3 4 5
do
    create_datasets_cv $filename $index_file $fold
    
    echo "C-SVC value: $csvc" >> $results.$fold
    echo "GAMMA value: $gamma" >> $results.$fold
    svm $csvc $gamma $fold &
done
