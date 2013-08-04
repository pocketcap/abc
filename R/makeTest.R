print(load("../data/test.RData"))

require(plyr)

test$signX <- test$X > 0
test$signY <- test$Y > 0
test$signZ <- test$Z > 0

gc()

seqs <- unique(test$SequenceId)
seqs <- seqs[1:floor(length(seqs) / 2)]

temp1 <- test[test$SequenceId %in% seqs,]
save(temp1, file = "../data/temp1.RData")
rm(temp1)
temp2 <- test[!test$SequenceId %in% seqs,]
rm(test)
save(temp2, file = "../data/temp2.RData")

gc()

regions <- expand.grid(signX = c(TRUE, FALSE), signY = c(TRUE, FALSE), signZ = c(TRUE, FALSE))
regions$region <- 1:8

temp2 <- join(temp2, regions)

gc()

temp2 <- ddply(temp2, .progress = "text", .(SequenceId), summarize,
            x = mean(X),
            y = mean(Y),
            z = mean(Z),
            r1 = mean(region == 1),
            r2 = mean(region == 2),
            r3 = mean(region == 3),
            r4 = mean(region == 4),
            r5 = mean(region == 5),
            r6 = mean(region == 6),
            r7 = mean(region == 7),
            r8 = mean(region == 8))

gc()

save(temp2, file = "../data/temp2_regions.RData")

rm(temp2)
gc()

print(load("../data/temp1.RData"))

temp1 <- join(temp1, regions)

gc()

temp1 <- ddply(temp1, .progress = "text", .(SequenceId), summarize,
            x = mean(X),
            y = mean(Y),
            z = mean(Z),
            r1 = mean(region == 1),
            r2 = mean(region == 2),
            r3 = mean(region == 3),
            r4 = mean(region == 4),
            r5 = mean(region == 5),
            r6 = mean(region == 6),
            r7 = mean(region == 7),
            r8 = mean(region == 8))

gc()

save(temp1, file = "../data/temp1_regions.RData")
