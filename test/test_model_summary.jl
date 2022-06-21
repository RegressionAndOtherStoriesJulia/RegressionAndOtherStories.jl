using RegressionAndOtherStories
using Test

df = DataFrame(x = 1:10, y = 1:10)

@testset "model_summary(df)" begin

    ms = model_summary(df, [:x, :y])
    @test ms[:x, :median] ≈ 5.5 atol=0.1

    ms = model_summary(df, ["x", "y"])
    @test ms["x", "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, [:x, :y]; table_header_type = String)
    @test ms[:x, "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, [:x, :y]; 
        round_estimates=false, table_header_type = String)
    @test ms[:x, "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, [:x, :y]; 
        digits = 5, table_header_type = String)
    @test ms[:x, "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, ["x", "y"])
    @test ms["x", "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, ["x", "y"]; table_header_type = Symbol)
    @test ms["x", :median] ≈ 5.5 atol=0.1

    ms = model_summary(df, ["x", "y", "z"])
    @test size(ms) == (2, 4)
    @test ms["x", "median"] ≈ 5.5 atol=0.1

    ms = model_summary(df, ["z"])
    @test typeof(ms) <: NamedArray

end