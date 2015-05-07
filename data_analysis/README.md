# Introduction

Most of the data analysis used in this project is conducted with
[R](http://www.r-project.org) (a free software environment for statistical computing and graphics).
Data analysis was mostly done as a classification task trying to classify
Android applications either to malware or goodware. Classifiers that
are used are:
- Support Vector Machines (ref.)
- Random Forest (ref.)
- LASSO (ref.)
- Ridge (ref.)

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
$ sudo apt-get install build-essential fort77 libreadline-dev
```

## R

If everything went ok in the previous step we can now try to build and install
R from source. As a first task we need to download the source code.
We shall download the source code and install it into our MALINE folder.
Therefore, MALINE environment variable should be set the the path of the
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

## Running
