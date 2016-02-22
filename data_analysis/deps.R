options(echo=FALSE)

# dependencies needed to do the data analysis

install.packages(c("caret",
                   "doMC",
                   "e1071",
                   "foreach",
                   "glmnet",
                   "Matrix",
                   "randomForest",
                   "rpart",
                   "rpart.plot",
                   "RRF",
                   "dplyr"),
		 repos="http://cran.us.r-project.org")
