using RegressionAndOtherStories

hdi = CSV.read(ros_data("HDI", "hdi.dat"), DataFrame; delim=" ")
f = open(ros_datadir("HDI", "hdi.csv"), "w")
CSV.write(f, hdi)
close(f)

hdi = CSV.read(ros_datadir("HDI", "hdi.csv"), DataFrame)
