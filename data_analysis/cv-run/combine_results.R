library(dplyr)

setwd("./vars")
files <- list.files()

L <- list()

br <- 1
for(i in 1:length(files)){
	print(i)
	source(files[i])

	### RF
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
		rf.res <- data.frame(tmp, name=exp.name, classifier="rf")
	}

	### LASSO
	lasso.res <- NULL
	fname <- paste0(output.data.dir, "lasso.mod.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		lasso.res <- data.frame(tmp, name=exp.name, classifier="lasso")
		lasso.res <- lasso.res %>% mutate(malware=X1, goodware=1-malware) %>% select(-X1)
	}

	### RIDGE
	ridge.res <- NULL
	fname <- paste0(output.data.dir, "ridge.mod.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		ridge.res <- data.frame(tmp, name=exp.name, classifier="ridge")
		ridge.res <- ridge.res %>% mutate(malware=X1, goodware=1-malware) %>% select(-X1)
	}

	### SVM Linear
	svmlinear.res <- NULL
	fname <- paste0(output.data.dir, "svmLinear.list.Rdata")
	if(file.exists(fname)){
		load(fname)
		tmp <- rbind_all(lapply(1:length(l),
				       	function(i){
					       	data.frame(l[[i]][[3]],
								  fold=i,
								  id=1:nrow(l[[i]][[3]])) }))
		svmlinear.res <- data.frame(tmp, name=exp.name, classifier="svmlinear")
	}

	L[[i]] <- rbind(rf.res, lasso.res, ridge.res, svmlinear.res)
}

final <- rbind_all(L)
write.csv(final, file="../results.csv", row.names=FALSE)
