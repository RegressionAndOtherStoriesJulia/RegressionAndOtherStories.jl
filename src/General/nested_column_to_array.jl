"""
# nested_column_to_array

Convert a nested column in a DataFrame to an array.

$(SIGNATURES)

## Required arguments
* `df`: DataFrame or ModelSummary object
# `var`: Symbol or String

Exported.

"""
function nested_column_to_array end

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

    if eltype(df[:, varlocal]) <: Vector
        m = zeros(nrow(df), length(df[1, varlocal]))
        i = 1 # rownumber
        for r in eachrow(df[:, var])
            m[i, :] = r[1]
            i += 1
        end
    elseif eltype(df[:, varlocal]) <: Matrix
        m = zeros(nrow(df), size(df[1, varlocal], 1), size(df[1, varlocal], 2))
        i = 1 # rownumber
        for r in eachrow(df[:, var])
            m[:, :, i] = r[1]
            i += 1
        end
    end
    m
end

function nested_column_to_array(ms::ModelSummary, var::Union{Symbol, String})
    if eltype(names(ms.df)) == String
        varlocal = String(var)
        if !(varlocal in String.(names(ms.df)))
            @warn "$(var) not found in ModelSummary object."
            return nothing
        end
    else
        varlocal = Symbol(var)
        if !(varlocal in Symbol.(names(ms.df)))
            @warn "$(var) not found in ModelSummary object."
            return nothing
        end
    end 

    if eltype(ms.df[:, varlocal]) <: Vector
        m = zeros(nrow(ms.df), length(ms.df[1, varlocal]))
        i = 1 # rownumber
        for r in eachrow(ms.df[:, var])
            m[i, :] = r[1]
            i += 1
        end
    elseif eltype(ms.df[:, varlocal]) <: Matrix
        m = zeros(nrow(ms.df), size(ms.df[1, varlocal], 1), size(ms.df[1, varlocal], 2))
        i = 1 # rownumber
        for r in eachrow(ms.df[:, var])
            m[:, :, i] = r[1]
            i += 1
        end
    end
    m
end

export
    nested_column_to_array