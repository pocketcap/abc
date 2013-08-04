library(ffbase)
library(multicore)
ffload("../data/ff/train")
ffload("../data/ff/test")
print(load("../data/questions.RData"))

preds <- mclapply(1:nrow(questions), function(i) {

    cat("Working on question", i, "\n")
    
    this.question <- questions[i,]
    this.device <- this.question$QuizDevice
    this.sequence <- this.question$SequenceId
    
    train.device <- ffwhich(train, train$Device == this.device)
    train.not <- ffwhich(train, train$Device != this.device)
    n.train.device <- length(train.device)

    X <- as.data.frame(train[train.device, c("X", "Y", "Z")])
    rows <- sample(train.not[], nrow(X))
    X <- rbind(X, as.data.frame(train[rows, c("X", "Y", "Z")]))
    X$y <- rep(c(1, 0), c(n.train.device, n.train.device))

    mod <- glm(y ~ X + Y + Z, data = X, family = binomial(link = "logit"))

    this.test <- ffwhich(test, test$SequenceId == this.sequence)
    this.test <- as.data.frame(test[this.test,])

    mean(predict(mod, this.test, type = "response"))

})

save(preds, file = "../data/logit_preds.RData")
