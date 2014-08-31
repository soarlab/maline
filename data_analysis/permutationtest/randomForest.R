##############
# libraries
##############

library(caret)
library(randomForest)
library(parallel)

##############
# basic data
##############

# gives X (covariates) and Y (outcome)
source('./data.R')

index <- 1:nrow(X)

##############
# randomForest
##############

X <- as(X, 'matrix')

build.forest <- function(permutation){
	randomForest(X, Y[permutation], ntree=100, do.trace=TRUE)
}

# reproducible research
set.seed(123)

#
# NOTICE!!!
# random forest will be built on the whole data set
# and only OOB's will be compared
#

# non-permutated data
np.rf <- build.forest(index)

# make permutations of the outcome
n.of.perm <- 80
perm <- replicate(n.of.perm, sample(index), simplify=FALSE)

#cores <- detectCores()-1
cores <- 41
cl <- makeCluster(cores)
# get library support needed to run the code
clusterEvalQ(cl,library(randomForest))

# put objects in place that might be needed for the code
clusterExport(cl,c("Y", "X"))

l <- parLapply(cl, perm, build.forest)

#stop the cluster
stopCluster(cl)


# if you would like to save the results uncomment the following two lines
L <- list(original=np.rf, perm=l)
save(L, file=paste0(output.data.dir, "/perm.randomforest.list.Rdata"))

