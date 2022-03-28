using Documenter, RegressionAndOtherStories

makedocs(
    modules = [RegressionAndOtherStories],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Rob J Goedman",
    sitename = "RegressionAndOtherStories.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/goedman/RegressionAndOtherStories.jl.git",
    push_preview = true
)
