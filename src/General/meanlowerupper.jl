"""
# meanlowerupper

Compute a NamedTuple with means, lower and upper PI values.

$(SIGNATURES)

"""
function meanlowerupper(data, PI = (0.055, 0.945))
    m = mean.(eachrow(data))
    lower = quantile.(eachrow(data), PI[1])
    upper = quantile.(eachrow(data), PI[2])
    return (mean = m,
            lower = lower,
            upper = upper,
            raw = data)
end

export
    meanlowerupper