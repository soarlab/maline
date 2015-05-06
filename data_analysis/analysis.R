##############
# libraries
##############

library(Matrix)
library(e1071)
library(caret)

##############
# basic data
##############

X <- readMM('../data/data_sparse2.mm')
D <- X[,-43682]
Y <- factor(X[,43682], levels=c(0,1), labels=c("goodware", "malware"))

main.ind <- data.frame(ind=1:43681, zeros=TRUE)

# delete all features that bare no information
zeros <- (apply(D, 2, max) == 0)
D <- D[, !zeros]
main.ind[!zeros,"zeros"] <- FALSE


##############
# SVM 
##############

index <- 1:nrow(D)

set.seed(998)
trainindex <- createDataPartition(index, p = 0.75, list = FALSE)[,1]
testindex <- index[-trainindex]
trainset <- D[trainindex, ]
testset <- D[testindex, ]

m <- svm(trainset, Y[trainindex],
#	 type="C", kernel="radial")
	 cost=100, gamma = 1)

m.pred <- predict(m,testset)
confusionMatrix(m.pred, Y[testindex])

m.poly <- svm(D, Y,
	 type="C",
	 kernel="polynomial",
	 degree=1,
	 cross=10)

##############
# Random Forest on equally sized sets
##############

library(randomForest)

full <- as(D, 'matrix')

set.seed(998)
spam656 <- sample(which(Y=="malware"), 656)
ham656 <- which(Y=="goodware")

ind <- c(spam656, ham656)

rf <- randomForest(full[ind,], Y[ind], mtry=8, ntree=200,
		   do.trace=TRUE )


##############
# Feature selection via RRF
##############

library(RRF)

full <- as(D, 'matrix')

# Both the number of features and the quality of the features are 
# quite sensitive to lambda for RRF. A smaller lambda leads to fewer features.
lambda <- 0.8
rrf <- RRF(full,Y,flagReg=1,coefReg=lambda,
	   do.trace=TRUE, mtry=100, ntree=100)
# coefReg is a constant for all variables.
# either "X,as.factor(class)" or data frame
# like "Y~., data=data" is fine, but the later one is significantly slower. 

imp <- rrf$importance
imp <- imp[,"MeanDecreaseGini"]
subsetRRF <- which(imp>0) # produce the indices of the features selected by RRF

# Feature selection via GRRF
rf <- RRF(full,Y, flagReg = 0, # build an ordinary RF 
	   do.trace=TRUE, mtry=100, ntree=100)
impRF <- rf$importance 
impRF <- impRF[,"MeanDecreaseGini"] # get the importance score 
imp <- impRF/(max(impRF)) #normalize the importance scores into [0,1]

gamma <- 0.5   #A larger gamma often leads to fewer features.
#But, the quality of the features selected is quite stable
#for GRRF, i.e., different gammas can have similar accuracy 
#performance (the accuracy of an ordinary RF using the feature subsets).
#See the paper for details.

coefReg <- (1-gamma) + gamma*imp
# each variable has a coefficient, which depends on the 
# importance score from the ordinary RF and the parameter: gamma

grrf <- RRF(full,Y, flagReg=1, coefReg=coefReg,
	   do.trace=TRUE, mtry=100, ntree=100)
imp <- grrf$importance
imp <- imp[,"MeanDecreaseGini"]
subsetGRRF <- which(imp>0) # produce the indices of the features selected by GRRF

print(subsetRRF) #the subset includes many more noisy variables than GRRF
print(subsetGRRF)

# test the quality of subsetGRRF

library(rpart)
library(rpart.plot)

index <- 1:nrow(D)

set.seed(998)
trainindex <- createDataPartition(index, p = 0.75, list = FALSE)[,1]
testindex <- index[-trainindex]
trainset <- D[trainindex, ]
testset <- D[testindex, ]

fit <- rpart(Y[trainindex] ~ . ,
	     data=as.data.frame(full[trainindex, subsetGRRF]))
tmp <- predict(fit, newdata=as.data.frame(full[testindex, subsetGRRF]),
	       type="class")

confusionMatrix(tmp, Y[testindex])

rpart.plot(fit, extra=2)


# 3-fold
fitControl <- trainControl(method = "cv", number = 10)

library(doMC)
registerDoMC(cores = 4)

set.seed(998)
rffit <- train(Y ~ ., data = as.data.frame(full[,subsetGRRF]),
                 method = "rf",
                 trControl = fitControl,
		 do.trace=TRUE)
print(rffit)

svmfit <- train(Y ~ ., data = as.data.frame(full[,subsetGRRF]),
                 method = "svmPoly",
                 trControl = fitControl,
		 degree = 1)
print(svmfit)

rpartfit <- train(Y ~ ., data = as.data.frame(full[,subsetGRRF]),
                 method = "rpart2",
                 trControl = fitControl)
print(rpartfit)

#
# test using original indexes for RRF
#
orig.ind <- (main.ind[ !main.ind$zeros,])[subsetRRF,"ind"]

tmp <- as.data.frame( as(X, 'matrix') )
rffitRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "rf",
                 trControl = fitControl,
		 do.trace=TRUE)
print(rffitRRF)

svmfitRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "svmPoly",
                 trControl = fitControl,
		 degree = 1)
print(svmfitRRF)

rpartfitRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "rpart2",
                 trControl = fitControl)
print(rpartfitRRF)

#
# test using original indexes for GRRF
#
orig.ind <- (main.ind[ !main.ind$zeros,])[subsetGRRF,"ind"]

tmp <- as.data.frame( as(X, 'matrix') )
rffitGRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "rf",
                 trControl = fitControl,
		 do.trace=TRUE)
print(rffitGRRF)

svmfitGRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "svmPoly",
                 trControl = fitControl,
		 degree = 1)
print(svmfitGRRF)

rpartfitGRRF <- train(Y ~ ., data = tmp[,orig.ind],
                 method = "rpart2",
                 trControl = fitControl)
print(rpartfitGRRF)

