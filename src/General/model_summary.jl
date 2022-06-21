"""

Compute median, mad_sd, mean and std summary of distribition.

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
function model_summary(df::DataFrame, params; 
    round_estimates = true, digits = 3, table_header_type = eltype(params))

    if !(typeof(params) in [Vector{String}, Vector{Symbol}])
        @error "Parameter vector is not a Vector of Strings or Symbols."
        return NamedArray(Float64, 0)
    end

    colnames = names(df)
    col_type = eltype(colnames)
    params_type = eltype(params)
    pars = params_type[]
    
    for par in params
        if col_type(par) in colnames
            append!(pars, [par])
        else
            @warn ":$(par) not in $(colnames), will be dropped."
        end
    end

    if length(pars) > 0
        parameters = Pair{params_type, Int}[]
        estimates = zeros(length(pars), 4)
        for (indx, par) in enumerate(pars)
            if col_type(par) in colnames
                append!(parameters, [par => indx])
                vals = df[:, par]
                estimates[indx, :] = 
                    [median(vals), mad(vals, normalize=true),
                        mean(vals), std(vals)]
            end
        end

        if round_estimates
            estimates = round.(estimates; digits)
        end

        if table_header_type === String
            na = NamedArray(estimates, 
                (OrderedDict(parameters...), 
                OrderedDict("median"=>1, "mad_sd"=>2, "mean"=>3, "std"=>4)),
                ("Parameter", "Value"))
        else
            na = NamedArray(estimates, 
                (OrderedDict(parameters...), 
                OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
                ("Parameter", "Value"))
        end
        
       return na
    else
        @warn "No parameters match the column names in model_df."
        return NamedArray(Float64, 0)
    end
end

export
    model_summary
