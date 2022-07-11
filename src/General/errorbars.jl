"""
# errorbars_mean

Compute errorbar DataFrame for the means of columns in a DataFrame.

$(SIGNATURES)

## Required arguments
* `df`: DataFrame
# `p = [0.055, 0.945]`: Probability bounds

## Result

A DataFrame (with a `parameters` column)

Exported.

"""
function errorbars_mean(df, p = [0.055, 0.945])
    se_df = DataFrame()
    for (indx, col) in enumerate(eachcol(df))
        n = length(col)
        est = mean(col)
        se = std(col)/sqrt(n)
        int = [abs.(quantile.(TDist(n-1), p) * se)]
        append!(se_df, DataFrame(parameters = names(df)[indx], estimate = est, se = se, p = [p], q = int))
    end
    se_df
end

"""
# errorbars_draws

Compute errorbar DataFrame for the draws (columns in a DataFrame).

$(SIGNATURES)

## Required arguments
* `df`: DataFrame
# `p = [0.055, 0.945]`: Probability bounds

## Result

A DataFrame (with a `parameters` column)

Exported.

"""
function errorbars_draws(df, p = [0.25, 0.75])
    q_df = DataFrame()
    for (indx, col) in enumerate(eachcol(df))
        m = median(col)
        s = mad(col; normalize=true)
        int = [abs.(quantile(col, p) .- m)]
        append!(q_df, DataFrame(parameters = names(df)[indx], median = m, mad_sd = s, p = [p], q = int))
    end
    q_df
end

export
    errorbars_mean,
    errorbars_draws
