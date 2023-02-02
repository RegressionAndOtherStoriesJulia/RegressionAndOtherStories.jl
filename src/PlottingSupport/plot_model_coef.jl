function plot_model_coef(df::DataFrame, pars::Vector{Symbol};
    mname="", fig="", title="")

  if length(mname) > 9
    mname = mname[1:9]
  end
 
  s = Vector{NamedTuple}(undef, 1)
  for mindx in 1:1
    m, l, u = estimparam(df)
    d = Dict{Symbol, NamedTuple}()
    for (indx, par) in enumerate(names(df))
      d[Symbol(par)] = (mean=m[indx], lower=l[indx], upper=u[indx])
    end
    s[mindx] =   (; d...)
  end

  plot_model_coef(s, pars; mnames=[mname], fig, title)
end

function plot_model_coef(p::Pair{String, DataFrame}, pars::Vector{Symbol};
    fig="", title="")

  mname = p.first
  if length(mname) > 9
    mname = mname[1:9]
  end
 
  s = Vector{NamedTuple}(undef, 1)
  for mindx in 1:1
    m, l, u = estimparam(p.second)
    d = Dict{Symbol, NamedTuple}()
    for (indx, par) in enumerate(names(p.second))
      d[Symbol(par)] = (mean=m[indx], lower=l[indx], upper=u[indx])
    end
    s[mindx] =   (; d...)
  end

  plot_model_coef(s, pars; mnames=[mname], fig, title)
end

export
  plot_model_coef
