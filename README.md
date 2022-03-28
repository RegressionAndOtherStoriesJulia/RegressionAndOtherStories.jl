# RegressionAndOtherStories.jl v0.1.0

| **Project Status**          |  **Build Status** |
|:---------------------------:|:-----------------:|
|![][project-status-img] | ![][CI-build] |

[CI-build]: https://github.com/stanjulia/StanSample.jl/workflows/CI/badge.svg?branch=master

[issues-url]: https://github.com/stanjulia/ROSbase.jl/issues

[project-status-img]: https://img.shields.io/badge/lifecycle-experimental-orange.svg

## Purpose (once completed, maybe late 2022)

RegressionAndOtherStories.jl contains supporting (Julia) functions and the data files used in ["Regression and Other Stories"](https://avehtari.github.io/ROS-Examples/) by Andrew Gelham, Jennifer Hill and Aki Vehtari.

## Contents

The **supporting functions** are intended to be used in (currently) 2 Julia projects (also under development), ROSStanPluto.jl and ROSTuringPluto.jl.
See the lists of exported and not exported funtiens at the end of this file.

All **data files** are in `.csv` format and located in the `data` directory.

If RegressionAndOtherStories.jl is loaded, the files can be read in as a DataFrame using:
```
hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"), DataFrame)
```

For that purpose `ros_datadir()` is exported.

If needed, Stata files (`.dat`) have been converted to `.csv` files using the scripts in the `scripts` directory, e.g. see `scripts\hdi.jl`. To access the Stata files in the R package `ROS-Examples` RegressionAndOtherStories.jl expects the environment variable `JULIA_ROS_HOME` to be defined, e.g.:
```
ENV["JULIA_ROS_HOME"] = expanduser("~/Projects/R/ROS-Examples")
```

R itself does not necessarily need to be installed for this to work. The ROS-Examples package can be found [here](https://github.com/avehtari/ROS-Examples).

If so desired, direct use of the Stata files is also possible as the Stata to .csv file conversion scripts mentioned above show.

## Approach

The approach taken in RegressionAndOtherStories.jl and associated projects is different from StatisticalRethinking.jl.

In StatisticalRethinking.jl I attempted to create an intermediate layer to convert Stan and Turing mcmc results to a set of common functions. I am no longer happy with the complexity that introduced. In RegressionAndOtherStories.jl all functions work on DataFrames. It's up to the notebooks to create appropriate DataFrames.

If this approach turns out to be an improvement, I will consider updating the corresponding StatisticalRethinking projects as well.

## Issues, comments and questions

Please file issues, comments and questions [here](https://github.com/stanjulia/ROSbase.jl/issues).

## Versions

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

9. [Causal Inference in Statistics - A Primer](https://www.wiley.com/en-us/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847)

10. [Pearl, Judea and MacKenzie, Dana: The Book of Why](https://www.basicbooks.com/titles/judea-pearl/the-book-of-why/9780465097616/)

11. [Scott Cunningham: Causal Inference - the mixtapes](https://mixtape.scunning.com)

## Functions defined in this package:

### Currently exported functions (see online help)

1. ros_path
2. ros_data
3. ros_datadir


### Currently not exported functions (see online help)

1. None yet

