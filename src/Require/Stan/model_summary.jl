import RegressionAndOtherStories: model_summary

"""

Create a NamedArray from the output created by Stan's `stansummary` executable.

$(SIGNATURES)

## Required positional arguments
```julia
* `model::SampleModel` # SampleModel used to create the draws
```

## Opyional poistional arguments
* `params` # Vector of Symbols or Strings to be included
```

If `params` is not present, an abbreviated version of
read_samples() is shown (but as a DataFrame, not a NamedArray!).

## Keyword arguments
```julia
* `round_estimates = true` #
* `digits = 3` # Number of decimal digits
* `table_header_type` # Default:Symbols or Strings as eltype(params).
```

## Returns

Either a NamedArray or a DataFrame. A Dataframe is nicer for display in
Pluto notebooks, a NamedArray is easier to select individual entries.


"""
function model_summary(model::SampleModel, params;
    round_estimates=true, digits=3, table_header_type=eltype(params))

    if !(typeof(params) in [Vector{String}, Vector{Symbol}])
        @warn "Parameter vector is not a Vector of Strings or Symbols."
        return NamedArray(Float64, 0)
    end

    sdf = read_summary(model)
    params_type = eltype(params)
    
    stats = names(sdf)
    stats[8] = "n_eff"
    stats = table_header_type.(stats)
    items = [2,4,5,6,7,8,10]
    
    # Remove unwanted rows and create parameter pairs
    count = 1
    df = DataFrame()
    parameters = Pair{params_type, Int}[]
    for (index, par) in enumerate(params_type.(sdf[:, :parameters]))
        if par in params
            push!(df, sdf[index, items])
            append!(parameters, [par => count])
            count += 1
        end
    end
    
    statistics = Pair{table_header_type, Int}[]
    for (index, stat) in enumerate(stats[items])
        append!(statistics, [stat => index])
    end

    if round_estimates
        estimates = round.(Array(df); digits)
    else
        estimates = Array(df)
    end
    
    return NamedArray(
        estimates,
        (OrderedDict(parameters...), OrderedDict(statistics...)),
        ("Par", "Stat")
    )

end

function model_summary(model::SampleModel)
    sdf = read_summary(model)
    return sdf[8:end, [1, 2, 4, 5, 6, 7, 8, 10]]
end

