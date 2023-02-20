"""

# DAG

Directed acyclic graph struct

### Struct
```julia
DAG(
* `name::AbstractString` : Name for the DAG object
* `e::Vector{Tuple{Int, Int}}` : DAG definition as vector of edges, e.g. [(:a, :b), ...]
* `p::Vector{Tuple{Int, Int}}` : DAG definition as used for graph creation
* `d::AbstractString` : DAG dot representation (e.g. used for GraphViz)
* `g::Graphs.Graph` : DiGraph with field: ne, fadjlist and badjlist
* `v::Vector{Symbol}` : Names of variables in DAG, order corresponding to g
* `df::Union{DataFrame, Nothing}` : Variable observations
* `cov::Union{NamedArray, Nothing}` : Covariance matrix as NamedArray
)
```

Part of API, exported.
"""
mutable struct DAG
    name::AbstractString
    e::Vector{Tuple{Symbol, Symbol}}
    p::Vector{Tuple{Int, Int}}
    d::AbstractString
    g
    v::Vector{Symbol}
    df::Union{DataFrame, Nothing}
    covm::Union{NamedArray, Nothing}
end

function sort_nodes() end
function construct_dag() end
function dseparation() end
function dag() end
function set_dag_df!() end
function set_dag_cov_matrix!() end

export
    DAG,
    dag,
    sort_nodes,
    construct_dag,
    dseparation
    set_dag_df!,
    set_dag_cov_matrix!