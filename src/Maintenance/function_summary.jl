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
    :create_ros_notebooks, 
    :update_notebooks
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
    "(; display_actions)",
    "(df; display_actions)"
]

const exps = [
    false, false, true,
    true,
    true, # if AoG loaded
    true, # if Makie loaded
    true, # if StanSample loaded
    true,
    false, false, true, true, true
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

Create a ros_functions DataFrame.

$(SIGNATURES)

## Optional keyword arguments
```julia
* `funs=funs` # Vector of function names (symbols)
* `sigs=sigs` # Vector of signatures (strings)
* `exps=exps` # Vector of boolean values indicating is exported
* `cons=cons` # Vector of package names which trigger function inclusion
```

Exported.

"""
function create_function_summary(; funs=funs, sigs=sigs, exps=exps, cons=cons)

    df = DataFrame(
        :symbol => Symbol[],
        :function => Union{Function, Missing}[],
        :exported => Bool[],
        :condition => String[],
        :signature => String[]
    )

    for (indx, fun) in enumerate(funs)
        if isdefined(Main, Symbol(fun))
            func = getfield(Main, fun)
        elseif isdefined(RegressionAndOtherStories, Symbol(fun))
            func = getfield(RegressionAndOtherStories, Symbol(fun))
        else
            func = missing
        end
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

"""

Update loaded functions in the ros_functions DataFrame.

$(SIGNATURES)

## Optional positional arguments
```julia
* `df # DataFrame `ros_functions` to be updated`
```


Exported.

"""
function update_functions_in_summary(df)

    funcs = Union{Function, Missing}[]
    for fun in df.symbol
        if isdefined(Main, Symbol(fun))
            func = getfield(Main, fun)
        elseif isdefined(RegressionAndOtherStories, Symbol(fun))
            func = getfield(RegressionAndOtherStories, Symbol(fun))
        else
            func = missing
        end
        append!(funcs, [func])
    end

    df.function = funcs
    df
end

export
    create_function_summary,
    update_functions_in_summary
