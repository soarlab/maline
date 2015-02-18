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

svm()
{
    echo "Testing Set Fold $fold" >> $results
    echo >> $results
        
    echo "Linear Kernel" >> $results    

    python $grid -log2c 0,15,1 -log2g 1,1,1 -t 0 $current/$training_file
    acc=$(cat $training_file.out | awk -F" " '{print $3}' | awk -F"=" '{ print $2 }' | sort -nr | head -1)
    csvc=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $1 }' | awk -F"=" '{print $2 }')
    gamma=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $2 }' | awk -F"=" '{print $2 }')
    mv $training_file.out $training_file.linear.out
    csvc=$(echo "2 ^ $csvc" | bc)
    echo "C-SVC value: $csvc" >> $results
    echo "GAMMA value: $gamma" >> $results
    svm-train -s 0 -t 0 -c $csvc -b 1 -h 0 $current/$training_file $training_file.linear.model
    svm-predict -b 1 $current/$testing_file $training_file.linear.model $testing_file.linear.out >> $results
    echo >> $results
    
    echo "Confusion Matrix"
    echo $testing_file
    confusion-matrix_cv.sh $testing_file $fold linear >> $results
    echo >> $results
    
    echo "RBF - Radial Basis Function" >> $results
    python $grid -log2c 0,15,1 $current/$training_file
    acc=$(cat $training_file.out | awk -F" " '{print $3}' | awk -F"=" '{ print $2 }' | sort -nr | head -1)
    csvc=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $1 }' | awk -F"=" '{print $2 }')
    gamma=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $2 }' | awk -F"=" '{print $2 }')
    csvc=$(echo "2 ^ $csvc" | bc)
    gamma=$(echo "2 ^ $gamma" | bc)
    mv $training_file.out $training_file.rbf.out
    echo "C-SVC value: $csvc" >> $results
    echo "GAMMA value: $gamma" >> $results
    svm-train -s 0 -t 2 -c $csvc -g $gamma -b 1 -h 0 $current/$training_file $training_file.rbf.model
    svm-predict -b 1 $current/$testing_file $training_file.rbf.model $testing_file.rbf.out >> $results
    
    echo "Confusion Matrix"
    confusion-matrix_cv.sh $testing_file $fold rbf >> $results
    echo >> $results
    
    python $grid -log2c 0,15,1 -log2g 3,-15,-2 -t 1 $current/$training_file
    acc=$(cat $training_file.out | awk -F" " '{print $3}' | awk -F"=" '{ print $2 }' | sort -nr | head -1)
    csvc=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $1 }' | awk -F"=" '{print $2 }')
    gamma=$(cat $training_file.out | grep $acc | head -1 | awk -F" " '{ print $2 }' | awk -F"=" '{print $2 }')
    csvc=$(echo "2 ^ $csvc" | bc)
    gamma=$(echo "2 ^ $gamma" | bc)
    mv $training_file.out $training_file.poly.out
    echo "C-SVC value: $csvc" >> $results
    echo "GAMMA value: $gamma" >> $results
    for deg in 1 2 3 4 5
    do 
	echo "Polynomial Kernel - Degree $deg" >> $results
	
	svm-train -s 0 -t 1 -c $csvc -g $gamma  -d $deg -h 0 -b 1 -h 0 $current/$training_file $training_file.k$deg.model
	svm-predict -b 1 $current/$testing_file $training_file.k$deg.model $testing_file.k$deg.out >> $results
	
	echo >> $results
	
	echo "Confusion Matrix"
	confusion-matrix_cv.sh $testing_file $fold k$deg >> $results
	echo >> $results
    done    
}

if [ "$#" -lt 4 ]; then
    echo "Usage: run-classdroid.sh TRAINING_FILE TESTING_FILE FOLD TYPE(graph,freq)"
    exit
fi

training_file=$1
testing_file=$2
fold=$3
name=$4
easy=$(which easy.py)
grid=$(which grid.py)

current=`pwd`
date=$(date +"%Y%m%d%H%M%S")
dir="svmresults_${date}_$name_fold$fold"
mkdir $dir

results="feature-matrix-"$name.$fold.result

cd $dir
svm
