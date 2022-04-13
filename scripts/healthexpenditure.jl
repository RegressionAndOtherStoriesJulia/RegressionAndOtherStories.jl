using RegressionAndOtherStories

expend = CSV.read(ros_data("HealthExpenditure", "healthexpenditure.csv"),
    DataFrame)

life = CSV.read(ros_data("HealthExpenditure", "lifeexpectancy.csv"),
    DataFrame)

function fmax(a)
    maximum(filter(x ->!ismissing(x) .&& typeof(x) <: Number, a))
end

country = Vector(expend[4:33, 1])
country[5] = "Czech"
country[20] = "N.Zealand"
country[29] = "UK"
country[30] = "USA"

spending = [fmax(x) for x in [Vector(expend[i, 2:end]) for i in 4:33]]
lifespan = [fmax(x) for x in [Vector(life[i, 2:end]) for i in 4:33]]

df = DataFrame(
        country = country,
        spending = spending,
        lifespan = lifespan
    )

df |> display

CSV.write(ros_datadir("HealthExpenditure", "healthdata.csv"), df)
