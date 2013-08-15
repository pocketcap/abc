library(plyr)
source("createFeatures.R")

## train <- read.csv("../data/train.csv")
## test <- read.csv("../data/test.csv")
print(load("../data/train.RData"))
print(load("../data/test.RData"))
questions <- read.csv("../data/questions.csv")

train <- ddply(train, .(Device), transform, T = diffMilliseconds(T), .progress = "text")

train$T <- diffMilliseconds(train$T)
test$T <- diffMilliseconds(test$T)

train <- ddply(train, .(Device), summarize,
               x = mean(X, trim = 0.01),
               y = mean(Y, trim = 0.01),
               z = mean(Z, trim = 0.01))
test <- ddply(test, .(SequenceId), summarize,
              x = mean(X, trim = 0.01),
              y = mean(Y, trim = 0.01),
              z = mean(Z, trim = 0.01))

library(multicore)
outdata <- mclapply(1:nrow(questions), function(i) {
    cat("Working on question", i, "\n")
    this.q <- questions[i,]

    this.test <- test[test$SequenceId == this.q$SequenceId, c("x", "y", "z")]

    mat <- rbind(train[-1], this.test)

    dist <- as.matrix(dist(mat))
    dist <- dist[-nrow(dist), ncol(dist)]
    names(dist) <- train$Device

    dist <- sort(dist, decreasing = TRUE)
    which(names(dist) == this.q$QuizDevice)
})

outdata <- unlist(outdata)

submit <- data.frame(QuestionId = questions$QuestionId,
                     IsTrue = outdata)

write.csv(submit, file = "../data/submissions/dist_sort.csv", row.names = FALSE)
