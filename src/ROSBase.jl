module ROSBase

using Reexport

@reexport using CSV, DelimitedFiles, Unicode
@reexport using DataFrames

# Direct access to the R repository "ROS-Examples"

try
    src_path = ENV["JULIA_ROS_HOME"]
catch
    @warning "ENV["JULIA_ROS_HOME"] not available."
end

ros_path(parts...) = normpath(joinpath(src_path, parts...))
ros_data(dataset, parts...) = normpath(joinpath(src_path, dataset, "data",
    parts...))

# Access to "ROSStanPluto" repository data directory
ros_datadir(parts...) = normpath(joinpath(@__DIR__), "../data", 
    parts...)

#= Basic usage to read in a Stata file and store it to
hibbs = CSV.read(ros_data("ElectionsEconomy", "hibbs.dat"), DataFrame;
    delim=" ")
f = open("/Users/rob/.julia/dev/ROSStanPluto/data/ElectionsEconomy/hibbs.csv", "w")
CSV.write(f, hibbs)
close(f)
=#

export
    ros_path,
    ros_data,
    ros_datadir

end # module
