function _getellipsepoints(cx, cy, rx, ry, θ)
    t = range(0, 2*pi, length=100)
    ellipse_x_r = @. rx * cos(t)
    ellipse_y_r = @. ry * sin(t)
    R = [cos(θ) sin(θ); -sin(θ) cos(θ)]
    r_ellipse = [ellipse_x_r ellipse_y_r] * R
    x = @. cx + r_ellipse[:,1]
    y = @. cy + r_ellipse[:,2]
    (x,y)
end


"""
# getellipsepoints

Plot confidence intervals of a covariance matrix.

$(SIGNATURES)

See the examples in `research/Ellipse/cov_ellipse.jl` in both the 
ROSTuringPluto and ROSStanPluto projects.

"""
function getellipsepoints(μ, Σ, confidence=0.95)
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

export
    getellipsepoints