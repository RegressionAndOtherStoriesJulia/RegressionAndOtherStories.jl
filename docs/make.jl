using Documenter, ROSBase

makedocs(
    modules = [ROSBase],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Rob J Goedman",
    sitename = "ROSBase.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/goedman/ROSBase.jl.git",
    push_preview = true
)
