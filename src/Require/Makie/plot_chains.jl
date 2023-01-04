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
function plot_chains(df::DataFrame, pars::Vector{Symbol};
    no_of_chains=4, no_of_draws=1000, kwargs...)

    dft = deepcopy(df)

    dft[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    dft[!, :chain] = categorical(dft.chain)

    fig = Figure(resolution = default_figure_resolution)
    for i in 1:length(pars)
        ax = Axis(fig[i, 1]; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
        for j in 1:no_of_chains
            plt = lines!(dft[dft.chain .== j, pars[i]])
        end
        ax = Axis(fig[i, 2]; ylabel="pdf", xlabel="$(pars[i])", title="Density $(pars[i])")
        for j in 1:no_of_chains
            U = kde(dft[dft.chain .== j, pars[i]]; kwargs...)
            den = lines!(U.x, U.density)
            xs = LinRange(minimum(U.x), maximum(U.x), length(U.density))
            ys_low = zeros(length(U.density))
            ys_high = U.density
            band!(xs, ys_low, ys_high; color=:lightgrey)
        end
    end
    return fig
end

function plot_chains(df::DataFrame, pars::Vector{Symbol};
    no_of_chains=4, no_of_draws=1000, kwargs...)

    dft = deepcopy(df)

    dft[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    dft[!, :chain] = categorical(dft.chain)

    fig = Figure(resolution = default_figure_resolution)
    for i in 1:length(pars)
        ax = Axis(fig[i, 1]; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
        for j in 1:no_of_chains
            plt = lines!(dft[dft.chain .== j, pars[i]])
        end
        ax = Axis(fig[i, 2]; ylabel="pdf", xlabel="$(pars[i])", title="Density $(pars[i])")
        for j in 1:no_of_chains
            U = kde(dft[dft.chain .== j, pars[i]]; kwargs...)
            den = lines!(U.x, U.density)
            xs = LinRange(minimum(U.x), maximum(U.x), length(U.density))
            ys_low = zeros(length(U.density))
            ys_high = U.density
            band!(xs, ys_low, ys_high; color=:lightgrey)

        end
    end
    return fig
end

export
    plot_chains
