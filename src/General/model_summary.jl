"""

Compute median, mad_sd, mean and std summary of distribition.

$(SIGNATURES)

## Positional arguments
```julia
* `df::DataFrame` # DataFrame holding the draws
* `pars::Vector{Symbol}` # Vector of symbols to be included
```

## Keyword arguments
```julia
* `digits = 2` # Number of decimal digits
```

"""
function model_summary(model, pars; digits=2)
    parameters = Pair{Symbol, Int}[]
    estimates = zeros(length(pars), 4)
    for (indx, par) in enumerate(pars)
        append!(parameters, [par => indx])
        vals = model[:, par]
        estimates[indx, :] = [median(vals), mad(vals), mean(vals), std(vals)]
    end

    NamedArray(
        round.(estimates; digits=digits), 
        (OrderedDict(parameters...), 
        OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
               ("Parameter", "Value")
    )
end

export
    model_summary
