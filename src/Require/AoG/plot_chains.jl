"""

Plot the traces and densities of the chains.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame holding the draws
* `pars::Vector{Symbol}` # Vector of symbols to be included
```

## Keyword arguments
```julia
* `no_of_chains = 4` # Number of chains
* 'no_of_draws = 1000' # Number of draws (after warmup) in each chain
```

"""
function plot_chains(df::DataFrame, pars::Vector{Symbol};
    no_of_chains=4, no_of_draws=1000)

    df[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    df[!, :chain] = categorical(df.chain)

    fig = Figure()
    for i in 1:length(pars)
        let
            plt = data(df) * visual(Lines) * mapping(pars[i]; color=:chain)
            axis = (; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
            draw!(fig[i, 1], plt; axis)
        end
        let
            plt = data(df) * mapping(pars[i]; color=:chain) * AlgebraOfGraphics.density()
            axis = (; title="Density $(pars[i])")
            draw!(fig[i, 2], plt; axis)
        end
    end
    return fig
end

export
    plot_chains
