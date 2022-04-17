function model_summary(model, pars; digits=2)
    parameters = Pair{Symbol, Int}[]
    estimates = zeros(length(pars), 4)
    for (indx, par) in enumerate(pars)
        append!(parameters, [par => indx])
        vals = model[:, par]
        estimates[indx, :] = [median(vals), mad(vals), mean(vals), std(vals)]
    end

    NamedArray(
        round.(estimates; digits=digits), 
        (OrderedDict(parameters...), 
        OrderedDict(:median=>1, :mad_sd=>2, :mean=>3, :std=>4)),
               ("Parameter", "Value")
    )
end

export
    model_summary
