"""

nested_column_to_array(df, var)

Create a Vector, Matrix or Array from a column of a DataFrame.

$(SIGNATURES)

### Required arguments
```julia
* `df::DataFrame` : DataFrame
* `var::::Union{Symbol, String}` : Column in the DataFrame
```

This is a generalization of the previously available `matrix()`
function.

Exported
"""
function nested_column_to_array(df::DataFrame, var::Union{Symbol, String})
    if eltype(names(df)) == String
        varlocal = String(var)
        if !(varlocal in String.(names(df)))
            @warn "$(var) not found in df."
            return nothing
        end
    else
        varlocal = Symbol(var)
        if !(varlocal in Symbol.(names(df)))
            @warn "$(var) not found in df."
            return nothing
        end
    end 

    if eltype(df[:, varlocal]) <: Number
        m = Vector(df[:, var])
    elseif eltype(df[:, varlocal]) <: Vector
        m = zeros(nrow(df), length(df[1, varlocal]))
        i = 1 # rownumber
        for (i, r) in enumerate(eachrow(df[:, var]))
            m[i, :] = r[1]
        end
    elseif eltype(df[:, varlocal]) <: Matrix
        m = zeros(size(df[1, varlocal], 1), size(df[1, varlocal], 2), nrow(df))
        i = 1 # rownumber
        for (i, r) in enumerate(eachrow(df[:, var]))
            m[:, :, i] = r[1]
        end
    end
    m
end

export
    nested_column_to_array