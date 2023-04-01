using RegressionAndOtherStories, Test

dag_1 = "DiGraph dag_1 {A -> M; M -> D; A -> D;}"
d1 = create_dag()

update_dag!(d1, nothing; g_dot_repr=dag_1)

@testset "DAG" begin
    @test d1.g_dot_repr == dag_1
end
