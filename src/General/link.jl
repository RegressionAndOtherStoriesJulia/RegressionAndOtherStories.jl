"""
# link

Generalized link function to evaluate callable for all parameters in dataframe over range of x values.

$(SIGNATURES)

## Required arguments
* `dfa::DataFrame`: data frame with parameters
* `rx_to_val::Function`: function of two arguments: row object and x
* `xrange`: sequence of x values to be evaluated on

## Return values
Is the vector, where each entry was calculated on each value from xrange.
Every such entry is a list corresponding each row in the data frame.

## Examples
```jldoctest
julia> using RegressionAndOtherStories

julia> d = DataFrame(:a => [1,2], :b=>[1,1])
2×2 DataFrame
 Row │ a      b
     │ Int64  Int64
─────┼──────────────
   1 │     1      1
   2 │     2      1

julia> link(d, (r,x) -> r.a+x*r.b, 1:2)
2-element Vector{Vector{Int64}}:
 [2, 3]
 [3, 4]

```
"""
function link(dfa::DataFrame, rx_to_val::Function, xrange)
  [rx_to_val.(eachrow(dfa), (x,)) for x ∈ xrange]
end

export
  link