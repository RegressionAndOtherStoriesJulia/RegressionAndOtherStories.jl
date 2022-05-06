"""

Binning of a vector (of draws).

$(SIGNATURES)

## Positional arguments
```julia
* `x::AbstractVectir` # DataFrame holding the draws
* `n::Int` # Number of bins
* `rng::AbstractRNG=Random.default_rng()` # Random number generator
```

From [Bogumił Kamiński](https://bkamins.github.io/julialang/2020/12/11/binning.html)

Not exported.

"""
function bin_vector(x::AbstractVector, n::Int, 
    rng::AbstractRNG=Random.default_rng())

    n > 0 || throw(ArgumentError("number of bins must be positive"))
    l = length(x)

    # find bin sizes
    d, r = divrem(l, n)
    lens = fill(d, n)
    lens[1:r] .+= 1
    # randomly decide which bins should be larger
    shuffle!(rng, lens)

    # ensure that we have data sorted by x, but ties are ordered randomly
    df = DataFrame(id=axes(x, 1), x=x, r=rand(rng, l))
    sort!(df, [:x, :r])

    # assign bin ids to rows
    binids = reduce(vcat, [fill(i, v) for (i, v) in enumerate(lens)])
    df.binids = binids

    # recover original row order
    sort!(df, :id)
    return df.binids
end
