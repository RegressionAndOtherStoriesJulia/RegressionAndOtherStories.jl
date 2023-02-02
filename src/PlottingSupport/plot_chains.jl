"""

Plot the traces and densities of the chains.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame holding the draws
* `pars::Vector{Symbol}` # Vector of Symbols or Strings to be included
```

## Keyword arguments
```julia
* `no_of_chains = 4` # Number of chains
* 'no_of_draws = 1000' # Number of draws (after warmup) in each chain
```

KernelDensity.jl keyword arguments are passed on to `kde()`.

"""
function plot_chains() end

export
    plot_chains
