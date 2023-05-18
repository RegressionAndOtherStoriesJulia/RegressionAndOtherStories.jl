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

"""
Directed acyclic graph struct

$(SIGNATURES)

### Mutable struct
```julia
DAG(
* `name::Union{AbstractString, Nothing}` : Name for the DAG object
* `g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}` : CausalInference.DiGraph
* `g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `g_dot_str::Union{AbstractString, Nothing}` : DAG dot representation (e.g. used for GraphViz)
* `vars::Union{Vector{Symbol}, Nothing}` : Variables in initial DAG
* `est_g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}` : CausalInference.DiGraph
* `est_g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `est_g_dot_str::Union{AbstractString, Nothing}` : DAG dot representation (e.g. used for GraphViz)
* `est_vars::Union{Vector{Symbol}, Nothing}` : Variables in PC estimated DAG
* `df::Union{DataFrame, Nothing}` : Variable observations
* `cov::Union{NamedArray, Nothing}` : Covariance matrix as NamedArray
)
```

### Constructor
```julia
* `dag(name::Union{AbstractString, Nothing})` : Create a dummy DAG object
```

Part of API, exported.
"""
mutable struct DAG
    name::Union{AbstractString, Nothing}
    # Assumed DAG
    g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}
    g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}
    g_dot_str::Union{AbstractString, Nothing}
    vars::Union{Vector{Symbol}, Nothing}
    #Estimated DAG
    est_g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}
    est_g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}
    est_g_dot_str::Union{AbstractString, Nothing}
    est_vars::Union{Vector{Symbol}, Nothing}
    # p value used in testing
    p::Union{Float64, Nothing}
    # Df used for est_g
    df::Union{DataFrame, Nothing}
    # Covariance matrix from df
    covm::Union{NamedArray, Nothing}
end

mutable struct Path
  f::Int
  l::Int
  path::Vector{Int}
  visited::Vector{Int}
  next_node::Int
end


function create_dag(name::Union{AbstractString, Nothing}=nothing)

    d = isnothing(name) ?
        DAG("", 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing) :
        DAG(name, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing)

    return d
end

function update_dag!(d::DAG, df::Union{DataFrame, Nothing}=nothing;
    g_dot_str::AbstractString)
    
    d.g_dot_str = g_dot_str
    vars = isnothing(df) ? nothing : Vector(Symbol.(names(df)))
    (d.g_tuple_list, d.vars) = create_tuple_list(g_dot_str, vars)
    d.g = DiGraph(length(d.vars))
    for (i, j) in d.g_tuple_list
        add_edge!(d.g, i, j)
    end

    return nothing
end

function set_dag_est_g!(d::DAG, df::Union{DataFrame, Nothing}=nothing;
    g_dot_str::AbstractString)
    
    d.est_g_dot_str = g_dot_str
    vars = isnothing(df) ? nothing : vector(Symbol.(names(df)))
    (d.est_g_tuple_list, d.vars) = create_tuple_list(g_dot_str, vars)
    d.est_g = DiGraph(length(d.vars))
    for (i, j) in d.g_tuple_list
        add_edge!(d.g, i, j)
    end

    return nothing
end

mutable struct PCDAG
    name::Union{AbstractString, Nothing}
    
    # Assumed DAG
    g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    g_tuple_list::Vector{Tuple{Int, Int}}
    g_dot_str::AbstractString
    vars::Vector{Symbol}
    
    #Estimated PCDAG
    est_g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    est_g_tuple_list::Vector{Tuple{Symbol, Symbol}}
    est_g_dot_str::AbstractString
    
    # p value used in testing
    p::Float64
    # Df used for est_g
    df::DataFrame
    # Covariance matrix from df
    covm::NamedArray
end


mutable struct FCIDAG
    name::AbstractString
    
    # Assumed DAG
    g::Graphs.SimpleGraphs.SimpleDiGraph{Int64}
    g_tuple_list::Vector{Tuple{Int, Int}}
    g_dot_str::AbstractString
    vars::Vector{Symbol}
    
    #Estimated FCIDAG
    est_g::MetaGraphs.MetaDiGraph{Int64, Float64}
    est_g_dot_str::Union{AbstractString, Nothing}
    
    # p value used in testing
    p::Float64
    # Df used for est_g
    df::DataFrame
    # Covariance matrix from df
    covm::NamedArray
end

function create_pc_dag() end
function create_fci_dag() end
function update_dag_est_g!() end
function set_dag_est_g!() end
function create_tuple_list() end
function skeleton_graph() end
function all_paths() end

export
    DAG,
    PCDAG,
    FCIDAG,
    create_pc_dag,
    create_fci_dag,
    Path,
    create_dag,
    update_dag!,
    set_dag_est_g!,
    create_tuple_list,
    skeleton_graph,
    all_paths
    
