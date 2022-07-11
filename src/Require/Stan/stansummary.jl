using .StanSample
import DataFrames: describe
import Base.show

"""

Struct to hold a DataFrame created by stan_summary().

Basically a DataFrame but expects a column "parameters".

Exported

"""
mutable struct StanSummary
    df::DataFrame
end

show(StanSummary) = show(StanSummary.df)

"""

Element selection operator on a StanSummary.

$(SIGNATURES)

Basically a DataFrame but expects a column "parameters".

Exported

"""
function (ss::StanSummary)(par, stat)

    varlocalx = String(par)
    varlocaly = String(stat)
    
    if !(varlocalx in ss.df.parameters)
        @warn "Variable \"$(varlocalx)\" not found in $(ss.df.parameters)."
        return nothing
    elseif !(varlocaly in names(ss.df))
        @warn "Variable $(varlocaly) not found in $(names(ss.df))."
        return nothing
    end
 
    return ss.df[ss.df.parameters .== String(varlocalx), 
        String(varlocaly)][1]
end


"""

Create a StanSummary

$(SIGNATURES)

## Required positional arguments
```julia
* `model::SampleModel` # SampleModel used to create the draws
```

## Optional positional arguments
```julia
* `params` # Vector of Symbols or Strings to be included
```

## Keyword arguments
```julia
* `round_estimates = true` #
* `digits = 3` # Number of decimal digits
```

## Returns

A StanSummary object.


"""
function describe(model::SampleModel, params; 
    round_estimates=true, digits=3)

    if !(typeof(params) in [Vector{String}, Vector{Symbol}])
        @warn "Parameter vector is not a Vector of Strings or Symbols."
        return nothing
    end

    sdf = read_summary(model)
    sdf.parameters = String.(sdf.parameters)
    dfnew = DataFrame()
    for p in String.(params)
        append!(dfnew, sdf[sdf.parameters .== p, :])
    end

    if round_estimates
        colnames = names(dfnew)
        for col in colnames
            if !(col == "parameters")
                dfnew[!, col] = round.(dfnew[:, col]; digits=2)
            end
        end
    end

    StanSummary(dfnew)
end

function describe(model::SampleModel; showall=false)
    sdf = read_summary(model)
    sdf.parameters = String.(sdf.parameters)
    if !showall
        sdf = sdf[8:end, :] 
    end
    StanSummary(sdf)
end

export
    StanSummary,
    describe
