library(ffbase)
library(multicore)
source("auc.R")
ffload("../data/ff/train")
ffload("../data/ff/test")
print(load("../data/questions.RData"))

preds <- mclapply(1:nrow(questions), function(i) {

    cat("Working on question", i, "\n")
    
    this.question <- questions[i,]
    this.device <- this.question$QuizDevice
    
    train.device <- ffwhich(train, train$Device == this.device)
    train.not <- ffwhich(train, train$Device != this.device)
    n.train.device <- length(train.device)
    
    n.mod <- 10
    nm <- 1
    outdata <- replicate(n.mod, {
        cat("Working on model", nm, "\n")
        sub <- sample(train.not, n.train.device)
        
        dat <- rbind(train[sub,], as.data.frame(train[train.device,]))
        dat$y <- c(rep(0, n.train.device), rep(1, n.train.device))
        
        k <- 10
        
        valid <- sample(1:k, nrow(dat), replace = TRUE)
        
        cv <- sapply(1:k, function(j) {
            
            cat("Working on fold", j, "\n")
            
            train.dat <- dat[valid != j,]
            test.dat <- dat[valid == j,]
            
            mod <- glm(y ~ X + Y + Z, data = train.dat, family = binomial(link = "logit"))
            
            pred <- predict(mod, test.dat, type = "response")
            
            auc(test.dat$y, pred)
        })
        
        mod <- glm(y ~ X + Y + Z, data = dat, family = binomial(link = "logit"))
        
        this.test <- ffwhich(test, test$SequenceId == this.question$SequenceId)
        this.test <- as.data.frame(test[this.test,])
        test.pred <- predict(mod, this.test, type = "response")
        
        
        nm <<- nm + 1
        structure(list(mean(test.pred), mean(cv)),
                  names = c("pred", "cv.auc"))
    }, simplify = FALSE)
    
    out.auc <- unlist(lapply(outdata, "[", "cv.auc"))
    out.pred <- unlist(lapply(outdata, "[", "pred"))
    
    weighted.mean(out.pred, out.auc)

})

save(preds, file = "../data/logit_preds.RData")
