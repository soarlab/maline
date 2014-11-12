##############
# libraries
##############

library(caret)
library(randomForest)
library(ROCR)

##############
# basic data
##############

# gives X (covariates) and Y (outcome)
source('./data.R')

##############
# randomForest
##############

X <- as(X, 'matrix')
index <- 1:nrow(X)

# reproducible research
set.seed(123)
trainIndex <- createDataPartition(index, p = .8,
                                  list = FALSE,
                                  times = 1)


# find the optimal numbers of variables to try splitting on at each node.
bestmtry <- tuneRF(X[trainIndex,], Y[trainIndex], ntreeTry=100,
     stepFactor=1.5, improve=0.01, trace=TRUE, plot=TRUE, dobest=FALSE)

bestmtry <- (bestmtry[order(bestmtry[,2]),])[1,1]

rf <- randomForest(X[trainIndex,], Y[trainIndex], ntree=100,
		  mtry=bestmtry, keep.forest=TRUE, importance=FALSE,
		  do.trace=TRUE)

rf.pr = predict(rf, type="prob", newdata=X[-trainIndex,])[,2]
rf.pred = prediction(rf.pr, Y[-trainIndex])
rf.perf = performance(rf.pred,"tpr","fpr")
plot(rf.perf, main="ROC Curve for Random Forest",
     col=2, lwd=2, xlim=c(0,0.2))

