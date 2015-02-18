##############
# libraries
##############

library(Matrix)
library(caret)
require(doMC)
library(glmnet)

##############
# basic data
##############

# gives X (covariates) and Y (outcome)
source('./data.R')

index <- 1:nrow(X)

##############
# LASSO
##############

inner.cores <- 11

# inner cross-validation
inner.cv <- function(testindex){
	registerDoMC(cores=inner.cores)
	trainindex <- index[-testindex]
	lasso.mod <- cv.glmnet(X[trainindex,], Y[trainindex], alpha=1, family="binomial", type.measure="class", parallel=TRUE)
	list(lasso.mod, confusionMatrix(predict(lasso.mod, s="lambda.min", newx=X[testindex,], type="class"), Y[testindex]),
	data.frame(malware=predict(lasso.mod, s="lambda.min", newx=X[testindex,], type="response"), truth=Y[testindex]) )
}

# reproducible research
if(do.seed == TRUE) set.seed(123) 

# 5-fold outer cross-validation
folds <- createFolds(index, 5)

l <- mclapply(folds, inner.cv)

tmp <- lapply(l, function(x){ print(x[2]) })

# average the results
print(rowMeans(sapply(l, function(x){ x[[2]]$overall })))
print(rowMeans(sapply(l, function(x){ x[[2]]$byClass })))

# if you would like to save the results uncomment the following line
save(l, file=paste0(output.data.dir, "/lasso.mod.list.Rdata"))

