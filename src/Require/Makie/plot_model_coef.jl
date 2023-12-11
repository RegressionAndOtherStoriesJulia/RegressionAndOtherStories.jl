function plot_model_coef(s::Vector{NamedTuple},  pars::Vector{Symbol}; mnames=String[], fig="", title="")

    levels = length(s) * (length(pars) + 1)
    colors = [:blue, :red, :green, :darkred, :black, :grey, :darkblue, :cyan, :darkred]
    
    xmin = 0; xmax = 0.0
    for i in 1:length(s)
        for par in pars
            syms = Symbol.(keys(s[i]))
            if Symbol(par) in syms
                mp = s[i][par].mean
                xmin = min(xmin, s[i][par].lower)
                xmax = max(xmax, s[i][par].upper)
            end
        end
    end

    ylabs = String[]
    for j in 1:length(s)
        for i in 1:length(pars)
            l = length(String(pars[i]))
            str = repeat(" ", 9-l) * String(pars[i])
            append!(ylabs, [str])
        end
        l = length(mnames[j])
        str = mnames[j] * repeat(" ", 9-l)
        append!(ylabs, [str])
    end
    
    ys = [string(ylabs[i]) for i = 1:length(ylabs)]
    yran = range(1, stop=length(ylabs), length=length(ys))
    yticks = (yran, ys)
    
    f = Figure(;size =  default_figure_resolution)
    ax = Axis(f[1, 1]; title, yticks)
    xlims!(xmin-0.1(xmax-xmin), xmax+0.1(xmax-xmin))
    ylims!(0, 10)
    
    line = 0
    for mindx in 1:length(s)
        line += 1
        #hlines!([line] .+ length(pars), color=:darkgrey, line=(2, :dash))
        hlines!([line, line+1], color=:darkgrey, linewidth=2, linestyle=:dot)
        
        for (pindx, par) in enumerate(pars)
            line += 1
            syms = Symbol.(keys(s[mindx]))
            if Symbol(par) in syms
                ypos = (line - 1)
                mp = s[mindx][Symbol(par)].mean
                lower = s[mindx][Symbol(par)].lower
                upper = s[mindx][Symbol(par)].upper
                lines!( [lower, upper], [ypos, ypos]; color=colors[pindx])
                scatter!([mp], [ypos], color=colors[pindx])
                vlines!([0.0]; color=:grey, linewidth=2, linestyle=:dash)
            end
        end
        
    end
    
    (s, f)
end

export
    plot_model_coef
