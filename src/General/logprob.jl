function logprob(ndf::DataFrame, x::Matrix, y::Vector, k=k)
    b = Matrix(hcat(ndf.b...)')
    mu = ndf.a .+ b * x[:, 1:k]'
    logpdf.(Normal.(mu , ndf.sigma),  y')
end

export
    logprob
