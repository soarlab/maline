#!/bin/bash

cd vars;
VARS=$(ls -1)
cd ../

for V in $VARS; do
	BASE=$(basename $V ".R")
	echo ${BASE}

	cp -r ../crossvalidation rundir/${BASE}
	cp vars/${V} rundir/${BASE}/vars.R

	sed -i "s/CHANGE_THIS/rundir\/${BASE}/" rundir/${BASE}/randomForest.job
	sed -i "s/CHANGE_THIS/rundir\/${BASE}/" rundir/${BASE}/glmnet-lasso.job
	sed -i "s/CHANGE_THIS/rundir\/${BASE}/" rundir/${BASE}/glmnet-ridge.job
	sed -i "s/CHANGE_THIS/rundir\/${BASE}/" rundir/${BASE}/svmLinear.job
done

