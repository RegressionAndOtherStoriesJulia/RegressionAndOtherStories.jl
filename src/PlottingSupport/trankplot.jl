"""

Create a trankplot.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame holding the draws
* `param::AbstractString` # Symbol to use
```

## Keyword arguments
```julia
* `bins = 40` # Number of bins
* `n_draws = 1000` # Number of draws in df
* `n_chains = 4` # Number of chains appended in df
* `n_eff = 0` # Effective number of samples
```

"""
function trankplot() end

export
    trankplot
