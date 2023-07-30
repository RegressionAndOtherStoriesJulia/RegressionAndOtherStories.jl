function create_tuple_list(d_str::AbstractString, vars::Union{Vector{Symbol}, Nothing})
    d = d_str[findfirst("{", d_str)[1]+1:findlast("}", d_str)[1]-2]
    s = filter(x->!isspace(x), d)
    s = split.(split(s, ";"), "->")
    if isnothing(vars)
        vars = Vector{Symbol}()
        for e in s
            e = Symbol.(e)
            for n in e
                push!(vars, n)
            end
        end
    end
    tups = Tuple{Int, Int}[]
    for e in s
        e = Symbol.(e)
        push!(tups,
            (findfirst(x -> x == e[1], vars), findfirst(x -> x == e[2], vars)))
    end
    (tups, vars)
end

abstract type AbstractDAG end

mutable struct Path
  f::Int
  l::Int
  path::Vector{Int}
  visited::Vector{Int}
  next_node::Int
end

"""
Directed acyclic graph struct to hold PC algorithm output

### Mutable struct
```julia
DAG(
* `name::AbstractString` : Name for the DAG object
* `g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}` : CausalInference.DiGraph
* `g_tuple_list::Vector{Tuple{Int, Int}}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `g_dot_str::AbstractString` : DAG dot representation (e.g. used for GraphViz)
* `vars::Vector{Symbol}` : Variables in initial DAG
* `est_g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}` : CausalInference.DiGraph
* `est_g_tuple_list::Vector{Tuple{Int, Int}}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `est_g_dot_str::AbstractString` : DAG dot representation (e.g. used for GraphViz)
* `df::DataFrame` : Variable observations
* `cov::NamedArray` : Covariance matrix as NamedArray
)
```

Part of API, exported.
"""
mutable struct PCDAG <: AbstractDAG
    name::AbstractString
    
    # Assumed DAG
    g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    g_tuple_list::Vector{Tuple{Int, Int}}
    g_dot_str::AbstractString
    vars::Vector{Symbol}
    
    #Estimated PCDAG
    est_g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    est_g_tuple_list::Vector{Tuple{Int, Int}}
    est_g_dot_str::AbstractString
    
    # p value used in testing
    p::Float64
    # Df used for est_g
    df::DataFrame
    # Covariance matrix from df
    covm::NamedArray
end


"""
Directed acyclic graph struct to hold FCI algorithm output

### Mutable struct
```julia
DAG(
* `name::AbstractString` : Name for the DAG object
* `g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}` : CausalInference.DiGraph
* `g_tuple_list::Vector{Tuple{Int, Int}}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `g_dot_str::AbstractString` : DAG dot representation (e.g. used for GraphViz)
* `vars::Vector{Symbol}` : Variables in initial DAG
* `est_g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}` : CausalInference.DiGraph
* `est_g_tuple_list::Vector{Tuple{Int, Int}}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `est_g_dot_str::AbstractString` : DAG dot representation (e.g. used for GraphViz)
* `df::DataFrame` : Variable observations
* `cov::NamedArray` : Covariance matrix as NamedArray
)
```

Part of API, exported.
"""
mutable struct FCIDAG <: AbstractDAG
    name::AbstractString
    
    # Assumed DAG
    g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    g_tuple_list::Vector{Tuple{Int, Int}}
    g_dot_str::AbstractString
    vars::Vector{Symbol}
    
    #Estimated FCIDAG
    est_g::MetaGraphs.MetaDiGraph{Int64, Float64}
    est_g_dot_str::AbstractString
    
    # p value used in testing
    p::Float64
    # Df used for est_g
    df::DataFrame
    # Covariance matrix from df
    covm::NamedArray
end

mutable struct GESDAG <: AbstractDAG
    name::AbstractString
    
    # Assumed DAG
    g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    g_tuple_list::Vector{Tuple{Int, Int}}
    g_dot_str::AbstractString
    vars::Vector{Symbol}
    
    #Estimated FCIDAG
    est_g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    est_g_dot_str::AbstractString
    
    # Df used for est_g
    df::DataFrame

    method::Symbol
    
    # penalty value
    penalty::Float64
    score::Float64
    elapsed::Tuple{Float64, Float64}

    # Covariance matrix from df
    covm::NamedArray
end

function create_pc_dag() end
function create_fci_dag() end
function create_ges_dag() end
function create_tuple_list() end
function skeleton_graph() end
function all_paths() end

export
    AbstractDag,
    PCDAG,
    FCIDAG,
    GESDAG,
    create_pc_dag,
    create_fci_dag,
    create_ges_dag,
    Path,
    create_tuple_list,
    skeleton_graph,
    all_paths
    
