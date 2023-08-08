using CausalInference, DataFrames
using CairoMakie, GraphViz
using RegressionAndOtherStories

# Generate some sample data to use with the PC algorithm

N = 1000 # number of data points

# define simple linear model with added noise
N = 20
A = rand(N)
C = rand(N) + 0.4 .* A
F = rand(N) + 0.5 .* C
B = rand(N)
E = rand(N) + 0.4 .* B
H = rand(N) + 0.5 .* E
G = rand(N) + 0.4 .* F
H = rand(N) + 0.5 .* G
D = rand(N) + 0.2 .* A + 0.3 .* B
F += 0.9 .* D
H += 0.95 .* D
nt = (A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)
df = DataFrame(A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)

name = "dag_pc"
g_dot_str = "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}"
p = 0.25

est_pcalg_gauss_nt = pcalg(nt, p, gausscitest)
est_pcalg_gauss_nt |> display

est_pcalg_gauss_df = pcalg(df, p, gausscitest)
est_pcalg_gauss_df |> display

est_pcalg_cmi_df = pcalg(df, p, cmitest)
est_pcalg_cmi_df |> display

#vars=Symbol.(names(df))
#g_tuple_list = create_tuple_list(g_dot_str, vars)

function create_pcalg_gauss_dag(name, df, g_dot_str; p=0.25)

    println("In create_pcalg_gauss_dag")

    vars=Symbol.(names(df))
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

dag_pcalg_gauss = create_pcalg_gauss_dag(name, df, g_dot_str)
dag_pcalg_gauss.est_g |> display

function create_pcalg_cmi_dag(name, df, g_dot_str; p=0.25)

    println("In create_pcalg_cmi_dag")

    vars=Symbol.(names(df))
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

dag_pcalg_cmi = create_pcalg_cmi_dag(name, df, g_dot_str)
dag_pcalg_cmi.est_g |> display
