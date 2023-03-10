module CausalInferenceExt

using DocStringExtensions
using RegressionAndOtherStories

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: DAG, dseparation, create_dag, update_dag!


"""
Compute the estimated graph from a df

$(SIGNATURES)

### Required arguments
```julia
* `name::AbstractString` : Name for the DAG object
* `e::Vector{Tuple{Symbol, Symbol}}` : E.g. [(:a, :b), (:b, :c), (:a, :c)]
```

### Keyword arguments
```julia
* `df::DataFrame` : DataFrame with observations
* `covm::NamedArray` : Covariance matrix of observations
```

### Returns
```julia
* `dag::DAG` : Newly created DAG
```

Part of API, exported.
"""
function RegressionAndOtherStories.create_dag(name::AbstractString, df::DataFrame,  p=0.25;
    g_dot_repr::Union{AbstractString, Nothing}=nothing)
    
    d = create_dag(name)
    if !isnothing(g_dot_repr)
        update_dag!(d, g_dot_repr)
    end
    if !isnothing(df) 
        update_dag!(d, df, p)
    end

    d
end


function update_dag!(d::DAG, df::DataFrame, p=0.1)
    
    d.df = df
    d.est_vars = OrderedSet{Symbol}()
    for v in Symbol.(names(df))
        if !(v in d.est_vars)
            push!(d.est_vars, v)
        end
    end
        
    d.est_g = CausalInference.pcalg(df, p, gausscitest)

    # Create d.est_tuple_list
    d.est_g_tuple_list = Tuple{Symbol, Symbol}[]
    for (f, edge) in enumerate(d.est_g.fadjlist)
        for l in edge
            push!(d.est_g_tuple_list, (f, l))
        end
    end
    
    # Create d.est_g_dot_repr
    d.est_g_dot_repr = "digraph est_g_$(d.name) {"
    for e in d.g_tuple_list
        f = d.est_vars[e[1]]
        l = d.est_vars[e[2]]
        if length(setdiff(d.est_g_tuple_list, [(e[2], e[1])])) !==
            length(d.est_g_tuple_list)
            
            d.est_g_dot_repr = d.est_g_dot_repr * "$(f) -> $(l) [color=red, arrowhead=none];"
        else
            d.est_g_dot_repr = d.est_g_dot_repr * "$(f) -> $(l);"
        end
    end
    d.est_g_dot_repr = d.est_g_dot_repr * "}"

    # Compute est_g and covariance matrix (as NamedArray)
    d.covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    return nothing
end

"""
Test for d-separation, Returns true or false.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG object
* `f::Symbol` : First symbol of path in graph
* `l::Symbol` : Last symbol of path in graph

## Optional arguments
* `s:Vector{Symbol}` : Conditioning set of nodes
* `kwargs` : Passed on to `dsep()`

## Returns
* `true or false`

Exported
"""
function RegressionAndOtherStories.dseparation(d::DAG, f::Symbol, l::Symbol, s::Vector{Symbol}; kwargs...)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end
    dsep(d.g, findfirst(x -> x == f, d.vars), findfirst(x -> x == l, d.vars), cond; kwargs...)
end

RegressionAndOtherStories.dseparation(d::DAG, f::Symbol, l::Symbol; kwargs...) =
    RegressionAndOtherStories.dseparation(d, f, l, Symbol[]; kwargs...)

end
