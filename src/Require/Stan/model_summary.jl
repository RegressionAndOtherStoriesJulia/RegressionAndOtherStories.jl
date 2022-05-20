import RegressionAndOtherStories: model_summary

function model_summary(model::SampleModel, params::Vector{Symbol};
    round_estimates=true)

    sdf = read_summary(model)
    
    stats=names(sdf)
    stats[8] = "n_eff"
    items = [2,4,5,6,7,8,10]
    
    # Remove unwanted rows and create parameter pairs
    count = 1
    df = DataFrame()
    parameters = Pair{Symbol, Int}[]
    for (index, par) in enumerate(sdf[:, :parameters])
        if par in params
            push!(df, sdf[index, items])
            append!(parameters, [par => count])
            count += 1
        end
    end
    
    statistics = Pair{String, Int}[]
    for (index, stat) in enumerate(stats[items])
        append!(statistics, [stat => index])
    end

    if round_estimates
        estimates = round.(Array(df); digits=3)
    else
        estimates = Array(df)
    end
    
    return NamedArray(
        estimates,
        (OrderedDict(parameters...), OrderedDict(statistics...)),
        ("Par", "Stat")
    )
end

function model_summary(model::SampleModel, params::Vector{String};
    round_estimates=true)

    sdf = read_summary(model)
    
    stats=names(sdf)
    stats[8] = "n_eff"
    items = [2,4,5,6,7,8,10]
    
    # Remove unwanted rows and create parameter pairs
    count = 1
    df = DataFrame()
    parameters = Pair{String, Int}[]
    for (index, par) in enumerate(String.(sdf[:, :parameters]))
        if par in params
            push!(df, sdf[index, items])
            append!(parameters, [par => count])
            count += 1
        end
    end
    
    statistics = Pair{String, Int}[]
    for (index, stat) in enumerate(stats[items])
        append!(statistics, [stat => index])
    end

    if round_estimates
        estimates = round.(Array(df); digits=3)
    else
        estimates = Array(df)
    end
    
    return NamedArray(
        estimates,
        (OrderedDict(parameters...), OrderedDict(statistics...)),
        ("Par", "Stat")
    )

end
