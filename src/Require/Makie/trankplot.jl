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
function trankplot(df::DataFrame, param::AbstractString;
        bins=40, n_draws=1000, n_chains=4, n_eff=0, kwargs...)

    nt_args = (n_draws=n_draws, n_chains=n_chains)
    ranks = rank_vector(df[:, param], nt_args)
    
    f = Figure(;size =  default_figure_resolution)
    if n_eff > 0
        ax = Axis(f[1, 1]; 
            title="Trankplot of parameter $(param) (n_eff = $(n_eff))")
    else
        ax = Axis(f[1, 1])
    end
    
    Makie.xlims!(ax, 1, 41)
    colors = [:black, :green, :blue, :red]

    for j in 1:4
        bv = bin_vector(ranks[:, j], 40)
        s = [Meta.parse(string(split(string(cut(bv, 40)[i])[2:4], ":")[1])) for i in 1:40]
        for i in 1:40
            lines!([Float64(i), Float64(i+1)], [s[i], s[i]]; color=colors[j])
            if i == 1
                lines!([Float64(i), Float64(i)], [20, s[i]]; color=colors[j])
                lines!([Float64(i+1), Float64(i+1)], [s[i], s[i+1]]; color=colors[j])
            elseif i < 40
                lines!([Float64(i+1), Float64(i+1)], [s[i], s[i+1]]; color=colors[j])
            elseif i == 40
                lines!([Float64(i+1), Float64(i+1)], [s[i], 20]; color=colors[j])
            end
        end
    end
    f
end

export
    trankplot
