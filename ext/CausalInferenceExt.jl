module CausalInferenceExt

using DocStringExtensions
using RegressionAndOtherStories

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using CausalInference) : (using ..CausalInference)

import RegressionAndOtherStories: AbstractDAG, 
    PCDAG, create_pcalg_gauss_dag, create_pcalg_cmi_dag,
    FCIDAG, create_fci_dag,
    GESDAG, create_ges_dag, 
    skeleton_graph, all_paths 

import CausalInference: dsep, backdoor_criterion, is_collider, list_backdoor_adjustment

"""
Create a PCDAG object using gausscitest.

$(SIGNATURES)

## Required arguments
* `name::AbstractString` : A name for the PCDAG
* `df:DataFrame` : DataFrame with data (observations and possibly non observed inputs)
* `g_dot_str::AbstractString` : Represents in most PCDAGs the assumed generational model

## Optional keyword arguments
* `p=0.25` : p-value used in independence tests

## Returns
* `PCDAG` : See ?PCDAG

Part of the API, exported.
"""
function create_pcalg_gauss_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString; p=0.25)

    vars = Symbol.(names(df))
    g_tuple_list = create_tuple_list(g_dot_str, vars)
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end
    
    est_g = pcalg(df, p, gausscitest)

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
            est_g_dot_str *= "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
        else
            est_g_dot_str *= "$(vars[f]) -> $(vars[l]);"
        end
    end
    est_g_dot_str *= "}"

    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    return PCDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_tuple_list,
        est_g_dot_str, p, df, covm)
end

"""
Create a PCDAG object using cmitest.

$(SIGNATURES)

## Required arguments
* `name::AbstractString` : A name for the PCDAG
* `df:DataFrame` : DataFrame with data (observations and possibly non observed inputs)
* `g_dot_str::AbstractString` : Represents in most PCDAGs the assumed generational model

## Optional keyword arguments
* `p=0.25` : p-value used in independence tests

## Returns
* `PCDAG` : See ?PCDAG

Part of the API, exported.
"""
function create_pcalg_cmi_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString; p=0.25)

    vars = Symbol.(names(df))
    g_tuple_list = create_tuple_list(g_dot_str, vars)
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end
    
    est_g = pcalg(df, p, cmitest)

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
            est_g_dot_str *= "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
        else
            est_g_dot_str *= "$(vars[f]) -> $(vars[l]);"
        end
    end
    est_g_dot_str *= "}"

    # Compute est_g and covariance matrix (as NamedArray)
    covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

    return PCDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_tuple_list,
        est_g_dot_str, p, df, covm)
end


"""
Create a GESDAG object.

$(SIGNATURES)

## Required arguments
* `name::AbstractString` : A name for the FCIDAG
* `df::DataFrame` : DataFrame with observations
* `g_dot_str::AbstractString` : Represents in most FCIDAGs the assumed generational model
* `p::Float74` : p-value used in independence tests

## Optional keyword arguments
* `parallel=true` : Use multiple threads

## Returns
* `GESDAG` : See ?GESDAG

Part of the API, exported.
"""
function create_ges_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString;
    method=:gaussian_bic, penalty=1, parallel=true, verbose=false)
    
    vars = Symbol.(names(df))
    g_tuple_list = create_tuple_list(g_dot_str, vars)
    g = DiGraph(length(vars))
    for (i, j) in g_tuple_list
        add_edge!(g, i, j)
    end

    (est_g, score, elapsed) = ges(df; method, penalty, parallel, verbose)
    
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

    # Create and return the GESDAG
    return GESDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_dot_str, df,
        method, penalty, score, elapsed, covm)
end

"""
Create a FCIDAG object.

$(SIGNATURES)

## Required arguments
* `name::AbstractString` : A name for the FCIDAG
* `df::DataFrame` : DataFrame with observations
* `g_dot_str::AbstractString` : Represents in most FCIDAGs the assumed generational model
* `p::Float74` : p-value used in independence tests

## Optional keyword arguments
* `est_func=dseporacle` : Function used to compute FCIDAG

## Returns
* `PCDAG` : See ?PCDAG

Part of the API, exported.
"""
function create_fci_dag(name::AbstractString, df::DataFrame, g_dot_str::AbstractString, p=0.25;
    est_func=dseporacle)
    
    vars = Symbol.(names(df))
    g_tuple_list = create_tuple_list(g_dot_str, vars)
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
* `d::AbstractDAG` : AbstractDAG object
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

"""
List all paths between nodes f and l.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG object
* `f::Symbol` : First symbol of path in graph
* `l::Symbol` : Last symbol of path in graph

## Optional keyword arguments
* `debug = false` : Show intermediate results

## Returns
* `Vector{Vector{Symbol}}`

Exported
"""
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

"""
List backdoor adjustments.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG object
* `f::Symbol` : First symbol of path in graph
* `l::Symbol` : Last symbol of path in graph

## Optional keyword arguments
* `include = Symbol[]` : Adjustments sets containing these nodes
* `exclude = Symbol[]` : Nodes that can't be part of adjustment sets, e.g. unobserved.
* `debug = true` : Show intermediate results (show call to CausalInference method)

## Returns
* `Vector{Vector{Symbol}}`

Exported
"""
function list_backdoor_adjustment(d::AbstractDAG, from::Symbol, to::Symbol;
    include=Symbol[], exclude=Symbol[], debug=false)

    f = findfirst(x -> x == from, d.vars)
    l = findfirst(x -> x == to, d.vars)
    incl = Int[findfirst(x -> x == j, d.vars) for j in include]
    excl = Int[findfirst(x -> x == j, d.vars) for j in setdiff(d.vars, exclude)]
    debug && println("list_backdoor_adjustment(g, $Set($f), $Set($l), $Set($incl), $Set($excl)")
    res =  Set(list_backdoor_adjustment(d.g, Set(f), Set(l), Set(incl), Set(excl)))
    return [Symbol[d.vars[i] for i in j] for j in res]
end

end
