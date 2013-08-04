library(plyr)

train <- read.csv("../data/train.csv")
test <- read.csv("../data/test.csv")
questions <- read.csv("../data/questions.csv")

train <- ddply(train, .(Device), summarize,
               x = mean(X),
               y = mean(Y),
               z = mean(Z))
test <- ddply(test, .(SequenceId), summarize,
              x = mean(X),
              y = mean(Y),
              z = mean(Z))

library(multicore)
outdata <- mclapply(1:nrow(questions), function(i) {
    cat("Working on question", i, "\n")
    this.q <- questions[i,]

    this.test <- test[test$SequenceId == this.q$SequenceId, c("x", "y", "z")]

    mat <- rbind(train[-1], this.test)

    dist <- as.matrix(dist(mat))
    dist <- dist[-nrow(dist), ncol(dist)]
    names(dist) <- train$Device

    dist <- sort(dist)
    which(names(dist) == this.q$QuizDevice)
})

outdata <- unlist(outdata)

submit <- data.frame(QuestionId = questions$QuestionId,
                     IsTrue = outdata)

write.csv(submit, file = "../data/submissions/dist_sort.csv", row.names = FALSE)
