if !isdefined(Main, :StanSample)
    import DataFrames: getindex

    function getindex(df::DataFrame, r::T, c) where {T<:Union{Symbol, String}}
        colstrings = String.(names(df))
        if !("parameters" in colstrings)
            @warn "DataFrame `df` does not have a column named `parameters`."
            return nothing
        end
        if eltype(df.parameters) <: Union{Vector{String}, Vector{Symbol}}
            @warn "DataFrame `df.parameters` is not of type `Union{String, Symbol}'."
            return nothing
        end
        rs = String(r)
        cs = String(c)
        if !(rs in String.(df.parameters))
            @warn "Parameter `$(r)` is not in $(df.parameters)."
            return nothing
        end
        if !(cs in colstrings)
            @warn "Statistic `$(c)` is not in $(colstrings)."
            return nothing
        end
        return df[df.parameters .== rs, cs][1]
    end
end

"""

Compute median, mad_sd, mean and std summary of distribution.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame holding the draws
* `params` # Vector of Symbols or Strings to be included
```

## Keyword arguments
```julia
* `round_estimates=true` # Round to `digits` decimals.
* `digits = 3` # Number of decimal digits
* `table_header_type=eltype(params)` # Symbol or String
```

"""
function model_summary(df::DataFrame, params::T; 
    round_estimates = true, digits = 3) where T <: Vector

    if !(typeof(params) in [Vector{String}, Vector{Symbol}])
        @error "Parameter vector is not a Vector of Strings or Symbols."
        return nothing
    end

    colnames = String.(names(df))
    prs = String.(params)

    pars = String[]
    for par in prs
        if par in colnames
            append!(pars, [par])
        else
            @warn ":$(par) not in $(colnames), will be dropped."
        end
    end

    if length(pars) > 0
        dfnew = DataFrame()
        dfnew[!, "parameters"] = String.(pars)
        estimates = zeros(length(pars), 4)
        for (indx, par) in enumerate(pars)
            if par in colnames
                vals = df[:, par]
                estimates[indx, :] = 
                    [median(vals), mad(vals, normalize=true),
                        mean(vals), std(vals)]
            end
        end

        if round_estimates
            estimates = round.(estimates; digits)
        end

        dfnew[!, "median"] = estimates[:, 1]
        dfnew[!, "mad_sd"] = estimates[:, 2]
        dfnew[!, "mean"] = estimates[:, 3]
        dfnew[!, "std"] = estimates[:, 4]
    end
    dfnew
end

export
    model_summary
