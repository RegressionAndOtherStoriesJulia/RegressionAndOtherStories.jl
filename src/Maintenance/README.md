#### Walk through maintenace script.

If a project has many Pluto notebooks, a package update that affects most notebooks can become rather time consuming. This is primarily an issue for a maintainer of the project.

For both "RegressionAndOtherStories.jl" based projects ("ROSStanPluto.jl" and "ROSTuringPluto.jl"), below steps will trigger creation of new Project and Manifest sections the next time a notebook is opened in Pluto.

Although these functions are part of RegressionAndOtherStories.jl, they are only useful for projects similar to "ROSStanPluto.jl" and "ROSTuringPluto.jl" (with a fixed layout for the `notebooks` subdirectory, see below an example of a `ros_df` DataFrame).

In Julia's REPL, to use either `reset_all_notebooks!()` or `update_notebook_files!()`, start with moving to the intended project directory, e.g.:
```julia
cd(expanduser(joinpath("~", ".julia", "dev", "ROSStanPluto")))
```

Load `RegressionAndOtherStories.jl` into Julia's REPL:
```julia
using RegressionAndOtherStories
```

Attempt to reset all notebooks:
```julia
reset_all_notebooks!()
┌ Info: DataFrame `ros_df` is empty, 
└ update ros_df first by running `update_notebook_files!()`
```

Most likely, the first time in a REPL session the DataFrame `ros_df` is indeed empty. 

**Note: Currently these functions have only been tested using a DataFrame `ros_df` defined in RegressionAndOtherStrories.jl. Using these functions outside this context is currently untested.**

As suggested in above `Info` message:
```julia
update_notebook_files!()
┌ Info: DataFrame ros_df is empty!
└  It will be recreated from the directory `./notebooks`.

14×3 DataFrame
 Row │ chapter                    section                            reset 
     │ String                     String                             Bool  
─────┼─────────────────────────────────────────────────────────────────────
   1 │ 00 - ROS Stan Guide        0.1 Ros Stan Guide.jl              false
   2 │ 00 - ROS Stan Guide        0.2 Valid chains.jl                false
   3 │ 00 - ROS Stan Guide        0.3 DataFramesMiniLanguage.jl      false
   4 │ 01 - Introduction          1.1 Elections Economy - hibbs.jl   false
   5 │ 01 - Introduction          1.2 Electric Company - electric.…  false
   6 │ 01 - Introduction          1.3 Peacekeeping - piece.jl        false
   7 │ 01 - Introduction          1.4 Simple Causal - causal.jl      false
   8 │ 01 - Introduction          1.5 Helicopters - helicopters.jl   false
   9 │ 02 - Data and Measurement  2.1 HDI - hdi.jl                   false
  10 │ 02 - Data and Measurement  2.2 Pew - pew.jl                   false
  11 │ 02 - Data and Measurement  2.3 HealthExpenditure - health.jl  false
  12 │ 02 - Data and Measurement  2.4 Names - allnames.jl            false
  13 │ 03 - Probability           3.0 Basic methods.jl               false
  14 │ 09 - MCMC                  9.1 Bayes.jl                       false

┌ Info: All ros_df.reset values are false. No actions taken. 
│ Use `reset_all_notebooks!()`to reset all notebooks. 
└ or set some entries in ros_df.reset to `true`.
```
Now reset all notebooks with ros_df.rest set to true, e.g.:
```julia
reset_all_notebooks!()
Updating file:./00 - ROS Stan Guide/0.1 Ros Stan Guide.jl
Updating file:./00 - ROS Stan Guide/0.2 Valid chains.jl
Updating file:./00 - ROS Stan Guide/0.3 DataFramesMiniLanguage.jl
Updating file:./01 - Introduction/1.1 Elections Economy - hibbs.jl
Updating file:./01 - Introduction/1.2 Electric Company - electric.jl
Updating file:./01 - Introduction/1.3 Peacekeeping - piece.jl
Updating file:./01 - Introduction/1.4 Simple Causal - causal.jl
Updating file:./01 - Introduction/1.5 Helicopters - helicopters.jl
Updating file:./02 - Data and Measurement/2.1 HDI - hdi.jl
Updating file:./02 - Data and Measurement/2.2 Pew - pew.jl
Updating file:./02 - Data and Measurement/2.3 HealthExpenditure - health.jl
Updating file:./02 - Data and Measurement/2.4 Names - allnames.jl
Updating file:./03 - Probability/3.0 Basic methods.jl
Updating file:./09 - MCMC/9.1 Bayes.jl
```

Start Pluto (or re-start Pluto if certain notebooks are active) and open a notebook.
