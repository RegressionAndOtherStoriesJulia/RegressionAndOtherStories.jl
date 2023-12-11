module MakieExt

using RegressionAndOtherStories
import RegressionAndOtherStories: plot_model_coef, trankplot, plot_chains, pairplot

RegressionAndOtherStories.EXTENSIONS_SUPPORTED ? (using Makie) : (using ..Makie)

function plot_model_coef(s::Vector{NamedTuple},
    pars::Vector{Symbol}; mnames=String[], fig="", title="")

    levels = length(s) * (length(pars) + 1) + 1
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
            str = repeat(" ", levels-l) * String(pars[i])
            append!(ylabs, [str])
        end
        l = length(mnames[j])
        str = mnames[j] * repeat(" ", levels-l)
        append!(ylabs, [str])
    end
    
    ys = [string(ylabs[i]) for i = 1:length(ylabs)]
    yran = range(1, stop=length(ylabs), length=length(ys))
    yticks = (yran, ys)
    
    f = Figure(;size =  default_figure_resolution)
    ax = Axis(f[1, 1]; title, yticks)
    xlims!(xmin-0.1(xmax-xmin), xmax+0.1(xmax-xmin))
    ylims!(0, levels)
    
    line = 0
    for mindx in 1:length(s)
        line += 1
        #hlines!([line] .+ length(pars), color=:darkgrey, line=(2, :dash))
        hlines!([line + length(pars)], color=:darkgrey, linewidth=2, linestyle=:dot)
        
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

function trankplot(df::DataFrame, param::AbstractString;
        bins=40, n_draws=1000, n_chains=4, n_eff=0, kwargs...)

    nt_args = (n_draws=n_draws, n_chains=n_chains)
    ranks = RegressionAndOtherStories.rank_vector(df[:, param], nt_args)
    
    f = Figure(;size =  default_figure_resolution)
    if n_eff > 0
        ax = Axis(f[1, 1]; 
            title="Trankplot of parameter $(param) (n_eff = $(n_eff))")
    else
        ax = Axis(f[1, 1])
    end
    
    Makie.xlims!(ax, 1, 41)
    colors = [:black, :green, :blue, :red]

    for j in 1:4
        bv = RegressionAndOtherStories.bin_vector(ranks[:, j], 40)
        s = [Meta.parse(string(split(string(cut(bv, 40)[i])[2:4], ":")[1])) for i in 1:40]
        for i in 1:40
            lines!([Float64(i), Float64(i+1)], [s[i], s[i]]; color=colors[j])
            if i == 1
                lines!([Float64(i), Float64(i)], [20, s[i]]; color=colors[j])
                lines!([Float64(i+1), Float64(i+1)], [s[i], s[i+1]]; color=colors[j])
            elseif i < 40
                lines!([Float64(i+1), Float64(i+1)], [s[i], s[i+1]]; color=colors[j])
            elseif i == 40
                lines!([Float64(i+1), Float64(i+1)], [s[i], 20]; color=colors[j])
            end
        end
    end
    f
end

function plot_chains(df::DataFrame, pars::Vector{Symbol};
    no_of_chains=4, no_of_draws=1000, kwargs...)

    dft = deepcopy(df)

    dft[!, :chain] = repeat(collect(1:no_of_chains); inner=no_of_draws)
    dft[!, :chain] = categorical(dft.chain)

    fig = Figure(;size =  default_figure_resolution)
    for i in 1:length(pars)
        ax = Axis(fig[i, 1]; ylabel="$(pars[i])", xlabel="Iteration", title="Traces")
        for j in 1:no_of_chains
            plt = lines!(dft[dft.chain .== j, pars[i]])
        end
        ax = Axis(fig[i, 2]; ylabel="pdf", xlabel="$(pars[i])", title="Density $(pars[i])")
        for j in 1:no_of_chains
            U = kde(dft[dft.chain .== j, pars[i]]; kwargs...)
            den = lines!(U.x, U.density)
            xs = LinRange(minimum(U.x), maximum(U.x), length(U.density))
            ys_low = zeros(length(U.density))
            ys_high = U.density
            band!(xs, ys_low, ys_high; color=:lightgrey)
        end
    end
    return fig
end

function RegressionAndOtherStories._getellipsepoints(cx, cy, rx, ry, θ)
    t = range(0, 2*pi, length=100)
    ellipse_x_r = @. rx * cos(t)
    ellipse_y_r = @. ry * sin(t)
    R = [cos(θ) sin(θ); -sin(θ) cos(θ)]
    r_ellipse = [ellipse_x_r ellipse_y_r] * R
    x = @. cx + r_ellipse[:,1]
    y = @. cy + r_ellipse[:,2]
    (x,y)
end

function RegressionAndOtherStories.getellipsepoints(μ, Σ, confidence=0.95)
    quant = quantile(Chisq(2), confidence) |> sqrt
    cx = μ[1]
    cy =  μ[2]
    
    egvs = eigvals(Σ)
    if egvs[1] > egvs[2]
        idxmax = 1
        largestegv = egvs[1]
        smallesttegv = egvs[2]
    else
        idxmax = 2
        largestegv = egvs[2]
        smallesttegv = egvs[1]
    end

    rx = quant*sqrt(largestegv)
    ry = quant*sqrt(smallesttegv)
    
    eigvecmax = eigvecs(Σ)[:,idxmax]
    θ = atan(eigvecmax[2]/eigvecmax[1])
    if θ < 0
        θ += 2*π
    end

    _getellipsepoints(cx, cy, rx, ry, θ)
end

function RegressionAndOtherStories.pairplot(df; stride=1, colormap=:thermal,
    fsize =  default_figure_resolution)

    dim = size(df, 2) # how many colums there are in the dataframe
    idxs = 1:stride:size(df,1)
    colorant = range(0, 1, length=length(idxs))
    tv = names(df)

    pp_theme = Attributes(
        Axis = (
            aspect = 1,
            topspinevisible = false,
            rightspinevisible = false
        ),
        Scatter = (
            colormap = colormap, # try :thermal, :darkrainbow
            markersize = 10
        )
    )

    f = with_theme(pp_theme) do
        f = Figure(;size = fsize)

        for i in 1:dim, j in 1:dim

            ax = Axis(f[i, j]; title = "$(tv[i]) ~ $(tv[j])")
            scatter!(df[idxs,j], df[idxs,i], color = colorant)

            if i==dim
                ax.xticklabelsvisible = true
                ax.xlabel = names(df)[j]
            end
            if j==1
                ax.yticklabelsvisible = true
                ax.ylabel = names(df)[i]
            end
        end
        f
    end
end

end


