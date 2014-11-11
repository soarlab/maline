#
# This file will prepare the data for classifiers
# It is intended to be sourced from other files
#
# gives matrix X (covariates) and factor Y (outcome)
#

# libs
library(Matrix)

# basic vars
source('./vars.R')

##############
# basic data
##############

D <- readMM(features.file)
X <- D[,-ncol(D)]
Y <- factor(D[,ncol(D)], levels=c(0,1), labels=c("goodware", "malware"))

print(table(Y))

# delete all features that bare no information
zeros <- (apply(X, 2, max) == 0)
X <- X[, !zeros]
