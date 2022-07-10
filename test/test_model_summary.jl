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


data = (N=16, vote=hibbs.vote, growth=hibbs.growth)
m1_1s = SampleModel("hibbs", stan1_1)
rc1_1s = stan_sample(m1_1s; data)
ss1_1 = describe(m1_1s, [:a, :b, :sigma])
post1_1s = read_samples(m1_1s, :dataframe)

ms1_1_1 = model_summary(post1_1s, [:a, :b, :sigma])
ms1_1_2 = model_summary(post1_1s, ["a", "b", "sigma"])

@testset "model_summary" begin
    @test ms1_1_1(:b, :mad_sd) ≈ 0.66 atol=0.04
    @test ms1_1_2(:b, :mad_sd) ≈ 0.66 atol=0.04

    @test ms1_1_1("b", "mad_sd") ≈ 0.66 atol=0.04
    @test ms1_1_2("b", "mad_sd") ≈ 0.66 atol=0.04
end

ss1_1 = describe(m1_1s, ["a", "b", "sigma"]; digits=2)

@testset "describe(SampleModel,...)" begin
    @test ss1_1(:a, :mean) ≈ 46.25 atol=1
    @test ss1_1(:b, :std) ≈ 0.69 atol=0.1

    @test ss1_1("a", "mean") ≈ 46.25 atol=1
    @test ss1_1("b", "50%") ≈ 3.07 atol=0.1
end

