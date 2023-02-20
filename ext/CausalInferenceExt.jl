module CausalInferenceExt

using RegressionAndOtherStories, Graphs, DocStringExtensions, NamedArrays

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: DAG, dag, sort_nodes, construct_dag, set_dag_df!, set_dag_cov_matrix!

"""
Sort nodes in lhs, both and rhs. Also create vars vector.

$(SIGNATURES)

## Required arguments
* `edges::Vector{Tuple{Symbol, Symbol}}` : Vector of edges, e.g. [(:a, :b), (:a, :c), ...]

## Returns
* `NamedTuple` : (lhs=..., both=..., rhs=..., vars=...)

Exported, will be updated in the future.
"""
function sort_nodes(edges::Vector{Tuple{T, T}}) where {T <: Symbol}
    lhs = OrderedSet()
    both = OrderedSet()
    rhs = OrderedSet()
    for (ind, edge) in enumerate(edges)
        if !(edge[1] in both) && !(edge[1] in rhs)
            push!(lhs, edge[1])
        end
    end
    for (ind, edge) in enumerate(edges)
        if edge[2] in lhs
            push!(both, edge[2])
            setdiff!(lhs, [edge[2]])
        elseif !(edge[2] in rhs)
            push!(rhs, edge[2])
        end
    end
    setdiff!(rhs, both)
    vars = Symbol[]
    for s in vcat(lhs, both, rhs)
        for e in s
            push!(vars, Symbol.(e))
        end
    end

    (lhs=lhs, both=both, rhs=rhs, vars=vars)
end

"""
DAG constructor

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
function dag(dag_name::AbstractString, model::Vector{Tuple{Symbol, Symbol}};
    df::Union{DataFrame, Nothing}=nothing, covm::Union{NamedArray, Nothing}=nothing,
    use_chickering_order=true)

    local e
    if typeof(model) <: Vector{Tuple{Symbol, Symbol}}
        e = model
    end    

    a_tuple = []
    a_digraph = "digraph $dag_name {"

    lhs, both, rhs, vars = sort_nodes(e)

    for sym in Symbol.(lhs)
        for edge in e
            if edge[1] == sym
                push!(a_tuple, (findfirst(x -> x == edge[1], vars), findfirst(x -> x == edge[2], vars)))
            end
        end
    end
    for sym in Symbol.(both)
        for edge in e
            if edge[1] == sym
                push!(a_tuple, (findfirst(x -> x == edge[1], vars), findfirst(x -> x == edge[2], vars)))
            end
        end
    end

    g = DiGraph(length(vars))
    for (i, j) in a_tuple
        add_edge!(g, i, j)
    end

    if use_chickering_order
        co = CausalInference.chickering_order(g)
        os = OrderedSet{Int}()
        for c in co
            push!(os, c[1])
            push!(os, c[2])
        end

        a_tuple = []
        for p in co
            push!(a_tuple, (p[1], p[2]))
        end

        g = DiGraph(length(vars))
        for (i, j) in a_tuple
            add_edge!(g, i, j)
        end
    end

    for edge in a_tuple
        a_digraph = a_digraph * "$(vars[edge[1]]) -> $(vars[edge[2]]);"
    end
    a_digraph = a_digraph * "}"

    c = covm
    if !isnothing(df) && isnothing(c)
        #!isnothing(c) && @warn "New covariance matrix computed from df."
        @assert length(names(df)) == length(vars) "DataFrame has different number of columns"

        # Compute covariance matrix and store as NamedArray
        c = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
    end

    # Create DAG object

    DAG(dag_name, e, a_tuple, a_digraph, g, vars, df, c)

end

"""
DAG constructor from an estimated (pcalg) graph.

$(SIGNATURES)

### Required arguments
```julia
* `name::AbstractString` : Name for the DAG object
* `g::Graphs.SimpleGraphs.SimpleDiGraph` : Estimated using `pcalg()`
* `d::DAG` : Original DAG
```

The fields `d.df` and `d.covm` will be included in the new DAG.

### Returns
```julia
* `dag::DAG` : Newly created DAG holding the estimated graph
```

Part of API, exported.
"""
function dag(dag_name::AbstractString, g::T, d::DAG) where
    {T <: Graphs.SimpleGraphs.SimpleDiGraph{Int}}
    #println(g.fadjlist)
    a_tuple = Tuple{Symbol, Symbol}[]

    for (f, edge) in enumerate(g.fadjlist)
        for l in edge
            push!(a_tuple, (d.v[f], d.v[l]))
        end
    end
    dag(dag_name, a_tuple; df=d.df, covm=d.covm, use_chickering_order=false)
end

"""
Set or update Dataframe associated to DAG

$(SIGNATURES)

### Required arguments
```julia
* `d::DAG`                                  : Previously defined DAG object 
* `df::DataFrameOrNothing`                  : DataFrame associated with DAG
)
```

### Optional arguments
```julia
* `force=false`                             : Force assignment of df 
)
```

The `force = true` option can be used if the DAG involves unobserved nodes.

Part of API, exported.
"""
function set_dag_df!(d::DAG, df::Union{DataFrame, Nothing}; force=false)
  # Compute covariance matrix and store as NamedArray

  if !(force || df == nothing)
    @assert length(names(df)) == length(d.v) "DataFrame has different number of columns"
    @assert names(df, 1) !== d.v "DataFrame names differ from DAG variable names"
  end

  d.df = df
  if df == nothing || nrow(df) == 0
    d.cov = nothing
  else
    if nrow(df) > 1 && length(names(df)) > 0
      d.cov = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
    else
      d.cov = nothing
    end
  end

end  

"""
Set or update the covariance matrix associated to DAG

$(SIGNATURES)

### Required arguments
```julia
* `d::DAG`                                  : Previously defined DAG object 
* `cm::NamedArrayOrNothing`                 : Covariance matrix in NamedArray format
)
```

### Optional arguments
```julia
* `force=false`                             : Force assignment of df 
)
```

The `force = true` option can be used if the DAG involves unobserved nodes.

Part of API, exported.
"""
function set_dag_cov_matrix!(d::DAG, cm::Union{NamedArray, Nothing}; force=false)
  # Compute covariance matrix and store as NamedArray

  if !(force || cm == nothing)
    @assert length(names(cm)) == length(d.v) "Covariance matrix has different number of columns"
    @assert names(cm) !== d.v "Covariance matrix names differ from DAG variable names"
  end

  if cm == nothing
    d.cov = nothing
  else
    d.cov = cm
  end

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
        push!(cond, findfirst(x -> x == sym, d.v))
    end
    dsep(d.g, findfirst(x -> x == f, d.v), findfirst(x -> x == l, d.v), cond; kwargs...)
end

RegressionAndOtherStories.dseparation(d::DAG, f::Symbol, l::Symbol; kwargs...) =
    RegressionAndOtherStories.dseparation(d, f, l, Symbol[]; kwargs...)

end
