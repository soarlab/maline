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

if [ "$#" -lt 4 ]; then
    echo "Usage: run-classdroid.sh FILENAME SHUFFLE TRANSFORM_DATA TYPE(graph,freq)"
    exit
fi

shuffle()
{
    filename=$1

    gNum=$(cat $filename | awk -F " " '{ print $1 }' | grep 0 | wc -l)
    mNum=$(cat $filename | awk -F " " '{ print $1 }' | grep 1 | wc -l)
    
    head -n $gNum $filename > $dir/goodware.tmp
    tail -n $mNum $filename > $dir/malware.tmp

    shuf $dir/goodware.tmp > $dir/tmp.goodware
    shuf $dir/malware.tmp > $dir/tmp.malware

    cat $dir/tmp.malware >> $dir/tmp.goodware
    mv $dir/tmp.goodware $filename
}

svm()
{
    csvc=$1
    ratio=$2
    
    echo "Testing Set $ratio%" >> $results.$csvc
    echo >> $results.$csvc
        
    echo "Linear Kernel" >> $results.$csvc
    
    svm-train -s $type -t 0 -c $csvc -h 0 $filename.training.$ratio $filename.training.$ratio.$csvc.model
    svm-predict $filename.testing.$ratio $filename.training.$ratio.$csvc.model $filename.$ratio.$csvc.out >> $results.$csvc
    
    echo >> $results.$csvc
    
    echo "Confusion Matrix"
    confusion-matrix.sh $filename $ratio $dir $csvc >> $results.$csvc
    echo >> $results.$csvc
    
    echo "RBF - Radial Basis Function" >> $results.$csvc
    
    svm-train -s $type -t 2 -c $csvc -h 0 $filename.training.$ratio $filename.training.$ratio.$csvc.model
    svm-predict $filename.testing.$ratio $filename.training.$ratio.$csvc.model $filename.$ratio.$csvc.out >> $results.$csvc
    
    echo "Confusion Matrix"
    confusion-matrix.sh $filename $ratio $dir $csvc >> $results.$csvc
    echo >> $results.$csvc
    
    
    for deg in 1 2 3 4 5
    do 
	echo "Polynomial Kernel - Degree $deg" >> $results.$csvc
	
	svm-train -s $type -t 1 -c $csvc -d $deg -h 0 $filename.training.$ratio $filename.training.$ratio.$csvc.model
	svm-predict $filename.testing.$ratio $filename.training.$ratio.$csvc.model $filename.$ratio.$csvc.out >> $results.$csvc
	
	echo >> $results.$csvc
	
	echo "Confusion Matrix"
	confusion-matrix.sh $filename $ratio $dir $csvc >> $results.$csvc
	echo >> $results.$csvc
    done    
}

file=$1
export shuff=$2
transform=$3

PWD=`pwd`
date=$(date +"%Y%m%d%H%M%S")
dir="svmresults_${date}_$4"
mkdir $dir

if [ "$transform" -eq 1 ]; then
    transforms_data $file $dir
else
    ln -s $PWD/$file.sparse $dir/$file.sparse
fi

export filename=$dir/$file.sparse

cat $filename | sort -V > $dir/tmp
mv $dir/tmp $filename

results=$dir/results.dat

#touch $results

for type in 0
do
    if [ "$shuff" -eq 1 ]; then
	shuffle "$filename"
    fi
    
    ratio=70    
    create_datasets $filename $ratio > results_count.dat
    
    for csvc in 4096 2048 1024 256 128 64 32 16 8 4 2 1 0.5 0.25 0.125 0.625 0.03125 0.015625 0.0078125 0.00390625
    do
	if [ "$shuff" -eq 1 ]; then
	    echo "Random" >> $results.$csvc
	fi
       	echo "C-SVC value: $csvc" >> $results.$csvc
	svm $csvc $ratio &
    done
done
