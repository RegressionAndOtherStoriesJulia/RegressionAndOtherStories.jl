module GraphVizExt

using RegressionAndOtherStories, DocStringExtensions

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using GraphViz) : (using ..GraphViz)

"""
Show GraphViz representation of a dot_repr.

$(SIGNATURES)

## Required arguments
* `d::AbstractString` : Dot representation of the DAG graph

Exported
"""
RegressionAndOtherStories.gvplot(d::AbstractString) = GraphViz.load(IOBuffer(d))

"""
Show GraphViz representation of the dot_repr in a DAG.

$(SIGNATURES)

## Required arguments
* `d::DAG` : DAG object containg the field `dot_repr`.

Exported
"""
RegressionAndOtherStories.gvplot(d::DAG) = GraphViz.load(IOBuffer(d.d))

end