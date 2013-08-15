library(ffbase)
ffload("../data/ff/train")

TOL <- 5
MAX_SEQ <- 10

sampleRate <- tapply(train$T[], train$Device[], mean, trim = 0.05, na.rm = TRUE)
sampleRate <- as.matrix(dist(sampleRate))

devices <- unique(train$Device)[]
outdata <- lapply(devices, function(dev) {
    cat("\nWorking on device", dev)
    sub <- as.data.frame(train[ffwhich(train, Device == dev),])
    n <- floor(nrow(sub) %/% 300 / MAX_SEQ)
    n <- max(c(1, min(MAX_SEQ, n)))
    N <- 600*n
    
    valid <- tail(sub, N)[1:(N / 2),]
    valid$SequenceId <- paste0(dev, "vvv", 0:(N/2-1) %/% 300)
    test <- tail(sub, N/2)
    test$SequenceId <- paste0(dev, "xxx", 0:(N/2-1) %/% 300)

    idx <- which(colnames(sampleRate) == dev)
    weights <- sort(sampleRate[idx,-idx])

    question <- ifelse(rbinom(2*n, 1, 0.5),
                       dev,
                       sample(names(weights)[1:TOL], 2*n, replace = TRUE))

    question <- data.frame(SequenceId = c(unique(valid$SequenceId), unique(test$SequenceId)),
                           QuizDevice = as.numeric(question),
                           answer = dev)
    
    structure(list(sub[1:(nrow(sub) - N)],
                   valid,
                   test,
                   question),
              names = c("train", "valid", "test", "question"))
})

train <- lapply(outdata, "[[", "train")
train <- do.call(rbind, train)
cat("Done making train\n")

valid <- lapply(outdata, "[[", "valid")
valid <- do.call(rbind, valid)
cat("Done making valid\n")

test <- lapply(outdata, "[[", "test")
test <- do.call(rbind, test)
cat("Done making test\n")

questions <- lapply(outdata, "[[", "question")
questions <- do.call(rbind, questions)
cat("Done making questions\n")

save(train, valid, test, questions, file = "../data/cv_train.RData")

cat("Finished")
