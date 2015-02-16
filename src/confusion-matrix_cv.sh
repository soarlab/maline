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

if [ "$#" -lt 3 ]; then
    echo "Usage: confusion-matrix.sh FILENAME FOLD ALG"
    exit 1
fi

testing_file=$1
fold=$2
dir=`pwd`
alg=$3

$(cat $dir/../$testing_file | awk -F " " '{ print $1 }' > $dir/orig_label.dat)

cat $dir/$testing_file.$alg.out | grep -v labels | awk -F " " '{ print $1 }' > tmp.dat
paste orig_label.dat tmp.dat  > $dir/compare.$fold.dat
gNum=$(cat $dir/../$testing_file | awk -F " " '{ print $1 }' | grep "0" | wc -l)
mNum=$(cat $dir/../$testing_file | awk -F " " '{ print $1 }' | grep "1" | wc -l)
goodware=$(cat $dir/compare.$fold.dat | awk -F "\t" '{if ($1 == $2 && $1 == "0") print $1 }' | wc -l)
malware=$(cat $dir/compare.$fold.dat | awk -F "\t" '{if ($1 == $2 && $1 == "1") print $1 }' | wc -l)
wrongGoodware=$(cat $dir/compare.$fold.dat | awk -F "\t" '{if ($1 != $2 && $1 == "0") print $1 }' | wc -l)
wrongMalware=$(cat $dir/compare.$fold.dat | awk -F "\t" '{if ($1 != $2 && $1 == "1") print $1 }' | wc -l)

echo "Testing Set"
echo -e "Number of goodware: "$gNum
echo -e "Number of malware: "$mNum
printf "\t\tgoodware\tmalware\n"
printf "goodware\t%s\t\t%s\n" "$goodware" "$wrongGoodware"
printf " malware\t%s\t\t%s\n" "$wrongMalware" "$malware"

rm -rf $dir/orig_label.dat $dir/compare.$fold.dat $dir/tmp.dat
