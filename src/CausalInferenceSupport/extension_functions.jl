function create_tuple_list(d_str::AbstractString, vars::Union{OrderedSet{Symbol}, Nothing})
    d = d_str[findfirst("{", d_str)[1]+1:findlast("}", d_str)[1]-2]
    s = filter(x->!isspace(x), d)
    s = split.(split(s, ";"), "->")
    if isnothing(vars)
        vars = OrderedSet{Symbol}()
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
* `g_dot_repr::Union{AbstractString, Nothing}` : DAG dot representation (e.g. used for GraphViz)
* `vars::Union{OrderedSet{Symbol}, Nothing}` : OrderedSet of variables in DAG
* `est_g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}` : CausalInference.DiGraph
* `est_g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `est_g_dot_repr::Union{AbstractString, Nothing}` : DAG dot representation (e.g. used for GraphViz)
* `est_vars::Union{OrderedSet{Symbol}, Nothing}` : OrderedSet of variables in DAG
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
    g_dot_repr::Union{AbstractString, Nothing}
    vars::Union{OrderedSet{Symbol}, Nothing}
    #Estimated DAG
    est_g::Union{Graphs.SimpleGraphs.SimpleDiGraph{Int64}, Nothing}
    est_g_tuple_list::Union{Vector{Tuple{Int, Int}}, Nothing}
    est_g_dot_repr::Union{AbstractString, Nothing}
    est_vars::Union{OrderedSet{Symbol}, Nothing}
    # Df used for est_g
    df::Union{DataFrame, Nothing}
    # Covariance matrix from df
    covm::Union{NamedArray, Nothing}

end

function create_dag(name::Union{AbstractString, Nothing}=nothing)
    d = isnothing(name) ?
        DAG("", 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing) :
        DAG(name, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing, nothing, nothing, 
            nothing, nothing)

    return d
end

function update_dag!(d::DAG, g_dot_repr::AbstractString)
    
    d.g_dot_repr = g_dot_repr
    (d.g_tuple_list, d.vars) = create_tuple_list(g_dot_repr, nothing)
    d.g = DiGraph(length(d.vars))
    for (i, j) in d.g_tuple_list
        add_edge!(d.g, i, j)
    end

    return nothing
end

function create_tuple_list() end
function dseparation() end

export
    DAG,
    create_dag,
    update_dag!,
    create_tuple_list,
    dseparation
