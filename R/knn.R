dataDir <- "../data"

questions <- read.csv(file.path(dataDir, "questions.csv"))
train <- read.csv(file.path(dataDir, "train.csv"))
test <- read.csv(file.path(dataDir, "test.csv"))

library(plyr)
train <- ddply(train, .(Device), summarize,
               x = mean(X), y = mean(Y), z = mean(Z))
test <- ddply(test, .(SequenceId), summarize,
              x = mean(X), y = mean(Y), z = mean(Z))

library(class)
library(multicore)
outdata <- mclapply(1:nrow(questions), function(i) {
    cat("Working on question", i, "\n")
    this.q <- questions[i,]

    this.test <- test[test$SequenceId == this.q$SequenceId, c("x", "y", "z")]

    y <- train$Device == this.q$QuizDevice

    knn(train[c("x", "y", "z")], this.test, cl = y)
})


submit <- data.frame(QuestionId = questions$QuestionId,
                     IsTrue = as.numeric(unlist(outdata)) - 1)

write.csv(submit, file = "../data/submissions/knn_benchmark.csv", row.names = FALSE)
