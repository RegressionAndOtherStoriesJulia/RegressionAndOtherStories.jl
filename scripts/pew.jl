### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ 7a3506e2-6287-4755-a715-cd1de9dffc4c
using Pkg, DrWatson

# ╔═╡ 4087e639-e1b9-4034-bb09-051ae0cc4e3d
begin
	using RegressionAndOtherStories
end

# ╔═╡ 27fd555f-2a13-4106-bcb5-6644e41dfb29
md" ##### As this is a good example of real life data-mangling, this file is in notebook format!."

# ╔═╡ d5f05d8b-416e-4648-89d8-afa937f30e77
md"
!!! note

Unfortunately this notebook is not complete. Translating R to Julia can be tricky!!!
"

# ╔═╡ ad1df579-dd25-4be3-9194-62019182e9c2
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""


# ╔═╡ a8a9aee2-f2fd-4176-9a45-570672d0eb94
begin
	pew_pre_raw = CSV.read(joinpath("/Users", "rob", ".julia", "dev", "RegressionAndOtherStories", "data", "Pew", "pew.csv"), DataFrame; missingstring="NA", pool=false)
	#pew_pre_raw = CSV.read(ros_datadir("Pew", "pew2.csv"), DataFrame; missingstring="NA", pool=false)
	pew_pre = pew_pre_raw[:, [:survey, :regicert,  :party, :state, :heat2, :heat4, :income2, :party4,
		:date, :weight, :voter_weight2, :pid, :ideology, :inc]]
end

# ╔═╡ 8ef8d7c5-219d-42e7-85a2-6dee7d237edb
N = size(pew_pre, 1)

# ╔═╡ 4859f90d-ccdf-4995-be0c-85faa9c02978
names(pew_pre)

# ╔═╡ 424f704a-0d61-45fa-a88f-3ad851b81f53
heat2_vals = unique(pew_pre.heat2)

# ╔═╡ 663a35fc-5c55-459c-be4a-b6be96d04eaf
pew_pre.heat2[1:10]

# ╔═╡ e05b1923-3137-47df-b49f-839cfae0bd2e
heat4_vals = unique(pew_pre.heat4)

# ╔═╡ 6383993d-ce7c-401d-a6a2-f87e19f85dd7
let
	res = Int[]
	ok = findall(x -> !ismissing(x), pew_pre.heat4)
	for heat4_val in heat4_vals[2:end]
		append!(res, [length(findall(x -> x == heat4_val, pew_pre.heat4[ok]))])
	end
	res
end

# ╔═╡ cff39c41-c8b6-49b3-9e5e-eeabf141a61f
rvote::Vector{Union{Missing, Int}} = repeat([missing]; inner=N);

# ╔═╡ b78a4c9a-452e-4a27-8cb3-63154d48d965
begin
	which_question = [!ismissing(pew_pre.heat2[i]) ? 2 : !ismissing(pew_pre.heat4[i]) ? 4 : 0 for i in 1:N]
end

# ╔═╡ 91a5866c-6723-46bd-b806-c2c9059c1244
length(which_question)

# ╔═╡ e8e32ea1-35f1-48fa-b5e4-bb5f2e845e10
findfirst(x -> x == 4, which_question)

# ╔═╡ 478230d4-f210-4df8-98e2-fdeaa88d3c7a
findall(x -> x == 4, which_question)

# ╔═╡ 0f27ef85-a4ce-4978-aac7-a1804f723ee0
length(findall(x -> x == 4, which_question))

# ╔═╡ 127ec62d-406e-40ca-93de-c32562e2a29f
mean(which_question)

# ╔═╡ bad9cf89-cc3a-4cb2-b139-ff8e1052818e
for i in 1:N
	if which_question[i] == 2
		rvote[i] = pew_pre.heat2[i] == "rep/lean rep" ? 1 : pew_pre.heat2[i] == "dem/lean dem" ? 0 : missing
	elseif which_question[i] == 4
		rvote[i] = pew_pre.heat4[i] == "rep/lean rep" ? 1 : pew_pre.heat4[i] == "dem/lean dem" ? 0 : missing
	end
