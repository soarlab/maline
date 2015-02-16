library(dplyr)

setwd("./vars")
files <- list.files()

br <- 1
for(i in 1:length(files)){
	print(i)
	source(files[i])

	### RF
	L <- list()
	rf.res <- NULL
	fname <- paste0(output.data.dir, "randomforest.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]]))
				       	}))
		L[[br]] <- data.frame(tmp, name=exp.name, classifier="rf")
		br <- br + 1
		rf.res <- rbind_all(L)
	}

	### LASSO
	L <- NULL
	lasso.res <- list()
	fname <- paste0(output.data.dir, "lasso.mod.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		L[[br]] <- data.frame(tmp, name=exp.name, classifier="lasso")
		br <- br + 1
		lasso.res <- rbind_all(L)
		lasso.res <- lasso.res %>% mutate(malware=X1, goodware=1-malware) %>% select(-X1)
	}

	### RIDGE
	L <- list()
	ridge.res <- NULL
	fname <- paste0(output.data.dir, "ridge.mod.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		L[[br]] <- data.frame(tmp, name=exp.name, classifier="ridge")
		br <- br + 1
		ridge.res <- rbind_all(L)
		ridge.res <- ridge.res %>% mutate(malware=X1, goodware=1-malware) %>% select(-X1)
	}

	### SVM Linear
	L <- list()
	svmlinear.res <- NULL
	fname <- paste0(output.data.dir, "svmLinear.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		L[[br]] <- data.frame(tmp, name=exp.name, classifier="svmlinear")
		br <- br + 1
		svmlinear.res <- rbind_all(L)
	}

	### the end :)
}

final <- rbind(rf.res, lasso.res, ridge.res, svmlinear.res)
write.csv(final, file="../results.csv", row.names=FALSE)
