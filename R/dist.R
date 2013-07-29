source("loadData.R")
library(plyr)
train <- ddply(train, .(Device), summarize,
               x = mean(X), y = mean(Y), z = mean(Z))
test <- ddply(test, .(SequenceId), summarize,
              x = mean(X), y = mean(Y), z = mean(Z))


outdata <- lapply(1:nrow(questions), function(i) {
    cat("Working on question", i, "\n")
    this.q <- questions[i,]

    this.test <- test[test$SequenceId == this.q$SequenceId, c("x", "y", "z")]

    foo <- rbind(train[-1], this.test)

    dist <- as.matrix(dist(as.matrix(foo)))

    this.dist <- dist[-nrow(dist),ncol(dist)]

    1 - this.dist[which(train$Device == this.q$QuizDevice)] / sum(this.dist)
})

save(outdata, file = "../data/submissions/dist.RData")

outdata <- unlist(outdata)

submit <- data.frame(QuestionId = questions$QuestionId,
                     IsTrue = outdata)

write.csv(submit, file = "../data/submissions/dist.csv", row.names = FALSE)
