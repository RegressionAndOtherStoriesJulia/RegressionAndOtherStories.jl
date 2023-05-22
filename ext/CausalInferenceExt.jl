module CausalInferenceExt

using DocStringExtensions
using RegressionAndOtherStories

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: AbstractDAG, PCDAG, create_pc_dag, FCIDAG, create_fci_dag,
    skeleton_graph, all_paths 

import CausalInference: dsep, backdoor_criterion, is_collider

function create_pc_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString, p::Float64=0.1; est_func=gausscitest)

    g_dot_str = g_dot_str
    vars = Symbol.(names(df))
    (g_tuple_list, vars) = create_tuple_list(g_dot_str, vars)
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end
    
    est_g = CausalInference.pcalg(df, p, est_func)

    # Create d.est_tuple_list
    est_g_tuple_list = Tuple{Int, Int}[]
    for (f, edge) in enumerate(est_g.fadjlist)
        for l in edge
            push!(est_g_tuple_list, (f, l))
        end
    end
    
    # Create d.est_g_dot_str
    est_g_dot_str = "digraph est_g_$(name) {"
    for e in g_tuple_list
        f = e[1]
        l = e[2]
        if length(setdiff(est_g_tuple_list, [(e[2], e[1])])) !== length(est_g_tuple_list)

           est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
        else
            est_g_dot_str = est_g_dot_str * "$(vars[f]) -> $(vars[l]);"
        end
    end
    est_g_dot_str = est_g_dot_str * "}"

    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    return PCDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_tuple_list,
        est_g_dot_str, p, df, covm)
end

function create_fci_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString, p=0.1;
    est_func=dseporacle)
    
    vars = Symbol.(names(df))
    (g_tuple_list, vars) = create_tuple_list(g_dot_str, vars)
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end

    est_g = fcialg(nv(g), est_func, g)
    est_g_dot_str = to_gv(est_g, vars)

    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    # Create and return the FCIDAG
    return FCIDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_dot_str, p, df, covm)
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
function dsep(d::AbstractDAG, f::Symbol, l::Symbol, s::Vector{Symbol}=Symbol[]; kwargs...)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end
    dsep(d.g, findfirst(x -> x == f, d.vars), findfirst(x -> x == l, d.vars), cond; kwargs...)
end

function dsep(d::AbstractDAG, g::AbstractGraph, f::Symbol, l::Symbol, s::Vector{Symbol}=Symbol[]; kwargs...)
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
function backdoor_criterion(d::AbstractDAG, from::Symbol, to::Symbol, s::Vector{Symbol}=Symbol[];
    verbose=false)

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    backdoor_criterion(d.g, f, l, cond; verbose)
end

function backdoor_criterion(d::AbstractDAG, g::AbstractGraph, from::Symbol, to::Symbol,
    s::Vector{Symbol}=Symbol[]; verbose=false)

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    cond = Int[]
    for sym in s
        push!(cond, findfirst(x -> x == sym, d.vars))
    end

    backdoor_criterion(g, f, l, cond; verbose)
end

function is_collider(d::AbstractDAG, f::Symbol, m::Symbol, l::Symbol; verbose=false)

    f = findfirst(x -> x == f, d.vars)
    m = findfirst(x -> x == m, d.vars)
    l = findfirst(x -> x == l, d.vars)
    is_collider(d.est_g, f, m, l)
end
   
function skeleton_graph(d::AbstractDAG)
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

function all_paths(d::AbstractDAG, f::Symbol, l::Symbol; debug=false)
    df = DataFrame()
    paths = Vector{Int}[]
    gs = skeleton_graph(d)
    nb_dict = Dict()
    for i in 1:nv(d.g)
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
