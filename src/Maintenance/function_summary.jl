using RegressionAndOtherStories
using DataFrames
using DocStringExtensions

const funs = Symbol[
    # RegressionAndOtherStoties.jl
    :ros_path,
    :ros_data,
    :ros_datadir,

    # General/model_summary.jl
    :model_summary,

    # Require/AoG/plot_chains.jl
    :plot_chains,

    # Require/Makie/trankplot.jl
    :trankplot,

    # Require Stan only
    :model_summary,

    # Require Turing only

    # Require StructuralCausalModels?

    # Require ParetoSmoothedImportanceSampling?

    # Maintenace/function_summary.jl
    :function_summary,

    # Maintenance/update_notebooks.jl
    :update_ros_notebooks!, 
    :add_to_ros_notebooks!,
    :reset_notebook!, 
    :reset_notebooks!, 
    :update_notebooks!
]

const sigs = [
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

const exps = [
    false, false, true,
    true,
    true, # if AoG loaded
    true, # if Makie loaded
    true, # if StanSample loaded
    false,
    false, false, false, true, true
]

const cons = [
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

## Optional keyword arguments
```julia
* `funs=funs` # Vector of function names (symbols)
* `sigs=sigs` # Vector of signatures (strings)
* `exps=exps` # Vector of boolean values indicating is exported
* `cons=cons` # Vector of package names which trigger function inclusion
```



Not exported.

"""
function function_summary(df=ros_functions; 
    funs=funs, sigs=sigs, exps=exps, cons=cons)

    for (indx, fun) in enumerate(funs)
        func = isdefined(Main, Symbol(fun)) ? getfield(Main, fun) : missing
            append!(df,
                DataFrame(
                    :symbol => fun,
                    :function => func,
                    :exported => exps[indx],
                    :condition => cons[indx],
                    :signature => sigs[indx]
                )
            )
    end
    
    df
end
