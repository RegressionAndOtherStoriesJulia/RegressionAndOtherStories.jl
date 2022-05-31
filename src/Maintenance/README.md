#### Example of using the `update_ros_notebooks()` maintenace function.

If a project has many Pluto notebooks, a package update that affects most notebooks can become rather time consuming. This is primarily an issue for a maintainer of the project who has to open each notebook and trigger a package update request.

For both "RegressionAndOtherStories.jl" based projects ("ROSStanPluto.jl" and "ROSTuringPluto.jl"), below steps will trigger the creation of new Project and Manifest sections the next time a notebook is opened in Pluto.

Although these functions are part of RegressionAndOtherStories.jl, they are only useful for projects similar to "ROSStanPluto.jl" and "ROSTuringPluto.jl" (with a fixed layout for the `notebooks` subdirectory, see below an example of a `ros_notebooks` DataFrame).

The 2 most important (and exported) functions are `create_ros_notebooks()` and `update_ros_notebooks(df)`.

**Note: Currently these functions have only been tested using a DataFrame `ros_notebooks` as defined in RegressionAndOtherStories.jl. Using these functions outside this context is currently untested.**

In Julia's REPL, start with moving to the intended project directory, e.g.:
```julia
cd(expanduser(joinpath("~", ".julia", "dev", "ROSStanPluto")))
```

The notebooks directory is expected to be a subdirectory of the project directory.

Load `RegressionAndOtherStories.jl` into Julia's REPL and create `ros_notebooks`:
```julia
using RegressionAndOtherStories

ros_notebooks = create_ros_notebooks()
┌ Info: DataFrame ros_notebooks is empty!
└  It will be recreated from directory `./notebooks`.
┌ Info: All ros_notebooks.reset values are false. No actions taken. 
│ Set some entries in ros_notebooks.reset to `true` 
└ and run `update_notebooks!(df).
```

Inspect DataFrame `ros_notebooks`:
```julia
ros_notebooks |> display
16×3 DataFrame
 Row │ chapter                    section                            reset 
     │ String                     String                             Bool  
─────┼─────────────────────────────────────────────────────────────────────
   1 │ 00 - ROSStanGuide          0.1 Ros Stan Guide.jl              false
   2 │ 00 - ROSStanGuide          0.2 Valid chains.jl                false
   3 │ 00 - ROSStanGuide          0.3 DataFramesMiniLanguage.jl      false
   4 │ 01 - Introduction          1.1 Elections Economy - hibbs.jl   false
   5 │ 01 - Introduction          1.2 Electric Company - electric.…  false
   6 │ 01 - Introduction          1.3 Peacekeeping - piece.jl        false
   7 │ 01 - Introduction          1.4 Simple Causal - causal.jl      false
   8 │ 01 - Introduction          1.5 Helicopters - helicopters.jl   false
   9 │ 02 - Data and Measurement  2.1 HDI - hdi.jl                   false
  10 │ 02 - Data and Measurement  2.2 Pew - pew.jl                   false
  11 │ 02 - Data and Measurement  2.3 HealthExpenditure - healthex…  false
  12 │ 02 - Data and Measurement  2.4 Names - allnames.jl            false
  13 │ 03 - Probability           3.0 Basic methods.jl               false
  14 │ 09 - MCMC                  9.1 Bayes.jl                       false
  15 │ Appendix Z                 latexify_example.jl                false
  16 │ Appendix Z                 using_reset_all_notebooks.jl       false
```

Update all `ros_notebooks.reset` values:
```julia
ros_notebooks.reset .= true;
```

Or just update a few ros_notebooks.reset values:
```julia
ros_notebooks[[3, 5,6], :reset] .= true;

# or

ros_notebooks.reset[[3, 5, 6]] .= true;

```

Reset notebooks with ros_notebooks.reset set to true, e.g.:
```julia
update_ros_notebooks!(ros_notebooks)
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

In the `notebooks` directory, under `Notebook maintenance`, a notebook version is provided.

In the same directory there is also a notebook demonstrating the maintenance functions `create_ros_functions()` and `update_ros_functions(df)`.
