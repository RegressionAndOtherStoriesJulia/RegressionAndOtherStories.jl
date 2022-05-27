using RegressionAndOtherStories

#=
## Functions defined in this package:

### Currently (v0.3.0) exported functions (see online help)

1. ros_path
2. ros_data
3. ros_datadir
4. plot_chains
5. model_summary
6. trankplot


### Currently not exported functions (see online help)

1. rank_vector
2. bin_vector

### Maintenance functions

1. update_ros_notebooks! (Not exported)
2. add_to_ros_notebooks! (Not exported)
3. reset_notebook! (Not exported)
4. reset_notebooks! (Exported)
5. update_notebooks! (Exported)

=#

funs = [
    # RegressionAndOtherStoties.jl
    "ros_path",
    "ros_data",
    "ros_datadir",

    # General/model_summary.jl
    "model_summary",

    # Require/AoG/plot_chains.jl
    "plot_chains",

    # Require/Makie/trankplot.jl
    "trankplot",

    # Require Stan only
    "Require/Stan/model_summary.jl",

    # Require Turing only

    # Require StructuralCausalModels?

    # Require ParetoSmoothedImportanceSampling?

    # Maintenace/function_summary.jl
    "function_summary",

    # Maintenace/update_notebooks.jl
    "update_ros_notebooks!", 
    "add_to_ros_notebooks!",
    "reset_notebook!", 
    "reset_notebooks!", 
    "update_notebooks!",
]

sigs = [
    "(dataset; env_var",
    "(dataset, parts...; env_var)",
    "(parts...)",

    "(model_df, params, digits)", # model_summary(::DataFrame)

    "(plot_chains(df, pars; no_of_chains, no_of_draws)", # plot_chains

    "(df, param; bins, n_draws, n_chains, n_eff, kwargs...)", # trankplot

    "(model, params; round_estimates)", # model_summary(::SampleModel)

    "(; funs, sigs, exps, cons)", # function_summary

    "(df; display_actions", 
    "(df, dir_path; display_actions)",
    "(fname; display_actions, create_pkg_files)",
    "(df; display_actions)",
    "(df; display_actions)"
]

exps = [
    false, false, true,
    true,
    true, # if AoG loaded
    true, # if Makie loaded
    true, # if StanSample loaded
    false,
    false, false, false, true, true
]

cons = [
    "", "", "",
    "",
    "AoG",
    "Makie",
    "StanSample",
    "",
    "", "", "", "", ""
]

"""

Fill the ros_functions DataFrame.

$(SIGNATURES)

## Optional positional arguments
```julia
* `df=ros_functions # DataFrame to be filled`
```

Not exported.

"""
function function_summary(; funs=funs, sigs=sigs, exps=exps, cons=cons)

    df = DataFrame()
    df.functions = funs 
    df.signatures = sigs
    df.exported = exps 
    df.condition = cons
    df
end

