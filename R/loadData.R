dataDir <- "../data"

## colClasses <- c("character", rep("numeric", 3), "integer")

## questions <- read.csv(file.path(dataDir, "questions.csv"))
## train <- read.csv(file.path(dataDir, "train.csv"), colClasses = colClasses)
## test <- read.csv(file.path(dataDir, "test.csv"), colClasses = colClasses)


print(load(file.path(dataDir, "train.RData")))
print(load(file.path(dataDir, "test.RData")))
print(load(file.path(dataDir, "questions.RData")))
