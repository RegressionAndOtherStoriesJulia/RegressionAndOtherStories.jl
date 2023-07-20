using DataFrames, Statistics
import Distributions: scale!

"""

# scale!

Augment a DataFrame with scaled values of 1 or more columns

### Method
```julia
scale!(df, var, ext) 
```

### Required arguments
```julia
* `df::DataFrame`                      : DataFrame
* `var::Union{Symbol, Vector{Symbol}}` : Variables to scale
* `ext::String="_s"`                   : Suffix for scaled variable(s)
```

### Return values
```julia
* `result::DataFrame`                  : Augmented DataFrame
```

### Example
```julia
scale!(df, :var1)

or

scale!(mydf, [:var1, var2])
```

"""
function scale_df_cols!(
    df::DataFrame, 
    vars::Vector{Symbol}, 
    ext="_s")

    for var in vars
        mean_var = mean(df[!, var])
        std_var = std(df[!, var])

        df[!, Symbol("$(String(var))$ext")] = 
            (df[:, var] .- mean_var)/std_var
    end
    df
end

function scale_df_cols!(
    df::DataFrame, 
    var::Symbol, 
    ext="_s")

    mean_var = mean(df[!, var])
    std_var = std(df[!, var])

    df[!, Symbol("$(String(var))$ext")] = 
        (df[:, var] .- mean_var)/std_var

end

export
    scale_df_cols!
    