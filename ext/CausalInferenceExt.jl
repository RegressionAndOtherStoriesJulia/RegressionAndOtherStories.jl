module CausalInferenceExt

using DocStringExtensions
using RegressionAndOtherStories

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: DAG, create_dag, update_dag!, update_dag_est_g!,
    skeleton_graph, all_paths
import CausalInference: dsep, backdoor_criterion

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
    g_dot_str::Union{AbstractString, Nothing}=nothing,
    est_func=gausscitest)
    
    d = create_dag(name)
    d.df = df
    d.p = p

    if !isnothing(g_dot_str)
        update_dag!(d, df; g_dot_str) # Defined in ROS
    end

    update_dag_est_g!(d, df, p; est_func)

    d
end

function update_dag_est_g!(d::DAG, df::DataFrame, p::Float64=0.1; est_func=gausscitest)
    
    d.df = df
    d.p = p

    d.est_g = CausalInference.pcalg(df, p, est_func)

    # Create vars Vector{Symbol}
    d.est_vars = Vector{Symbol}()
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
    
    # Create d.est_g_dot_str
    d.est_g_dot_str = "digraph est_g_$(d.name) {"
    for e in d.g_tuple_list
        f = d.est_vars[e[1]]
        l = d.est_vars[e[2]]
        if length(setdiff(d.est_g_tuple_list, [(e[2], e[1])])) !==
            length(d.est_g_tuple_list)
            
            d.est_g_dot_str = d.est_g_dot_str * "$(f) -> $(l) [color=red, arrowhead=none];"
        else
            d.est_g_dot_str = d.est_g_dot_str * "$(f) -> $(l);"
        end
    end
    d.est_g_dot_str = d.est_g_dot_str * "}"

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
function dsep(d::DAG, f::Symbol, l::Symbol, s::Vector{Symbol}=Symbol[]; kwargs...)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end
    dsep(d.g, findfirst(x -> x == f, d.vars), findfirst(x -> x == l, d.vars), cond; kwargs...)
end

function dsep(d::DAG, g::AbstractGraph, f::Symbol, l::Symbol, s::Vector{Symbol}=Symbol[]; kwargs...)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end
    dsep(g, findfirst(x -> x == f, d.vars), findfirst(x -> x == l, d.vars), cond; kwargs...)
end

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

function backdoor_criterion(d::DAG, g::AbstractGraph, from::Symbol, to::Symbol, s::Vector{Symbol}=Symbol[]; verbose=false)
    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    backdoor_criterion(g, f, l, cond; verbose)
end

function skeleton_graph(d::DAG)
    if !isnothing(d.g)
        fadjlist = copy(d.g.fadjlist)
        for (f, edge) in enumerate(fadjlist)
            for l in edge
                if !(f in fadjlist[l])
                    append!(fadjlist[l], f)
                end
            end
        end
    end
    g = Graph(length(fadjlist))
    for (f, entry) in enumerate(fadjlist)
        for l in entry
            add_edge!(g, f, l)
        end
    end
    g
end

function all_paths(d::DAG, f::Symbol, l::Symbol; debug=false)
    df = DataFrame()
    paths = Vector{Int}[]
    gs = skeleton_graph(d)
    nb_dict = Dict()
    for i in 1:6
        nb_dict[i] = neighbors(gs, i)
    end
    debug && println(nb_dict)
    debug && println(gs.fadjlist)
    fn = filter(i -> d.vars[i] == f, 1:length(d.vars))[1]
    ln = filter(i -> d.vars[i] == l, 1:length(d.vars))[1]
    stack = Path[]
    nb = deepcopy(nb_dict[fn])
    setdiff!(nb, [ln])
    debug && println(nb)
    for n in nb
        p = Path(fn, ln, [], [fn], fn)
        nn = p.next_node
        p_tmp = deepcopy(p)
        push!(p_tmp.path, nn)
        p_tmp.next_node = n
        if n == ln
            push!(p_tmp.path, ln)
            append!(paths, [p_tmp.path])
        else
            push!(stack, p_tmp)
        end
    end
    
    while !isempty(stack)
        debug && println()
        debug && println("$stack\n")
        p = pop!(stack)
        debug && println(p)
        nn = p.next_node
        push!(p.visited, nn)
        debug && println("has_a_path([$nn], [$(p.l)], $(p.visited)) = $(has_a_path(gs, [nn], [p.l], p.visited))")
        if has_a_path(gs, [nn], [p.l], p.visited)
            nb = deepcopy(nb_dict[nn])
            debug && println("\nNext = $nn, visited=$(p.visited), nb=$(nb))")
            setdiff!(nb, p.visited)
            debug && println(nb)
            for n in nb
                p_tmp = deepcopy(p)
                push!(p_tmp.path, nn)
                p_tmp.next_node = n
                if n == ln
                    push!(p_tmp.path, ln)
                    append!(paths, [p_tmp.path])
                else
                    push!(stack, p_tmp)
                end
            end
        end
    end
    sym_paths = Vector{Symbol}[]
    for p in paths
        sp = [d.vars[i] for i in p]
        append!(sym_paths, [sp])
    end
    sym_paths
end

end
