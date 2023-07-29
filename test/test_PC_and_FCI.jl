begin
    # Graphics related packages
    using CairoMakie
    using GraphViz
    using Graphs
    using MetaGraphs
    using Test

    # DAG support
    using CausalInference

    # Stan specific
    using StanSample

    # Project support functions
    using RegressionAndOtherStories
end

let
    Random.seed!(1)
    N = 1000
    global p = 0.01
    x = rand(N)
    v = x + rand(N) * 0.25
    w = x + rand(N) * 0.25
    z = v + w + rand(N) * 0.25
    s = z + rand(N) * 0.25

    #global nt = (x=x, v=v, w=w, z=z, s=s)
    global df = DataFrame(x=x, v=v, w=w, z=z, s=s)
    global covm = NamedArray(cov(Array(df)), (names(df), names(df)), ("Rows", "Cols"))
    df
end

g_dot_str="DiGraph dag_1 {x->v; v->z; x->w; w->z; z->s;}";

vars = Symbol.(names(df))
nt = namedtuple(vars, [df[!, k] for k in vars])

g = pcalg(nt, 0.25, gausscitest)
g |> display

dag_1 = create_fci_dag("dag_1", df, g_dot_str);
dag_1.est_g |> display

g_oracle = fcialg(5, dseporacle, dag_1.g)
g_oracle |> display

g_gauss = fcialg(nt, 0.05, gausscitest)
g_gauss |> display

let
    fci_oracle_dot_str = to_gv(g_oracle, dag_1.vars)
    fci_gauss_dot_str = to_gv(g_gauss, dag_1.vars)
    g1 = GraphViz.Graph(dag_1.g_dot_str)
    g2 = GraphViz.Graph(dag_1.est_g_dot_str)
    g3 = GraphViz.Graph(fci_oracle_dot_str)
    g4 = GraphViz.Graph(fci_gauss_dot_str)
    f = Figure(resolution=default_figure_resolution)
    ax = Axis(f[1, 1]; aspect=DataAspect(), title="True (generational) DAG")
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[1, 2]; aspect=DataAspect(), title="PC estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 1]; aspect=DataAspect(), title="FCI oracle estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g3)))
    hidedecorations!(ax)
    hidespines!(ax)
    ax = Axis(f[2, 2]; aspect=DataAspect(), title="FCI gauss estimated DAG")
    CairoMakie.image!(rotr90(create_png_image(g4)))
    hidedecorations!(ax)
    hidespines!(ax)
    f
end

println("Cmitest")
#@time dag_2 = create_pc_dag("dag_2", df, g_dot_str, 0.25; est_func=cmitest);

@testset "PC & FCI" begin

    @test dsep(dag_1, :x, :v) == false

    @test dsep(dag_1, :x, :s, [:w]) == false

    @test dsep(dag_1, :x, :s, [:z]) == true

    @test dsep(dag_1, :x, :z, [:v, :w]) == true

    @test backdoor_criterion(dag_1, :x, :v) == true

    @test backdoor_criterion(dag_1, :x, :w) == true

    @test backdoor_criterion(dag_1, dag_1.g, :x, :w) == true

    @test backdoor_criterion(dag_1, dag_1.est_g, :x, :w) == false

    @test backdoor_criterion(dag_1, g_oracle, :x, :v) == false

    @test backdoor_criterion(dag_1, g_gauss, :x, :v) == false

    @test dsep(dag_1, g_oracle, :x, :z, [:v, :w]) == false

    @test dsep(dag_1, dag_1.g, :x, :z, [:v, :w]) == true

end