using RegressionAndOtherStories
using Test

df = DataFrame(x = 1:10, y = 1:10)

@testset "test_hibbs.jl" begin

    mod_sum1 = model_summary(df, [:x, :y])
    @test mod_sum1[:x, :median] ≈ 5.5 atol=0.1

    mod_sum2 = model_summary(df, ["x", "y"])
    @test mod_sum2["x", "median"] ≈ 5.5 atol=0.1

    mod_sum3 = model_summary(df, ["x", "y", "z"])
    @test size(mod_sum3) == (2, 4)
    @test mod_sum3["x", "median"] ≈ 5.5 atol=0.1

    mod_sum4 = model_summary(df, ["z"])
    @test mod_sum4 === nothing

end