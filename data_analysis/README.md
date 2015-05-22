# Introduction

Most of the data analysis used in this project is conducted with
[R](http://www.r-project.org) (a free software environment for statistical computing and graphics).
Data analysis was mostly done as a classification task trying to classify
Android applications either to malware or goodware. Classifiers that
are used are:
- [Support Vector Machines](http://www.support-vector-machines.org/)
- [Random Forest](https://www.stat.berkeley.edu/~breiman/RandomForests/)
- [LASSO](https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html)
- [Ridge](https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html)

# Dependencies

Since we wanted to use the newest (and thus probably the best) version of R and
its packages data analysis was done with R 3.1.1. Packages used are:
- caret (version 6.0-35)
- doMC (version 1.3.3)
- e1071 (version 1.6-4)
- foreach (version 1.4.2)
- glmnet (version 1.9-8)
- Matrix (version 1.1-4)
- randomForest (version 4.6-10)
- rpart (version 4.1-8)
- rpart.plot (version 1.4-4)
- RRF (version 1.6)
- dplyr (version >= 0.2)

# Installation

R version 3.1.1 is not in the official Ubuntu 12.04 LTS repository so
it should be built from the source. To do so appropriate build tools
need to be installed. After build tools are installed and R is built
and installed appropriate R packages should be installed.

## Ubuntu packages

Packages needed to build R-3.1.1 from source can be obtained as follows:

```bash
$ sudo apt-get install build-essential fort77 libreadline-dev gfortran
```

## R

If everything went ok in the previous step we can now try to build and install
R from source. As a first task we need to download the source code.
We shall download the source code and install it into our MALINE directory.
Therefore, MALINE environment variable should be set to the path of the
maline installation.

```bash
$ export MALINE=path_to_maline_directory
```

After we check that MALINE variable exists we can do the following
to download the source code.

```bash
$ cd ${MALINE}
$ mkdir tmp opt
$ cd tmp
$ wget http://cran.at.r-project.org/src/base/R-3/R-3.1.1.tar.gz
```

Once we have the source code it can be built and installed as follows:

```bash
$ tar -xvf R-3.1.1.tar.gz
$ cd R-3.1.1
$ ./configure --with-x=no --prefix=${MALINE}/opt/R-3.1.1/
$ make
$ make install
```

If everything went fine with the previous block of commands R should be
installed under `${MALINE}/opt/R-3.1.1/` directory and can be executed with

```bash
$ ${MALINE}/opt/R-3.1.1/bin/R
```

## R packages

Before starting the data analysis one more step is needed. Installing
appropriate R packages. It can be done as follows:

```bash
$ cd ${MALINE}/data_analysis/
$ ${MALINE}/opt/R-3.1.1/bin/R CMD BATCH --no-save --no-restore ${MALINE}/data_analysis/deps.R
```

# Data analysis

## Concepts

Using feature matrices generated from logs and previously
obtained labels denoting malware/goodware for
applications the classification (data analysis) part can start.
The classification is either performed in R (for random
forest, LASSO, and ridge regression), or using an
off-the-shelf library called libSVM. 

R scripts are provided in this directory.
The scripts are heavily parallelized and adjusted to be run on
clusters or "supercomputers". For example, running a random
forest model on a feature matrix from a system call dependency
graph sample takes at least 32 GB of RAM in
one instance of 5-fold cross-validation.

## Running

### Cross-validation

Scripts to build cross-validated classifiers are given in the
directory *crossvalidation*. File *crossvalidation/vars.R* is of utter
importance since this is the file containing basic information
about the structure of an experiment (classification) that is
to be conducted.

Directory *cv-run* contains scripts to ease model building and validation.
The idea is to copy *vars.R* file from the *crossvalidation* directory
to directory *cv-run/vars/* and appropriately adjust it. Ideally,
the copied file should be renamed to a meaningful name
(e.g. representing the experiment intended to be run).
This can be repeated multiple times to describe multiple experiments.

Executing the *cv-run/cv-setup.sh* will then copy directory *crossvalidation*
to directory *cv-run/rundir/* and adjust the variables as described
in files from *cv-run/vars/* directory. Therefore,
directories in *cv-run/rundir* will contain all the scripts from
*crossvalidation* directory and will be self-sustained.

To execute an experiment now it is just needed to traverse to the appropriate
*cv-run/results* directory and start a script for classification.

After all experiments are over the results can be combined
to a data frame (as a results.csv file) using the *cv-run/combine_results.R*
 script.

***IMPORTANT***: Some scripts contain variables (*inner.cores/outer.cores*)
describing the amount of parallelization intended and should be adjusted
before the start of an experiment.


#### An example of usage

MALINE repo contains a file named *data_sparse2.mm.tar.bz2*.
This is a compressed example of a feature matrix obtained
from the logs for the graph-dependency model. More correctly,
an un(b)zipped file *data_sparse2.mm* contains the
feature matrix and the labels (malware/goodware) in a
sparse matrix format. The last column of this (sparse) matrix
contains the labels. This is the format expected in all
the (classification) scripts in the *crossvalidation* directory.

To evaluate the predictive power of classification
through cross validation with random forest model the
following steps can be used:

```bash
# prepare the feature matrix
$ tar -xvf data_sparse2.mm.tar.bz2

# copy the file *crossvalidation/vars.R* file to 
# directory *cv-run/vars/*:
$ cp crossvalidation/vars.R cv-run/vars/basicexample.R

# edit the copied file and adjust variables
$ cd cv-run
$ editor_of_choice vars/basicexample.R

# execute the *cv-setup.sh* script
$ ./cv-setup.sh

# enter the newly generated directory
$ cd rundir/basicexample/

# use the random forest model
$ ${MALINE}/opt/R-3.1.1/bin/R CMD BATCH --no-restore --no-save randomForest.R

# export the results
$ cd ../../
$ ${MALINE}/opt/R-3.1.1/bin/R CMD BATCH --no-restore --no-save combine_results.R
```

After this the results of the classification should be in the
newly generated file *results.csv*.

