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

"""
function plot_chains(df::DataFrame, pars::Vector{Symbol};
    no_of_chains=4, no_of_draws=1000)

    dft = deepcopy(df)

    dft[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    dft[!, :chain] = categorical(dft.chain)

    fig = Figure()
    for i in 1:length(pars)
        ax = Axis(fig[i, 1]; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
        for j in 1:no_of_chains
            plt = lines!(dft[dft.chain .== j, pars[i]])
        end
        ax = Axis(fig[i, 2]; ylabel="pdf", xlabel="$(pars[i])", title="Density $(pars[i])")
        den = density!(dft[:, pars[i]])
    end
    return fig
end

function plot_chains(df::DataFrame, pars::Vector{String};
    no_of_chains=4, no_of_draws=1000)

    dft = deepcopy(df)

    dft[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    dft[!, :chain] = categorical(dft.chain)

    fig = Figure()
    for i in 1:length(pars)
        ax = Axis(fig[i, 1]; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
        for j in 1:no_of_chains
            plt = lines!(dft[dft.chain .== j, pars[i]])
        end
        ax = Axis(fig[i, 2]; ylabel="pdf", xlabel="$(pars[i])", title="Density $(pars[i])")
        den = density!(dft[:, pars[i]])
    end
    return fig
end

export
    plot_chains
