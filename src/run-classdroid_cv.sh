#!/bin/bash -x

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
    echo "Testing Set Fold $fold" >> $results
    echo >> $results
        
    echo "Linear Kernel" >> $results
    
    svm-train -s $type -t 0 -c $csvc -g $gamma -h 0 -b 1 $current/$training_file $training_file.linear.model
    svm-predict -b 1 $current/$testing_file $training_file.linear.model $testing_file.linear.out >> $results
    
    echo >> $results
    
    echo "Confusion Matrix"
    confusion-matrix_cv.sh $testing_file $fold $type >> $results
    echo >> $results
    
    echo "RBF - Radial Basis Function" >> $results
    
    svm-train -s $type -t 2 -c $csvc -g $gamma -h 0 -b 1 $current/$training_file $training_file.rbf.model
    svm-predict -b 1 $current/$testing_file $training_file.rbf.model $testing_file.rbf.out >> $results
    
    echo "Confusion Matrix"
    confusion-matrix_cv.sh $testing_file $fold $type >> $results
    echo >> $results
    
    
    for deg in 1 2 3 4 5
    do 
	echo "Polynomial Kernel - Degree $deg" >> $results
	
	svm-train -s $type -t 1 -c $csvc -g $gamma -d $deg -h 0 -b 1 $current/$training_file $training_file.k$deg.model
	svm-predict -b 1 $current/$testing_file $training_file.k$deg.model $testing_file.k$deg.out >> $results
	
	echo >> $results
	
	echo "Confusion Matrix"
	confusion-matrix_cv.sh $testing_file $fold $type >> $results
	echo >> $results
    done    
}

if [ "$#" -lt 7 ]; then
    echo "Usage: run-classdroid.sh TRAINING_FILE TESTING_FILE FOLD TYPE(graph,freq) CSVC GAMMA SCALE"
    exit
fi

training_file=$1
testing_file=$2
fold=$3
name=$4
csvc=$5
gamma=$6
scale=$7

current=`pwd`
date=$(date +"%Y%m%d%H%M%S")
dir="svmresults_${date}_$name"
mkdir $dir

SCALE=""
if [ "$scale" -eq 1 ]; then
    SCALE=".scale"
fi

results="feature-matrix-"$type.$fold.result

type=0
echo "C-SVC value: $csvc" >> $results
echo "GAMMA value: $gamma" >> $results
cd $dir
svm
