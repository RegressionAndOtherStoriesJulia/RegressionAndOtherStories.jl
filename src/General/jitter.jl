"""
# jitter

Add jitter to a value (typically for plotting.

$(SIGNATURES)

## Required arguments
* `x`: Value

## Optional positional argument
* `j = 0.5: Jitter range bound for Uniform(-j, j)

```
"""
function jitter(x, j=0.5)
  x + rand(Uniform(-j, j))
end

export
  jitter
