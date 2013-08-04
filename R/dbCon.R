suppressPackageStartupMessages(library(RMySQL))

cred <- readLines("~/mysql_cred.txt")
con <- dbConnect(MySQL(), user = cred[1], dbname = "sbdb", host = cred[3], password = cred[2])

