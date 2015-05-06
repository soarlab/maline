##############
# libraries
##############

library(caret)
require(doMC)
library(kernlab)
library(foreach)

##############
# basic data
##############

# gives X (covariates) and Y (outcome)
source('./data.R')

index <- 1:nrow(X)

##############
# SVM
##############

#
# tune parameters
#

inner.cores <- 8
outer.cores <- 5

# svmRadial

build.and.test.svm <- function(testindex){
	registerDoMC(cores = inner.cores )
	trainindex <- index[-testindex]
	ctrl <- trainControl(number = 5,
			     method = "cv")
#			     method = "repeatedcv", repeats = 5)
	if(do.seed == TRUE) set.seed(667)
	tgrid <- expand.grid(C=2^seq(-5,15,by=3), sigma=2^seq(-15,3,by=3))
	mod <- train(X[trainindex,], Y[trainindex], method = "svmRadial",
     	     trControl = ctrl,
#     	     preProc = c("center", "scale"),
             tuneGrid = tgrid,
 	     allowParallel=TRUE,
	     prob.model=TRUE)
	list(mod, confusionMatrix(Y[testindex], predict(mod$finalModel,  newdata=X[testindex,])),
	data.frame(predict(mod$finalModel,  newdata=X[testindex,], type="probabilities"), truth=Y[testindex]) )
}

# reproducible research
if(do.seed == TRUE) set.seed(123)

# 5-fold outer cross-validation
folds <- createFolds(index, 5)

l <- mclapply(folds, build.and.test.svm, mc.cores=outer.cores)

tmp <- lapply(l, function(x){ print(x[2]) })

# average the results
print(rowMeans(sapply(l, function(x){ x[[2]]$overall })))
print(rowMeans(sapply(l, function(x){ x[[2]]$byClass })))

# if you would like to save the results uncomment the following line
save(l, file=paste0(output.data.dir, "/svmrbf.list.Rdata"))