end

# ╔═╡ 75e4d07d-90ff-402a-8918-4f0e68bbcf5d
pew_pre.rvote = rvote

# ╔═╡ 1040c140-5d2a-4352-a7f0-901f3a2b275a
(question = mean(which_question), rvote = mean(filter(!ismissing, rvote)))

# ╔═╡ d6ad38c9-5bc9-4d59-a1d8-b19ad76634dc
unique(pew_pre.regicert)

# ╔═╡ 9ce44159-004f-424a-8f8c-99e41b2dd622
registered = [!ismissing(pew_pre.regicert[i]) && pew_pre.regicert[i] == "absolutely certain" ? 1 : 0 for i in 1:N]

# ╔═╡ fbd7dfb4-1cd7-4aad-ad4b-b89e675376e7
mean(registered)

# ╔═╡ 836e78ed-98d9-4ff6-adda-e7cfa3080bcf
begin
	early = Vector(pew_pre.date) .> 90008
	late = Vector(pew_pre.date) .> 90008
	month = Int.(floor.(pew_pre.date ./ 10000))
	day = Int.(floor.(pew_pre.date ./ 100) .- 100month)
	day_numeric = month .* 31 .+ day
	poll_id = [
		month[i] == 6 ? 1 :
			month[i] == 7 && day[i] < 28 ? 2 :
				month[i] == 7 && day[i] >= 28 || month[i] == 8 ? 3 :
					month[i] == 9 && day[i] < 16 ? 4 :
						month[i] == 9 && day[i] >= 16 ? 5 :
							month[i] == 10 && day[i] < 14 ? 6 :
								month[i] == 10 && day[i]>=14 && day[i] < 20 ? 7 :
									month[i] == 10 && day[i] >= 20 && day[i] < 27 ? 8 : 9
										for i in 1:N]
	max_poll_id = maximum(poll_id)
end

# ╔═╡ db88ef04-e742-4336-b6c8-73eb5055e655
# R: 266804, 542365, 138996
[sum(month), sum(day), sum(poll_id)]

# ╔═╡ 745fb351-97c9-490c-b242-91937aefb895
let
	state_abr = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY",
		"LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK",
		"OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"];
	sn = unique(Vector{String}(sort(pew_pre.state)))
	state_names = vcat(sn[1], "alaska", sn[2:7], "dc", sn[8:46], sn[48:50])
	votes08 = [60,39, 62,36, 54,45, 58,39, 40,59, 46,53, 39,60, 37,62, 7,93, 49,51, 53,46, 25,74, 61,36, 38,61, 
		49,50, 45,54, 57,42, 58,41, 59,40, 40,58, 39,60, 36,62, 42,56, 44,54, 57,43, 49,49, 50,47, 57,41, 41,57, 
		44,55, 42,57, 42,57, 37,62, 49,50, 53,45, 47,51, 66,34, 42,56, 44,55, 35,63, 54,45, 54,44, 57,42, 55,44,
		62,35, 32,67, 48,52, 43,56, 56,43, 43,56, 65,33]
	obama08 = votes08[2:2:102]
	mccain08 = votes08[1:2:101]
	ovote_actual = obama08 ./ (obama08 .+ mccain08)
	global state_df = DataFrame(row=1:51, state=state_names, state_abbr=state_abr, obama08=obama08, mccain08=mccain08,
		actual=ovote_actual)
	state_df
end

# ╔═╡ 07fd84bd-7778-4ea1-ab87-190f4693c46d
begin
	pop_weight0 = Vector(pew_pre.weight)
	voter_weight0 = [ismissing(rvote[i]) || registered[i] == 0 ? missing : pop_weight0[i] for i in 1:N]
	
	pop_weight = repeat([missing], N)
	pop_weight = convert(Vector{Union{Missing, Float64}}, pop_weight)
	voter_weight = repeat([missing], N)
	voter_weight = convert(Vector{Union{Missing, Float64}}, voter_weight)
	for i in 1:max_poll_id
		ok = findall( x -> x == i, poll_id)
		pop_weight[ok] = pop_weight0[ok] / mean(pop_weight0[ok])
		voter_weight[ok] = voter_weight0[ok] / mean(filter(!ismissing, voter_weight0[ok]))
	end
