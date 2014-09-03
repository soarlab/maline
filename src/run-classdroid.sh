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

if [ "$#" -lt 2 ]; then
    echo "Usage: run-classdroid.sh FILENAME SHUFFLE"
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

file=$1
shuff=$2

date=$(date +"%Y%m%d%H%M%S")
dir="svmresults_$date"
mkdir $dir

transforms_data $file $dir

filename=$dir/$file.sparse

cat $filename | sort -V > $dir/tmp
mv $dir/tmp $filename

results=$dir/results.dat

touch $results

h=0 #shrinking

for type in 0 #C-SVC(0) or nu-SVC(1)
do 
    for csvc in 256 128 64 32 16 8 4 2 1 0.5 0.25 0.125 0.625 0.03125 0.015625 0.0078125 0.00390625 #C-SVC(0) or nu-SVC(1)
    do 
       	echo "C-SVC value: $csvc" >> $results
	for ratio in 70 #50% or 90% of training set
	do 
    
	    echo "Testing Set $ratio%" >> $results
	    echo >> $results
	    
	    if [ "$shuff" -eq 1 ]; then
		shuffle "$filename"
		echo "Random" >> $results
	    fi
	    
	    create_datasets $filename $ratio >> $results
	    
	    echo "Linear Kernel" >> $results
	    
	    svm-train -h $h -s $type -t 0 -c $cscv $filename.training.$ratio $filename.training.$ratio.model
	    svm-predict $filename.testing.$ratio $filename.training.$ratio.model $filename.$ratio.out >> $results
	    
	    echo >> $results
	    
	    echo "Confusion Matrix"
	    confusion-matrix.sh $filename $ratio $dir >> $results
	    echo >> $results
	    
	    for deg in 1 2 3 4 #polynomial degree
	    do 
		echo "Polynomial Kernel - Degree $deg" >> $results
		
		svm-train -s 0 -t 1 -d $deg $filename.training.$ratio $filename.training.$ratio.model
		svm-predict $filename.testing.$ratio $filename.training.$ratio.model $filename.$ratio.out >> $results
		
		echo >> $results
		
		echo "Confusion Matrix"
		confusion-matrix.sh $filename $ratio $dir >> $results
		echo >> $results
	    done    
	done
    done
done
