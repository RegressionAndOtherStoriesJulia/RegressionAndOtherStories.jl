module GraphVizExt

using CairoMakie, RegressionAndOtherStories, DocStringExtensions

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using GraphViz) : (using ..GraphViz)

"""
Show GraphViz representation of a dot_repr.

$(SIGNATURES)

## Required arguments
* `d::AbstractString` : Dot representation of the DAG graph

Exported
"""
RegressionAndOtherStories.gvplot(d::AbstractString) = GraphViz.load(IOBuffer(d))

function RegressionAndOtherStories.create_png_image(g::T) where {T <: GraphViz.Graph}
    tmpdir = mktempdir()
    tb_g = open(joinpath(tmpdir, "dot_g.png"), "w")
    show(tb_g, MIME"image/png"(), g)
    close(tb_g)
    img_g = CairoMakie.load(joinpath(tmpdir, "dot_g.png"))
    img_g
end

"""
Show GraphViz representation of the DOT representations in a DAG.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG containing both g and est_g graphs.

Exported
"""
function RegressionAndOtherStories.gvplot(d::DAG; 
    title_g = "Generational causal graph",
    title_est_g = "Estimated causal graph")

    if !isnothing(d.g_dot_repr) && !isnothing(d.est_g_dot_repr)
        g1 = GraphViz.Graph(d.g_dot_repr)
        g2 = GraphViz.Graph(d.est_g_dot_repr)

        f = Figure()
        ax = Axis(f[1, 1]; aspect=DataAspect(), title=title_g)

        # Used for the legend
        undefined = lines!(0, 0, color=:blue)
        indeterminate = lines!(0, 0, color=:red)
        influence = lines!(0, 0, color=:black)

        CairoMakie.image!(rotr90(create_png_image(g1)))
        hidedecorations!(ax)
        hidespines!(ax)

        # Est_g
        title = isnothing(d.p) ? title_est_g : title_est_g * " (p = $(round(d.p, digits=3)))"
        ax = Axis(f[1, 2]; aspect=DataAspect(), title)
        Makie.image!(rotr90(create_png_image(g2)))
        hidedecorations!(ax)
        hidespines!(ax)

        # Legend
        Legend(f[1, 3], 
            [undefined, indeterminate, influence],
            ["Undirectional", "Indeterminate", "Influence"])

        f
    elseif !isnothing(d.g_dot_repr)
        gvplot_g(d; title=title_g)
    elseif !isnothing(d.est_g_dot_repr)
        gvplot_est_g(d; title=title_est_g)
    else
        @warn "No DOT representation found in DAG."
    end
end

"""
Show GraphViz representation of the DAG.g.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG containing both g and est_g graphs.

## Optional arguments
* `title::AbstractString` : Title for plot.

Exported
"""
function RegressionAndOtherStories.gvplot_g(d::DAG; 
    title="Generational causal graph")

    if !isnothing(d.g_dot_repr)
        g1 = GraphViz.Graph(d.g_dot_repr)
        f = Figure()
        ax = Axis(f[1, 1]; aspect=DataAspect(), title)

        # Used for the legend
        undefined = lines!(0, 0, color=:blue)
        indeterminate = lines!(0, 0, color=:red)
        influence = lines!(0, 0, color=:black)

        CairoMakie.image!(rotr90(create_png_image(g1)))
        hidedecorations!(ax)
        hidespines!(ax)

        # Legend
        Legend(f[1, 2], 
            [undefined, indeterminate, influence],
            ["Undirectional", "Indeterminate", "Influence"])

        f
    elseif !isnothing(d.g_dot_repr)
        @warn "No DOT representation for g found in DAG."
    end
end

"""
Show GraphViz representation of the DAG.est_g.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG containing both g and est_g graphs.

## Optional arguments
* `title::AbstractString` : Title for plot.

Exported
"""
function RegressionAndOtherStories.gvplot_est_g(d::DAG; 
    title="Estimated causal graph")

    if !isnothing(d.est_g_dot_repr)
        g1 = GraphViz.Graph(d.est_g_dot_repr)
        f = Figure()
        ax = Axis(f[1, 1]; aspect=DataAspect(), title)

        # Used for the legend
        undefined = lines!(0, 0, color=:blue)
        indeterminate = lines!(0, 0, color=:red)
        influence = lines!(0, 0, color=:black)

        CairoMakie.image!(rotr90(create_png_image(g1)))
        hidedecorations!(ax)
        hidespines!(ax)

        # Legend
        Legend(f[1, 2], 
            [undefined, indeterminate, influence],
            ["Undirectional", "Indeterminate", "Influence"])
        
        f
    elseif !isnothing(d.g_dot_repr)
        @warn "No DOT representation for est_g found in DAG."
    end
end

end