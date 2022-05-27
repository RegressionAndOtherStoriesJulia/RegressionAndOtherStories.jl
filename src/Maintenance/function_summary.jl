using RegressionAndOtherStories

funs = [
    "update_ros_notebooks!", 
    "add_to_ros_notebooks!",
    "reset_notebook!", 
    "reset_notebooks!", 
    "update_notebooks!"
]

sigs = [
    "(df; display_actions", 
    "(df, dir_path; display_actions)",
    "(fname; display_actions, create_pkg_files)",
    "(df; display_actions, create_package_files)",
    "(df; display_actions, create_package_files)"
]

exps = [false, false, false, true, true]

"""

Fill the ros_functions DataFrame.

$(SIGNATURES)

## Optional positional arguments
```julia
* `df=ros_functions # DataFrame to be filled`
```

Not exported.

"""
function function_summary()
    df = DataFrame()
    df.functions = funs 
    df.signatures = sigs
    df.exported = exps 
    df
end

