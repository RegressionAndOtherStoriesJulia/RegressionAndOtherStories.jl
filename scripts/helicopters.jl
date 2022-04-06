using RegressionAndOtherStories

helicopters = CSV.read(ros_data("Helicopters", "helicopters.txt"),
    DataFrame; delim=" ")
f = open(ros_datadir("Helicopters", "helicopters.csv"), "w")
CSV.write(f, helicopters[:, 1:4])
close(f)

helicopters2 = CSV.read(ros_datadir("Helicopters", "helicopters.csv"), DataFrame)
