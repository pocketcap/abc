library(plyr)

parseMilli <- function(char)
    {
        milli <- as.numeric(gsub(".*([0-9]{3})$", "\\1", char))
        seconds <- as.numeric(gsub("[0-9]{3}$", "", char))

        structure(list(as.POSIXct(seconds, origin = "1970-01-01"),
                       milli),
                  names = c("time", "milliseconds"))
    }
                  

diffMilliseconds <- function(char)
    {
        milli <- as.numeric(gsub("^[0-9]{5}", "", char))
        milli - milli[1]
    }

differential <- function(x, t)
    {
        dx <- c(0, diff(x))
        dt <- c(0, diff(t))

        dx/dt
    }

addRegions <- function(df, test)
    {

        require(plyr)
        
        df$signX <- df$X > 0
        df$signY <- df$Y > 0
        df$signZ <- df$Z > 0
        
        regions <- expand.grid(signX = c(TRUE, FALSE), signY = c(TRUE, FALSE), signZ = c(TRUE, FALSE))
        regions$region <- 1:8
        
        df <- join(df, regions)

        split <- "Device"
        if (test)
            split <- "SequenceId"
        
        df <- ddply(df, split, summarize,
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
        df
    }



## train$T <- diffMilliseconds(train$T)
## test$T <- diffMilliseconds(test$T)

## eigs <- eigen(var(train[c("T", "X", "Y", "Z")]))

## lowd <- as.matrix(train[c("T", "X", "Y", "Z")]) %*% eigs$vectors[,1:2]

## devices <- unique(train$Device)
