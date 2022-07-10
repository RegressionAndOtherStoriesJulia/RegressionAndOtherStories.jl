using RegressionAndOtherStories
using Test

df = DataFrame()
df.parameters = ["a", "b"]
df.x = [1, 2]
df.y = [3, 4]
df.z = [[5, 8], [9,4]]
df.a = [[1 2; 3 4], [5 2; 6 7]]
df

ms = ModelSummary(df)
#display(ms)

@testset "nested" begin
    @test ms("a", "z") == df.z[1]
    @test ms(:a, :z) == df.z[1]
    @test ms("a", :a) == df.a[1]
    @test ms("b", "z") == df.z[2]
    @test ms(:b, :z) == df.z[2]
    @test ms("b", :a) == df.a[2]
    @test nested_column_to_array(ms, :z) == [5.0 8.0; 9.0 4.0]
    @test nested_column_to_array(ms.df, :z) == [5.0 8.0; 9.0 4.0]
    @test nested_column_to_array(ms, "z") == [5.0 8.0; 9.0 4.0]
    @test nested_column_to_array(ms, "a") == 
        [1.0 2.0; 3.0 4.0;;; 5.0 2.0; 6.0 7.0]
    @test nested_column_to_array(ms.df, "a") == 
        [1.0 2.0; 3.0 4.0;;; 5.0 2.0; 6.0 7.0]
    @test nested_column_to_array(ms, :a) == 
        [1.0 2.0; 3.0 4.0;;; 5.0 2.0; 6.0 7.0]
end

ms("c", "z")
ms("a", "c")
ms(:c, :z)
ms(:a, :c)