end

# ╔═╡ 3c2f895a-f1d3-4c80-a9d6-1cb4ab3a083c
# [1] 1.326923 0.822000 0.493000 0.492000 2.000000 1.800000 1.384615 0.492000 1.081633 1.777778 0.571000 1.458000
pew_pre.pop_weight0 = pop_weight0

# ╔═╡ faf2626a-ac8a-4e74-b93c-8ccc8d8a4b69
# R: [1] 0.5936557  NA 0.5352379 0.5341522 0.8947854 0.6640835 0.6194668 0.5341522 0.4839145 0.6558850
pew_pre.voter_weight = voter_weight

# ╔═╡ 5344134a-9e47-4cf1-83a8-017f43736fa0
begin
	dems = Int[]; reps = Int[]
	votes = setdiff(1:N, findall(ismissing, rvote))
	for st in state_df.state
		state = findall(x -> x == st, pew_pre.state)
		if length(state) > 10
			valid = intersect(state, votes)
			append!(dems, [sum(rvote[valid] .== 0)])
			append!(reps, [sum(rvote[valid] .== 1)])
		else
			append!(dems, [0])
			append!(reps, [0])
		end
	end
	state_df.dems=dems
	state_df.reps=reps
	state_df
end

# ╔═╡ 354b330f-c86e-4f29-a2a7-2efc82f8f46a
pew_pre[:, [:state, :rvote, :voter_weight2]]

# ╔═╡ 02ab023b-199c-4134-9dc8-387c7963cdb3
let
	pew_df = pew_pre[completecases(pew_pre, [:rvote, :voter_weight]), [:state, :rvote, :voter_weight]]
end

# ╔═╡ 78426ef1-922f-4277-af1f-e3a1ef61ed6e
md"
!!! note

In below DataFrame I'm surprised `inc` does not always correspond with `income2`.
"

# ╔═╡ bace2090-e331-4a04-ab5e-6f68b6c6ce27
pew_pre[:, [:state, :inc, :income2]]

# ╔═╡ 235cb6da-5cc7-456a-8874-c1b1923cf956
sort(unique(pew_pre.inc))

# ╔═╡ e58d4b6f-820e-4d69-8919-682fbf9051fb
inc_vals = [5,15,25,35,45,62.5,87.5,125,200]

# ╔═╡ d3978285-5e7e-44c5-b06b-9a46fe6b62e0
max_inc = 9

# ╔═╡ d35a817a-1fe9-4ccc-9484-7b272985c194
sort(unique(pew_pre.pid))

# ╔═╡ cd1810bf-11ed-46b1-b5a3-39054202e740
sort(unique(filter(x -> !ismissing(x), pew_pre.pid)))

# ╔═╡ e6cf6020-0953-4e6d-9174-f21928a742da
pid_labels = ["Democrat", "Lean Dem.", "Independent", "Lean Rep.", "Republican"]

# ╔═╡ 4310a3bb-74f4-4746-a4df-a2f3528de248
max_pid = 5

# ╔═╡ 922cbd2d-2ef0-4d0b-a9d5-c3759774068f
sort(unique(pew_pre.ideology))

# ╔═╡ 21cd4f93-cd3f-4813-a292-d1a6aef39db9
ideology_labels = ["Very liberal", "Liberal", "Moderate", "Conservative", "Very conservative"]

# ╔═╡ 9a173de0-b44b-4ec7-ba86-f34a8f0fdf0e
max_ideo = 5

