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

function create_png_image(g::T) where {T <: GraphViz.Graph}
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
function RegressionAndOtherStories.gvplot(d::DAG)
    if !isnothing(d.g_dot_repr) && !isnothing(d.est_g_dot_repr)
        g1 = GraphViz.Graph(d.g_dot_repr)
        g2 = GraphViz.Graph(d.est_g_dot_repr)
        f = Figure()
        ax = Axis(f[1, 1]; aspect = DataAspect(), title = "Assumed causal graph")
        CairoMakie.image!(rotr90(create_png_image(g1)))
        hidedecorations!(ax)
        ax = Axis(f[1, 2]; aspect = DataAspect(), title = "Estimated causal graph")
        Makie.image!(rotr90(create_png_image(g2)))
        hidedecorations!(ax)
        f
    elseif !isnothing(d.g_dot_repr)
        @info "TBD"
    elseif !isnothing(d.est_g_dot_repr)
        @info "TBD"
    else
        @warn "No DOT representation found in DAG."
    end
end

end