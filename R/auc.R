auc <- function(outcome, proba)
    {
        N = length(proba)
        N_pos = sum(outcome)
        df = data.frame(out = outcome, prob = proba)
        df = df[order(-df$prob),]
        df$above = (1:N) - cumsum(df$out)
        return( 1- sum( df$above * df$out ) / (N_pos * (N-N_pos) ) )
    }
