#!/bin/bash

# Directory where lists of non-analyzed files are
LIST_DIR=$1

LIMIT=99
FILE_NAME_PREFIX="$LIST_DIR/app-list"

for i in $(seq 0 $LIMIT); do
    str_i=$(printf "%02d" $i)
    HIGHEST=0

    COUNT=$(ls -1 $FILE_NAME_PREFIX.$str_i-non-analyzed.* 2>/dev/null | wc -l)
    if [ "$COUNT" = "0" ]; then
	continue
    fi

    for f in $(ls -1 $FILE_NAME_PREFIX.$str_i-non-analyzed.* 2>/dev/null); do
	NUM=$((${f##*.}))
	if [ $NUM -gt $HIGHEST ]; then
	    HIGHEST=$NUM
	fi
    done
    cat $(ls -1 $FILE_NAME_PREFIX.$str_i-non-analyzed.$HIGHEST)
done
