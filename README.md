# RegressionAndOtherStories.jl v0.9

| **Project Status**          |  **Build Status** |
|:---------------------------:|:-----------------:|
|![][project-status-img] | ![][CI-build] |

[CI-build]: https://github.com/stanjulia/StanSample.jl/workflows/CI/badge.svg?branch=master

[issues-url]: https://github.com/stanjulia/ROSbase.jl/issues

[project-status-img]: https://img.shields.io/badge/lifecycle-experimental-orange.svg

## Purpose (once completed, maybe late 2023)

RegressionAndOtherStories.jl contains supporting (Julia) functions and the data files used in ["Regression and Other Stories"](https://avehtari.github.io/ROS-Examples/) by Andrew Gelham, Jennifer Hill and Aki Vehtari.

The package is also used in project SR2StanPluto.jl v9+, a revised inplementation of the [Statistical Rethinking](https://github.com/StatisticalRethinkingJulia) support functions using Makie.jl, CausalInference.jl and GraphViz.jl. 

## Contents

The **supporting functions** are intended to be used in (currently) 3 Julia projects (also under development), [ROSStanPluto.jl](https://github.com/RegressionAndOtherStoriesJulia/ROSStanPluto.jl), [ROSTuringPluto.jl](https://github.com/RegressionAndOtherStoriesJulia/ROSTuringPluto.jl) and [SR2StanPluto](https://xcelab.net/rm/statistical-rethinking/).

All **data files** are in `.csv` format and located in the `data` directory.

If RegressionAndOtherStories.jl is loaded, the files can be read in as a DataFrame using:
```
hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"), DataFrame)
```

For that purpose `ros_datadir()` is exported.

If needed, Stata files (`.dat`) have been converted to `.csv` files using the scripts in the `scripts` directory, e.g. see `scripts\hdi.jl`. To access the Stata files in the R package [ROS-Examples](https://github.com/avehtari/ROS-Examples) RegressionAndOtherStories.jl expects the environment variable `JULIA_ROS_HOME` to be defined, e.g.:
```
ENV["JULIA_ROS_HOME"] = expanduser("~/Projects/R/ROS-Examples")
```

R itself does not necessarily need to be installed for this to work. 

If so desired, direct use of the Stata files is also possible as the Stata to .csv file conversion scripts mentioned above show.

## Approach

RegressionAndOtherStories.jl v9+ is using Julia's package extension option. In particular Turing, Stan, Makie, GraphViz and CausalInference, if needed, are included as extensions.

Over time I might minimize the use of AlgebraOfGraphics.jl. It is a nice package but also a bit more difficult to tailor (compared to Makie/GLMakie).

In working on this I will move over (and likely update) several important functions from StatisticalRethinking.jl as well, e.g. `link()`.

I expect I can use ParetoSmoothedImportanceSampling.jl as is but will take another look at PSIS.jl and ParetoSmooth.jl when revising the relevant chapters.

## Project maintenance for Pluto notebooks

In the subdirectory `src/Maintenance/reset_notebooks.jl` is a function I use in the Pluto notebook projects (SR2StanPluto, ROSStanPluto, etc.). The function potentially makes two changes to selected notebooks: 
1. If it finds a line starting with `Pkg.activate` it disbales that line if `reset_activate = true`.
2. If it finds a line starting with `#Pkg.activate` it enables that line if `set_activate = true`.
3. It removes the Project and Manifest sections of all notebooks selected for reset. See the maintenance notebooks in projects such as SR2StanPluto and ROSStanPluto.

Using `Pkg.activate(...)` is useful if your workflow uses many different notebooks.

## Issues, comments and questions

Please file issues, comments and questions [here](https://github.com/stanjulia/ROSbase.jl/issues).

Pull requests are also welcome.

## Versions

### Version 0.10

1. Redone DAG struct.
2. Use GraphViz with CairoMakie.
3. switch to use CairoMakie instead of GLMakie.

### Version 0.9

1. Switch to extensions.
2. Added simulate function.
3. Added scale_df_cols! (scale! conflicted with Makie and other packages).
4. Switching to CausalInference.jl as a replacement for StructuralCausalModels.jl.
5. Possibly switching to either PSIS.jl or ParetoSmooth.jl as a replacement for ParetoSmoothedImportanceSampling.jl.
6. Switched to Makie.jl and GLMakie.jl as back-end.
7. Use of GraphViz.jl to display DAGs.

### Versions 0.7 and 0.8

1. Primarily following package updates.

### Version 0.6.1

1. Changed back to use DataFrames directly as basis for summaries.
2. Use getindex to access single elements in summary DataFrames (first argument taken vrom `parameters` column in df)
3. For Stan use array() to group nested columns into a matrix. For Turing continue to use nested_column_to_array.

### Release 0.5.0

1. Added DataFrame operatior function (not exported).
2. Added errorbars_mean and errorbars_draws.
3. Added nested_column_to_array.
4. Made model_summary String/Symbol agnostic.

### Release 0.4.5

1. Doc fixes by Pietro Monticone
2. Added model_summary(::SampleModel).

### Release 0.4.x

1. Model_summary and plot_chains (accept both Symbol and Strings)
2. Focus on Appendices A and B.
3. Focus on chapters 4, 5, 6, 7

### Versions 0.3.6 - 0.3.10

1. Fine tuning working with ros_functions and ros_notebooks.

### Release 0.3.5

1. Added maintenance functions for a (large) set of notebooks.

### Release 0.3.4

1. Is tagging using JuliaHub with setting branch name working?

### Version 0.3.3

1. Add initial version of notebook maintenance routines.
2. Tag this version (if not done by TagBot)

### Version 0.3.2

1. Fix Makie and AoG glue scripts.

### Version 0.3.1

1. StatsFuns compat entry to 1.0.

### Version 0.3.0 (under development)

1. Switch back to using Requires.jl
2. Switch to using `eachindex()` where appropriate.
3. Experimental versions for chapter 3.

### Version 0.2.4

1. Chapter 2 mostly done
2. Added trankplot function

### Version 0.2.0

1. Support for the 5 examples from chapter 1 done.
2. Added plot_chains() and model_summary() functions.
3. Added Makie and AlgebraOfGraphics as dependencies.

Note: Source files for Makie/AoG are all in src/Makie/ to simplify moving those to a separate repo (not my intention right now, but still).

4. In sync with both ROS[Turing|Stan]Pluto projects tagged 2.3 and up.

### Version 0.1.0

1. Initial commit (to registrate the package for usage in projects).

## References

Of course this package is focused on:

0. [Gelman, Hill, Vehtari: Regression and Other Stories](https://www.cambridge.org/highereducation/books/regression-and-other-stories/DD20DD6C9057118581076E54E40C372C#overview)

which in a sense is a major update to item 3. below.

There is no shortage of other good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis Using Regression and Multilevel/Hierarchical Models](http://www.stat.columbia.edu/~gelman/arm/)

4. [McElreath: Statistical Rethinking](http://xcelab.net/rm/statistical-rethinking/)

5. [Kruschke: Doing Bayesian Data Analysis](https://sites.google.com/site/doingbayesiandataanalysis/what-s-new-in-2nd-ed)

6. [Lee, Wagenmakers: Bayesian Cognitive Modeling](https://www.cambridge.org/us/academic/subjects/psychology/psychology-research-methods-and-statistics/bayesian-cognitive-modeling-practical-course?format=PB&isbn=9781107603578)

7. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)

8. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

9. [Pearl, Glymour, Jewell: Causal Inference in Statistics: A Primer](https://www.wiley.com/en-us/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847)

10. [Pearl, Judea and MacKenzie, Dana: The Book of Why](https://www.basicbooks.com/titles/judea-pearl/the-book-of-why/9780465097616/)

11. [Scott Cunningham: Causal Inference - the mixtapes](https://mixtape.scunning.com)

A good book to understand most of the Julia constructs used in this book is:

12. [Bogumił Kamiński: Julia for Data Analysis](https://www.manning.com/books/julia-for-data-analysis).

