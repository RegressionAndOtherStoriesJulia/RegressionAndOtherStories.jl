module RegressionAndOtherStories

const ROS = RegressionAndOtherStories

using Reexport

# Compatibility with the new "Package Extensions" (https://github.com/JuliaLang/julia/pull/47695)
const EXTENSIONS_SUPPORTED = isdefined(Base, :get_extension)

if !EXTENSIONS_SUPPORTED
    using Requires: @require
end

function __init__()
    @static if !EXTENSIONS_SUPPORTED
        @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" include("../ext/MakieExt.jl")
        @require StanSample="c1514b29-d3a0-5178-b312-660c88baa699" include("../ext/StanExt.jl")
        @require CausalInference="8e462317-f959-576b-b3c1-403f26cec956"  include("../ext/CausalInferenceExt.jl")
        @require GraphViz="f526b714-d49f-11e8-06ff-31ed36ee7ee0" include("../ext/GraphVizExt.jl")
    end
end


@reexport using CSV, DelimitedFiles, Unicode, Graphs, OrderedCollections
@reexport using DataFrames, CategoricalArrays
@reexport using NamedArrays, DataStructures, NamedTupleTools
@reexport using Random, Distributions, StatsBase, Statistics
@reexport using KernelDensity, LinearAlgebra, LaTeXStrings, Dates
@reexport using Graphs, MetaGraphs

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

# Direct access to the R repository "ROS-Examples"

"""

ros_data()

Base part of the path to datafiles in the R package ROS-Examples.
Return "" if `env_var` is not present in ENV.

## Positional argument
```julia
* `dataset::Union{AbstractString, Missing}` # Path to data in ROS-Examples
```

### Keyword arguments
```julia
* `env_var = "JULIA_ROS_HOME"` # Environment variable name
```

### Returns
```julia
* `path::AbstractString` # Path or "".
```

# Extended help

Examples:
```julia
ros_path()
ros_path("HDI")
```
"""
function ros_path(dataset::Union{AbstractString, Missing} = missing;
    env_var="JULIA_ROS_HOME")

    if haskey(ENV, env_var)
        ros_src_path = ENV["JULIA_ROS_HOME"]
    else
        @warn "JULIA_ROS_HOME environment variable not defined."
        return ""
    end
    if ismissing(dataset)
        normpath(ros_src_path)
    else
        normpath(joinpath(ros_src_path, dataset))
    end
end

"""

ros_data()

Construct the path to a datafile in the R package ROS-Examples.
Return "" if `env_var` is not present in ENV.

## Positional argument
```julia
* `dataset::AbstractString`
* `parts::Vector{AbstractString}` # Path to data file in 
```

### Keyword arguments
```julia
* `env_var = "JULIA_ROS_HOME"` # Environment variable name
```

### Returns
```julia
* `path::AbstractString` # Path or "".
```

# Extended help

Examples:
```julia
ros_data()
ros_data("HDI", "hdi.dat")
```
"""
function ros_data(dataset, parts...; env_var="JULIA_ROS_HOME") 
   if haskey(ENV, env_var)
        ros_src_path = ENV["JULIA_ROS_HOME"]
    else
        @warn "JULIA_ROS_HOME environment variable not defined."
        return ""
    end
    normpath(joinpath(ros_path(dataset), "data", parts...))
end

default_figure_resolution =  (1100, 600);

export
    ros_path,
    ros_data,
    default_figure_resolution

# Access RegressionAndOtherStories.jl data files (.csv) using ros_datadir()
"""

# ros_datadir()

Path to the RegressionAndOtherStories.jl data files.

Construct the path to a dataset in RegressionAndOtherStories.jl.

## Positional argument
```julia
* `parts::Vector{AbstractString}` # Path to data file in 
```

### Returns
```julia
* `path::AbstractString` # Path or "".
```

# Extended help

Examples:
```julia
ros_datadir("ElectionsEconomy", "hibbs.dat")
```
or, to read in as a DataFrame:
```julia
hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"), DataFrame)
```

"""
function ros_datadir(parts...)
    normpath(@__DIR__, "..", "data", parts...)
end

include("Utilities/bin_vector.jl")
include("Utilities/rank_vector.jl")
include("General/link.jl")
include("General/jitter.jl")
include("General/modelsummary.jl")
include("General/nested_columns.jl")
include("General/errorbars.jl")
include("General/hpdi.jl")
include("General/PI.jl")
include("General/estimparam.jl")
include("General/lin.jl")
include("General/meanlowerupper.jl")
include("General/zscore_transform.jl")
include("General/simulate.jl")
include("General/scale_df_cols.jl")
include("PlottingSupport/plot_model_coef.jl")
include("PlottingSupport/trankplot.jl")
include("PlottingSupport/cov_ellipse.jl")
include("PlottingSupport/plot_chains.jl")
include("PlottingSupport/pairplot.jl")
include("CausalInferenceSupport/extension_functions.jl")
include("GraphVizSupport/extension_functions.jl")
include("Maintenance/reset_notebooks.jl")

export
    ROS,
    ros_datadir

end # module
