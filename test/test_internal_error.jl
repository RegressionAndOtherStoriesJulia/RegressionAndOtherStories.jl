using CausalInference, DataFrames

# Generate some sample data to use with the PC algorithm

N = 1000 # number of data points

# define simple linear model with added noise
N = 20
A = rand(N)
C = rand(N) + 0.4 .* A
F = rand(N) + 0.5 .* C
B = rand(N)
E = rand(N) + 0.4 .* B
H = rand(N) + 0.5 .* E
G = rand(N) + 0.4 .* F
H = rand(N) + 0.5 .* G
D = rand(N) + 0.2 .* A + 0.3 .* B
F += 0.9 .* D
H += 0.95 .* D
df = DataFrame(A=A, B=B, C=C, D=D, E=E, F=F, G=G, H=H)

println("\nPcalg cmi df")
est_pcalg_cmi_df = pcalg(df, 0.25, cmitest)
est_pcalg_cmi_df |> display
