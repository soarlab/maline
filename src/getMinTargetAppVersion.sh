 #!/bin/sh

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

CURR_PID=$$
APPS_FOLDER=$1

declare -a MINVERARR
declare -a TGTVERARR 
for i in `find $APPS_FOLDER -name "*.apk"`
do
    res=$(getAppVersion.sh $i)
    min=$(echo $res | awk -F "," '{ print $1 }')
    tgt=$(echo $res | awk -F "," '{ print $2 }')
    echo $i - $min >> minVersion.txt
    if [[ " ${MINVERARR[*]} " != *" $min "* ]]; then
	MINVERARR+=($min)
    fi
    echo $i - $tgt >> tgtVersion.txt
    if [[ " ${TGTVERARR[*]} " != *" $tgt "* ]]; then
	TGTVERARR+=($tgt)
    fi
done

minSorted=($(printf '%s\n' "${MINVERARR[@]}"|sort -n))
tgtSorted=($(printf '%s\n' "${TGTVERARR[@]}"|sort -n))
echo "Minimum Versions: "${minSorted[@]} > output.txt
echo " Target Versions: "${tgtSorted[@]} >> output.txt
