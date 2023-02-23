module StanExt

using RegressionAndOtherStories
import RegressionAndOtherStories: plot_model_coef

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using StanSample) : (using ..StanSample)

    function plot_model_coef(models::Vector{SampleModel},
        pars::Vector{Symbol}; fig="", title="")

        mnames = [models[i].name for i in 1:length(models)]
        for i in 1:length(mnames)
            if length(mnames[i]) > 9
                mnames[i] = mnames[i][1:9]
            end
        end
        
        s = Vector{NamedTuple}(undef, length(models))
        for (mindx, mdl) in enumerate(models)
            df = read_samples(mdl, :dataframe)
            m, l, u = estimparam(df)
            d = Dict{Symbol, NamedTuple}()
            for (indx, par) in enumerate(names(df))
                d[Symbol(par)] = (mean=m[indx], lower=l[indx], upper=u[indx])
            end
            s[mindx] =   (; d...)
        end
        
        plot_model_coef(s, pars; mnames, fig, title)
    end

end