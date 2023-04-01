module CausalInferenceExt

using DocStringExtensions
using RegressionAndOtherStories

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: DAG, dseparation, create_dag, update_dag!, update_dag_est_g!
import CausalInference: backdoor_criterion


"""
Undate DAG components

$(SIGNATURES)

### Required arguments
```julia
* `d::DAG` : DAG object
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
function create_dag(name::AbstractString, df::DataFrame, p=0.1;
    g_dot_repr::Union{AbstractString, Nothing}=nothing,
    est_func=gausscitest)
    
    d = create_dag(name)
    d.df = df
    d.p = p

    if !isnothing(g_dot_repr)
        update_dag!(d, df; g_dot_repr) # Defined in ROS
    end

    update_dag_est_g!(d, df, p; est_func)

    d
end

function update_dag_est_g!(d::DAG, df::DataFrame, p::Float64=0.1; est_func=gausscitest)
    
    d.df = df
    d.p = p

    d.est_g = CausalInference.pcalg(df, p, est_func)

    # Create vars OrderedSet{Symbol}
    d.est_vars = OrderedSet{Symbol}()
    for v in Symbol.(names(df))
        if !(v in d.est_vars)
            push!(d.est_vars, v)
        end
    end
        
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

"""
Test for a backdoor, Returns true or false.

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
function backdoor_criterion(d::DAG, from::Symbol, to::Symbol, s::Vector{Symbol}=Symbol[]; verbose=false)
    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    backdoor_criterion(d.g, f, l, cond; verbose)
end

end
