#!/bin/bash

[ "$USER" == "vagrant" ] && MALINE=/vagrant

cd ${MALINE}
mkdir tmp opt
cd tmp

# get the source code for R-3.1.1
wget http://cran.at.r-project.org/src/base/R-3/R-3.1.1.tar.gz
if [ $? -ne 0 ]; then
	echo "Error while downloading the source code for R-3.1.1"
	exit 101
fi


tar -xvf R-3.1.1.tar.gz
if [ $? -ne 0 ]; then
	echo "Error while extracting the source code for R-3.1.1"
	exit 102
fi

cd R-3.1.1

./configure --with-x=no --prefix=${MALINE}/opt/R-3.1.1/
if [ $? -ne 0 ]; then
	echo "Error while configuring R-3.1.1"
	exit 103
fi

make
if [ $? -ne 0 ]; then
	echo "Error during the make process for-R 3.1.1"
	exit 104
fi

make install
if [ $? -ne 0 ]; then
	echo "Error during the make install process for R-3.1.1"
	exit 105
fi

cd ${MALINE}/data_analysis/
${MALINE}/opt/R-3.1.1/bin/R CMD BATCH --no-save --no-restore ${MALINE}/data_analysis/deps.R
if [ $? -ne 0 ]; then
	echo "Error during the installation of R packages"
	exit 106
fi

exit 0
