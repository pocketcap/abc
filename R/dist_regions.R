print(load("../data/train_regions.RData"))
print(load("../data/test_regions.RData"))
questions <- read.csv("../data/questions.csv")

train.device <- train$Device
train <- as.data.frame(scale(train))
test.seq <- test$SequenceId
test <- as.data.frame(scale(test))

train$Device <- test$SequenceId <- NULL

library(multicore)
outdata <- mclapply(1:nrow(questions), function(i) {
    cat("Working on question", i, "\n")
    this.q <- questions[i,]

    this.test <- test[test.seq == this.q$SequenceId,]

    foo <- rbind(train, this.test)

    d <- as.matrix(dist(as.matrix(foo)))

    this.dist <- d[-nrow(d), ncol(d)]

    1 / this.dist[which(train.device == this.q$QuizDevice)]
})

save(outdata, file = "../data/submissions/dist_regions.RData")

outdata <- unlist(outdata)

submit <- data.frame(QuestionId = questions$QuestionId,
                     IsTrue = outdata)

write.csv(submit, file = "../data/submissions/dist_regions.csv", row.names = FALSE)
