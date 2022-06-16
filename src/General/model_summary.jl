"""

Compute median, mad_sd, mean and std summary of distribition.

$(SIGNATURES)

## Positional arguments
```julia
* `model_df::DataFrame` # DataFrame holding the draws
* `pars` # Vector of Symbols or Strings to be included
```

## Keyword arguments
```julia
* `digits = 2` # Number of decimal digits
* `table_headers` # Default:Symbols or Strings as eltype(pars).
```

"""
function model_summary(model_df::DataFrame, params::Vector{String}; 
    digits = 2, table_headers = String)

    colnames = String.(names(model_df))
    pars = String[]
    
    for par in params
        if par in colnames
            append!(pars, [par])
        else
            @warn ":$(par) not in $(colnames), will be dropped."
        end
    end

    if length(pars) > 0
        parameters = Pair{String, Int}[]
        estimates = zeros(length(pars), 4)
        for (indx, par) in enumerate(pars)
            if par in colnames
                append!(parameters, [par => indx])
                vals = model_df[:, par]
                estimates[indx, :] = 
                    [median(vals), mad(vals, normalize=false),
                        mean(vals), std(vals)]
            end
        end

        if table_headers === String
            na = NamedArray(round.(estimates; digits=digits), 
                (OrderedDict(parameters...), 
                OrderedDict("median"=>1, "mad_sd"=>2, "mean"=>3, "std"=>4)),
                ("Parameter", "Value"))
        else
            na = NamedArray(round.(estimates; digits=digits), 
                (OrderedDict(parameters...), 
                OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
                ("Parameter", "Value"))
        end
        
       return na
    else
        @warn "No parameters match the column names in model_df."
        return nothing
    end
end

function model_summary(model_df::DataFrame, params::Vector{Symbol} = Symbol.(names(model_df)); 
    digits = 2, table_headers=Symbol)
    
    colnames = Symbol.(names(model_df))
    pars = Symbol[]
    
    for par in params
        if par in colnames
            append!(pars, [par])
        else
            @warn ":$(par) not in $(colnames), will be dropped."
        end
    end

    if length(pars) > 0
        parameters = Pair{Symbol, Int}[]
        estimates = zeros(length(pars), 4)
        for (indx, par) in enumerate(pars)
            if par in colnames
                append!(parameters, [par => indx])
                vals = model_df[:, par]
                estimates[indx, :] = 
                    [median(vals), mad(vals, normalize=false),
                        mean(vals), std(vals)]
            end
        end

        if table_headers === String
            na = NamedArray(round.(estimates; digits=digits), 
                (OrderedDict(parameters...), 
                OrderedDict("median"=>1, "mad_sd"=>2, "mean"=>3, "std"=>4)),
                ("Parameter", "Value"))
        else
            na = NamedArray(round.(estimates; digits=digits), 
                (OrderedDict(parameters...), 
                OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
                ("Parameter", "Value"))
        end
        
        return na
   else
        @warn "No parameters match the column names in model_df."
        return nothing
    end
end

export
    model_summary