# ╔═╡ 2b6be5ad-411a-4e82-a713-e3a8e6140314
begin
	incprop = zeros(Union{Missing, Float64}, max_pid+1, max_inc)
	incprop[max_pid + 1, :] = ones(max_inc)
	vc = pew_pre[completecases(pew_pre, [:pid, :inc]), [:pid, :inc, :pop_weight0]]
	
	for i in 2:max_pid
		for j in 1:max_inc
			vcs = vc[vc.pid .< i .&& vc.inc .== j, :]
			incprop[i, j] = mean(vcs.pid, Weights(vcs.pop_weight0))
		end
	end
	incprop
	
end

# ╔═╡ d9c1c0a5-44fe-472f-a93c-9a3d38ef1a84
begin
	pid_incprob = CSV.read(joinpath("/Users", "rob", ".julia", "dev", "RegressionAndOtherStories", "data", "Pew", "pid_incprop.csv"), DataFrame; missingstring="NA", pool=false)
end

# ╔═╡ 272c6581-962e-461b-b99d-75c3ca9629c1
begin
	ideo_incprob = CSV.read(joinpath("/Users", "rob", ".julia", "dev", "RegressionAndOtherStories", "data", "Pew", "ideo_incprop.csv"), DataFrame; missingstring="NA", pool=false)
end

# ╔═╡ 7d9ce69d-6f62-4a99-91a2-2d9bab97eda1
let
	party_incprob_df = CSV.read(joinpath("/Users", "rob", ".julia", "dev", "RegressionAndOtherStories", "data", "Pew", "party_incprop.csv"), DataFrame; missingstring="NA", pool=false)
	party_incprob = reshape(Array(party_incprob_df)[:, 2:end], :, 3, 9)
	party_incprob[:, :, 9]
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DrWatson = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
RegressionAndOtherStories = "21324389-b050-441a-ba7b-9a837781bda0"

