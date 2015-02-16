#!/bin/bash

cd vars;
VARS=$(ls -1)
cd ../

for V in $VARS; do
	BASE=$(basename $V ".R")
	echo ${BASE}

	cp -r ../crossvalidation rundir/${BASE}
	cp vars/${V} rundir/${BASE}/vars.R
done

