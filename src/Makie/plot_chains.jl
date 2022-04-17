function plot_chains(df::DataFrame, par::Vector{Symbol}; no_of_chains=4, no_of_draws=1000)

    df[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    df[!, :chain] = categorical(df.chain)

    fig = Figure()
    for i in 1:length(par)
        let
            plt = data(df) * visual(Lines) * mapping(par[i]; color=:chain)
            axis = (; ylabel="$(par[i])", xlabel="Iteration", title="Traces")
            draw!(fig[i, 1], plt; axis)
        end
        let
            plt = data(df) * mapping(par[i]; color=:chain) * AlgebraOfGraphics.density()
            axis = (; title="Density $(par[i])")
            draw!(fig[i, 2], plt; axis)
        end
    end
    return fig
end

export
    plot_chains
