library(ffbase)
## source("createFeatures.R")

## print(load("../data/train.RData"))
## date <- parseMilli(train$T)
## train$T <- as.numeric(date$time)
## train$milli <- date$milliseconds
## train <- as.ffdf(train)
## ffsave(train, file = "/vol/data/kaggle/abc/ff/train")

## print(load("../data/test.RData"))
## date <- parseMilli(test$T)
## test$T <- as.numeric(date$time)
## test$milli <- date$milliseconds
## test <- as.ffdf(test)
## ffsave(test, file = "/vol/data/kaggle/abc/ff/test")



### make db as well
source("dbCon.R")
ffload("/vol/data/kaggle/abc/ff/train")
train <- as.data.frame(train)
cat("Writing train to MySQL\n")
dbWriteTable(con, "kaggleABCtrain", train)

rm(train)

ffload("/vol/data/kaggle/abc/ff/test")
test <- as.data.frame(test)
cat("Writing test to MySQL")
dbWriteTable(con, "kaggleABCtest", test)

closeAllConnections()
