using StanSample
using RegressionAndOtherStories
using Test

hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"), DataFrame)

stan1_1 = "
functions {
}
data {
    int<lower=1> N;      // total number of observations
    vector[N] growth;    // Independent variable: growth
    vector[N] vote;      // Dependent variable: votes 
}
parameters {
    real b;              // Coefficient independent variable
    real a;              // Intercept
    real<lower=0> sigma; // dispersion parameter
}
model {
    vector[N] mu;
    mu = a + b * growth;

    // priors including constants
    a ~ normal(50, 20);
    b ~ normal(2, 10);
    sigma ~ exponential(1);

    // likelihood including constants
    vote ~ normal(mu, sigma);
}";

data1_1s = (N=16, vote=hibbs.vote, growth=hibbs.growth);

m1_1s = SampleModel("hibbs", stan1_1)
rc1_1s = stan_sample(m1_1s; data=data1_1s)

if success(rc1_1s)
    sdf = read_summary(m1_1s)
    post1_1s = read_samples(m1_1s, :dataframe)
    ā, b̄, σ̄ = mean(Array(post1_1s), dims=1)

    @testset "test_hibbs.jl" begin
        @test ā ≈ 3.0 atol = 0.1
        @test b̄ ≈ 46.3 atol = 1.0
        @test σ̄ ≈ 3.6 atol = 0.2
    end
    
    @testset "model_summary" begin
        ms = model_summary(m1_1s, [:a, :b, :sigma])
        @test ms[:a, :mean] ≈ 46.5 atol=0.4

        ms = model_summary(m1_1s, [:a, :b, :sigma]; table_header_type=String)
        @test ms[:a, "mean"] ≈ 46.5 atol=0.4

        ms = model_summary(m1_1s, ["a", "b", "sigma"])
        @test ms["a", "mean"] ≈ 46.5 atol=0.4

        ms = model_summary(m1_1s, 
            Symbol.(["a", "b", "sigma"]); table_header_type=Symbol)
        @test ms[:a, :mean] ≈ 46.5 atol=0.4

        # Illegal input vector for params.

        ms = model_summary(m1_1s, [1, 2, 3])
        @test typeof(ms) <: NamedVector

    end
end
