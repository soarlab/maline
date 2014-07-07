#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Illegal number of parameters"
	echo "Use: ${0} INPUT_FILE OUTPUT_FILE"
	exit 1
fi

FEATURES_FILE=$1
FEATURES_FILE_SPARSE=$MALINE/`basename $1`.sparse.tmp
OUTPUT=$2

sparsify $FEATURES_FILE > $FEATURES_FILE_SPARSE

echo "%%MatrixMarket matrix coordinate real general" > $OUTPUT
TMP=`tail -n 1 $FEATURES_FILE_SPARSE | cut -d" " -f1,2`
TMP2=`wc -l $FEATURES_FILE_SPARSE | cut -d" " -f1`
echo "$TMP $TMP2" >> $OUTPUT
cat $FEATURES_FILE_SPARSE >> $OUTPUT
rm -f $FEATURES_FILE_SPARSE
