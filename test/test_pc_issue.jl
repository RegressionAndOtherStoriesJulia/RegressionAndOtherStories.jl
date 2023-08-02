using CausalInference, DataFrames, RegressionAndOtherStories

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

est_g = pcalg(nt, 0.25, gausscitest)
est_g |> display

est_g = pcalg(df, 0.25, gausscitest)
est_g |> display

name = "dag_pc"
g_dot_str = "Digraph PC {A->C; C->F; B->E; E->H; F->G; G->H; A->D; B->D; D->F; D->H;}"
p = 0.1
est_func = gausscitest

vars = Symbol.(names(df))
nt = namedtuple(vars, [df[!, k] for k in vars])

(g_tuple_list, vars) = create_tuple_list(g_dot_str, vars)
g = DiGraph(length(vars))
for (i, j) in g_tuple_list
    add_edge!(g, i, j)
end

est_g = CausalInference.pcalg(df, p, est_func)
est_g |> display

# Create d.est_tuple_list
est_g_tuple_list = Tuple{Int, Int}[]
for (f, edge) in enumerate(est_g.fadjlist)
    for l in edge
        push!(est_g_tuple_list, (f, l))
    end
end
est_g_tuple_list |> display

# Create d.est_g_dot_str
est_g_dot_str = "digraph est_g_$(name) {"
for e in g_tuple_list
    f = e[1]
    l = e[2]
    println([f, l, length(est_g_tuple_list), length(setdiff(est_g_tuple_list, [(e[2], e[1])]))])
    if length(setdiff(est_g_tuple_list, [(e[2], e[1])])) !== length(est_g_tuple_list)
        global est_g_dot_str *= "$(vars[f]) -> $(vars[l]) [color=red, arrowhead=none];"
    else
        global est_g_dot_str *= "$(vars[f]) -> $(vars[l]);"
    end
end
est_g_dot_str *= "}"
est_g_dot_str |> display

# Compute est_g and covariance matrix (as NamedArray)
covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))

dag_pc = PCDAG(name, g, g_tuple_list, g_dot_str, vars, est_g, est_g_tuple_list,
    est_g_dot_str, p, df, covm)
dag_pc.est_g |> display