[compat]
DrWatson = "~2.9.1"
RegressionAndOtherStories = "~0.1.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0-DEV"
manifest_format = "2.0"
project_hash = "536dc4ec5f1876ca98d80512f9fd4510365e7f8b"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "109664d3a6f2202b1225478335ea8fea3cd8706b"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.5"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "5a4168170ede913a2cd679e53c2123cb4b889795"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.53"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DrWatson]]
deps = ["Dates", "FileIO", "JLD2", "LibGit2", "MacroTools", "Pkg", "Random", "Requires", "Scratch", "UnPack"]
git-tree-sha1 = "67e9001646db6e45006643bf37716ecd831d37d2"
uuid = "634d3b9d-ee7a-5ddf-bec9-22491ea816e1"
version = "2.9.1"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "65e4589030ef3c44d3b90bdc5aac462b4bb05567"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.8"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "81b9477b49402b47fbe7f7ae0b252077f53e4a08"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.22"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.81.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "58f25e56b706f95125dcb796f39e1fb01d913a71"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.10"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NamedTupleTools]]
git-tree-sha1 = "befc30261949849408ac945a1ebb9fa5ec5e1fd5"
uuid = "d9ec5142-1e00-5aa0-9d6a-321866360f50"
version = "0.14.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e8185b83b9fc56eb6456200e873ce598ebc7f262"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.7"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "28ef6c7ce353f0b35d0df0d5930e0d072c1f5b9b"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegressionAndOtherStories]]
deps = ["CSV", "CategoricalArrays", "DataFrames", "DataStructures", "Dates", "DelimitedFiles", "Distributions", "LaTeXStrings", "LinearAlgebra", "NamedArrays", "NamedTupleTools", "Reexport", "Statistics", "StatsBase", "Unicode"]
git-tree-sha1 = "40868309da2f6bf1c7821930ab3e49643283f3f2"
uuid = "21324389-b050-441a-ba7b-9a837781bda0"
version = "0.1.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c3d8ba7f3fa0625b062b82853a7d5229cb728b6b"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.1"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "72e6abd6fc9ef0fa62a159713c83b7637a14b2b8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.17"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.41.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "16.2.1+1"
"""

# ╔═╡ Cell order:
# ╟─27fd555f-2a13-4106-bcb5-6644e41dfb29
# ╟─d5f05d8b-416e-4648-89d8-afa937f30e77
# ╠═ad1df579-dd25-4be3-9194-62019182e9c2
# ╠═7a3506e2-6287-4755-a715-cd1de9dffc4c
# ╠═4087e639-e1b9-4034-bb09-051ae0cc4e3d
# ╠═a8a9aee2-f2fd-4176-9a45-570672d0eb94
# ╠═8ef8d7c5-219d-42e7-85a2-6dee7d237edb
# ╠═4859f90d-ccdf-4995-be0c-85faa9c02978
# ╠═424f704a-0d61-45fa-a88f-3ad851b81f53
# ╠═663a35fc-5c55-459c-be4a-b6be96d04eaf
# ╠═e05b1923-3137-47df-b49f-839cfae0bd2e
# ╠═6383993d-ce7c-401d-a6a2-f87e19f85dd7
# ╠═cff39c41-c8b6-49b3-9e5e-eeabf141a61f
# ╠═b78a4c9a-452e-4a27-8cb3-63154d48d965
# ╠═91a5866c-6723-46bd-b806-c2c9059c1244
# ╠═e8e32ea1-35f1-48fa-b5e4-bb5f2e845e10
# ╠═478230d4-f210-4df8-98e2-fdeaa88d3c7a
# ╠═0f27ef85-a4ce-4978-aac7-a1804f723ee0
# ╠═127ec62d-406e-40ca-93de-c32562e2a29f
# ╠═bad9cf89-cc3a-4cb2-b139-ff8e1052818e
# ╠═75e4d07d-90ff-402a-8918-4f0e68bbcf5d
# ╠═1040c140-5d2a-4352-a7f0-901f3a2b275a
# ╠═d6ad38c9-5bc9-4d59-a1d8-b19ad76634dc
# ╠═9ce44159-004f-424a-8f8c-99e41b2dd622
# ╠═fbd7dfb4-1cd7-4aad-ad4b-b89e675376e7
# ╠═836e78ed-98d9-4ff6-adda-e7cfa3080bcf
# ╠═db88ef04-e742-4336-b6c8-73eb5055e655
# ╠═745fb351-97c9-490c-b242-91937aefb895
# ╠═07fd84bd-7778-4ea1-ab87-190f4693c46d
# ╠═3c2f895a-f1d3-4c80-a9d6-1cb4ab3a083c
# ╠═faf2626a-ac8a-4e74-b93c-8ccc8d8a4b69
# ╠═5344134a-9e47-4cf1-83a8-017f43736fa0
# ╠═354b330f-c86e-4f29-a2a7-2efc82f8f46a
# ╠═02ab023b-199c-4134-9dc8-387c7963cdb3
# ╟─78426ef1-922f-4277-af1f-e3a1ef61ed6e
# ╠═bace2090-e331-4a04-ab5e-6f68b6c6ce27
# ╠═235cb6da-5cc7-456a-8874-c1b1923cf956
# ╠═e58d4b6f-820e-4d69-8919-682fbf9051fb
# ╠═d3978285-5e7e-44c5-b06b-9a46fe6b62e0
# ╠═d35a817a-1fe9-4ccc-9484-7b272985c194
# ╠═cd1810bf-11ed-46b1-b5a3-39054202e740
# ╠═e6cf6020-0953-4e6d-9174-f21928a742da
# ╠═4310a3bb-74f4-4746-a4df-a2f3528de248
# ╠═922cbd2d-2ef0-4d0b-a9d5-c3759774068f
# ╠═21cd4f93-cd3f-4813-a292-d1a6aef39db9
# ╠═9a173de0-b44b-4ec7-ba86-f34a8f0fdf0e
# ╠═2b6be5ad-411a-4e82-a713-e3a8e6140314
# ╠═d9c1c0a5-44fe-472f-a93c-9a3d38ef1a84
# ╠═272c6581-962e-461b-b99d-75c3ca9629c1
# ╠═7d9ce69d-6f62-4a99-91a2-2d9bab97eda1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
