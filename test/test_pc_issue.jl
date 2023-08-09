using Graphs, CausalInference, DataFrames

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

println("\nPcalg gauss nt")
est_pcalg_gauss_nt = pcalg(nt, p, gausscitest)
est_pcalg_gauss_nt |> display

println("\nPcalg gauss df")
est_pcalg_gauss_df = pcalg(df, p, gausscitest)
est_pcalg_gauss_df |> display

println("\nPcalg cmi df")
est_pcalg_cmi_df = pcalg(df, p, cmitest)
est_pcalg_cmi_df |> display

function create_tuple_list(d_str::AbstractString, vars::Vector{Symbol})
    d = d_str[findfirst("{", d_str)[1]+1:findlast("}", d_str)[1]-2]
    s = filter(x->!isspace(x), d)
    s = split.(split(s, ";"), "->")

    tups = Tuple{Int, Int}[]
    for e in s
        e = Symbol.(e)
        push!(tups,
            (findfirst(x -> x == e[1], vars), findfirst(x -> x == e[2], vars)))
    end
    tups
end

println("\nFci dseoracle df")
est_func=dseporacle
vars = Symbol.(names(df))
g_tuple_list = create_tuple_list(g_dot_str, vars)
g = DiGraph(length(vars))
for (i, j) in g_tuple_list
    add_edge!(g, i, j)
end
est_fci = fcialg(nv(g), est_func, g)
est_fci |> display

println("\nGes gaussian_bic df")
method=:gaussian_bic; penalty=1.0; parallel=false; verbose=false
(est_ges_df, score, elapsed) = ges(df; method, penalty, parallel, verbose)
est_ges_df |> display

