using RegressionAndOtherStories
using Test

df = DataFrame(v = 1:100, w=201:300)

m = errorbars_mean(df)

d = errorbars_draws(df)

@testset "errorbars" begin
    @test m[m.parameters .== "v", "se"][1] ≈ 2.9 atol=0.5
    @test d[d.parameters .== "w", "q"][1] == [24.75, 24.75]
end
