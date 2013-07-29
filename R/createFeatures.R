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
