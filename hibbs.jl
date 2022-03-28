using RegressionAndOtherStories

hibbs = CSV.read(ros_data("ElectionsEconomy", "hibbs.dat"),
    DataFrame; delim=" ")
f = open(ros_datadir("ElectionsEconomy", "hibbs.csv"), "w")
CSV.write(f, hibbs)
close(f)

hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"),
    DataFrame)
