##############
# libraries
##############

library(caret)
require(doMC)
library(randomForest)
library(foreach)

##############
# basic data
##############

# gives X (covariates) and Y (outcome)
source('./data.R')

index <- 1:nrow(X)

##############
# randomForest
##############

inner.cores <- 11
outer.cores <- 4

X <- as(X, 'matrix')

build.and.test.forest <- function(testindex){
	registerDoMC(inner.cores) 
	trainindex <- index[-testindex]
	ff <- foreach(y=seq(inner.cores), .combine=combine ) %dopar% {
		if(do.seed == TRUE) set.seed(testindex[y])
   		rf <- randomForest(X[trainindex,], Y[trainindex], ntree=50, norm.votes=FALSE) #, do.trace=TRUE)
	}
	list(ff, confusionMatrix(Y[testindex], predict(ff,  newdata=X[testindex,])),
	data.frame(predict(ff,  newdata=X[testindex,], type="prob"), truth=Y[testindex]) )
}

# reproducible research
if(do.seed == TRUE) set.seed(123)

# 5-fold outer cross-validation
folds <- createFolds(index, 5)

l <- mclapply(folds, build.and.test.forest, mc.cores=outer.cores)

tmp <- lapply(l, function(x){ print(x[2]) })

# average the results
print(rowMeans(sapply(l, function(x){ x[[2]]$overall })))
print(rowMeans(sapply(l, function(x){ x[[2]]$byClass })))

# if you would like to save the results uncomment the following line
save(l, file=paste0(output.data.dir, "/randomforest.list.Rdata"))

