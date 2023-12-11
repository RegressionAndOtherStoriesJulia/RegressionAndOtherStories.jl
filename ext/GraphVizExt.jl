module GraphVizExt

using CairoMakie, RegressionAndOtherStories, MetaGraphs, DocStringExtensions

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using GraphViz) : (using ..GraphViz)

import RegressionAndOtherStories: create_png_image, gvplot

"""
Show GraphViz representation of a dot_str.

$(SIGNATURES)

## Required arguments
* `d::AbstractString` : Dot representation of the DAG graph

Exported
"""
RegressionAndOtherStories.gvplot(d::AbstractString) = GraphViz.load(IOBuffer(d))

function create_png_image(g::T) where {T <: GraphViz.Graph}
    tmpdir = mktempdir()
    tb_g = open(joinpath(tmpdir, "dot_g.png"), "w")
    show(tb_g, MIME"image/png"(), g)
    close(tb_g)
    img_g = CairoMakie.load(joinpath(tmpdir, "dot_g.png"))
    img_g
end

function RegressionAndOtherStories.gvplot(d::PCDAG; 
    title_g = "Generational causal graph",
    title_est_g = "PC estimated causal graph")

    g1 = GraphViz.Graph(d.g_dot_str)
    g2 = GraphViz.Graph(d.est_g_dot_str)

    f = Figure(;size =  default_figure_resolution)

    # g
    ax = Axis(f[1, 1]; aspect=DataAspect(), title=title_g)
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)

    # Est_g
    title = isnothing(d.p) ? title_est_g : title_est_g * " (p = $(round(d.p, digits=3)))"
    ax = Axis(f[1, 2]; aspect=DataAspect(), title)
    Makie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)

    f
end

function RegressionAndOtherStories.gvplot(d::GESDAG; 
    title_g = "Generational causal graph",
    title_est_g = "GES estimated causal graph")

    g1 = GraphViz.Graph(d.g_dot_str)
    g2 = GraphViz.Graph(d.est_g_dot_str)

    f = Figure(;size =  default_figure_resolution)

    # g
    ax = Axis(f[1, 1]; aspect=DataAspect(), title=title_g)
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)

    # Est_g
    title = isnothing(d.penalty) ? title_est_g : title_est_g * " (penalty = $(round(d.penalty, digits=1)))"
    ax = Axis(f[1, 2]; aspect=DataAspect(), title)
    Makie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)

    f
end

function gvplot(d::FCIDAG;
    title_g = "Generational causal graph",
    title_est_g = "FCI estimated causal graph")

    g1 = GraphViz.Graph(d.g_dot_str)
    g2 = GraphViz.Graph(d.est_g_dot_str)
    
    f = Figure(;size =  default_figure_resolution)

    # g
    ax = Axis(f[1, 1]; aspect=DataAspect(), title=title_g)
    CairoMakie.image!(rotr90(create_png_image(g1)))
    hidedecorations!(ax)
    hidespines!(ax)

    # est_g
    ax = Axis(f[1, 2]; aspect=DataAspect(), title=title_est_g)
    CairoMakie.image!(rotr90(create_png_image(g2)))
    hidedecorations!(ax)
    hidespines!(ax)
    
    f
end

function RegressionAndOtherStories.is_in(v, f, l)
    l in v[f]
end

function RegressionAndOtherStories.get_mark(g, f, l)
    arrowtail = nothing
    for key in keys(g.eprops)
        if key.src == f && key.dst == l
            arrowtail = g.eprops[key][:mark]
            return arrowtail
        end
    end
    return nothing
end

function RegressionAndOtherStories.to_gv(g::T, vars::Vector{Symbol}) where {T <: AbstractMetaGraph}
    dct = Dict(:arrow => :normal, :circle => :odot, :tail => :dot)
    dot_str = "graph {\n"
    for (f, edge) in enumerate(g.graph.fadjlist)
        for l in edge
            if f < l
                head = get_mark(g, f, l)
                tail = get_mark(g, l, f)
                dot_str *= " $(vars[f]) -- $(vars[l]) [dir="
                if (!isnothing(tail) && tail !== :tail) && !isnothing(head)
                    dot_str *= "both arrowhead=$(dct[head]) arrowtail=$(dct[tail])]\n"
                else
                    if !isnothing(head) && (isnothing(tail) || tail == :tail)
                        dot_str *= "forward arrowhead=$(dct[head])"
                    elseif !isnothing(tail) && isnothing(head)
                        dot_str *= "back arrowtail=$(dct[tail])"
                    else
                        dot_str *= "none"
                    end
                    dot_str *= "]\n"
                end
            end
        end
    end
    dot_str *= "}"
    dot_str
end

end