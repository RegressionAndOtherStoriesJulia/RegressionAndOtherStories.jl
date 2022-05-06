using Parameters

"""

Rank a vector.

$(SIGNATURES)

## Positional arguments
```julia
* `x::Vector` # Vector of the draws
* `nt_args::NamedTuple` # NamedTuple specifying n_draws and n_chains in x
```

Not exported.

"""
function rank_vector(x::Vector{Float64}, nt_args::NamedTuple)
    @unpack n_draws, n_chains = nt_args
    xc = zeros(Int, n_draws, n_chains)
    ranked = Int.(ordinalrank(x))
    for j in 1:n_chains
        start_draw = (j-1) * n_draws + 1
        last_draw = j * n_draws
        xc[:, j] = ranked[start_draw:last_draw]
    end
    xc
end
