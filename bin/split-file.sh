#!/bin/bash

# Input file to be split
FILE=$1

# Number of chunks the file should be split into
NUM_CHUNKS=$2

FILE_LINES=$(cat $FILE | wc -l)
((LINES_PER_FILE = (FILE_LINES + NUM_CHUNKS - 1) / NUM_CHUNKS))

# Split the file
split --lines=${LINES_PER_FILE} --numeric-suffixes ${FILE} ${FILE}.

# Debug information
echo "Lines in total: $FILE_LINES"
echo "Lines per file: $LINES_PER_FILE"    
