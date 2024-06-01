### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ fe5ddb88-1fe3-11ef-133f-e38ab23873d9
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics
	set_theme!(theme_light())
end;

# ╔═╡ 2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
function figureInstitutionalAnalysis(S::Array{Scenario})
	F=Figure()
	
end

# ╔═╡ 88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
function Scenarios(;random=false,distribution=Uniform)
	S=[]
	push!(S,
	scenario(
		w=SED(min=0.0,max=0.3,normalize=true;random,distribution),
		q=SED(mean=1.0,sigma=0.0,normalize=true;random)
	)
	)
end

# ╔═╡ 2d1dc9a6-08b5-4c36-809f-cbbf1a580795
S=Scenarios()

# ╔═╡ b43c0e48-660e-435d-8384-6c675f276c19
phaseplot(S[1])

# ╔═╡ Cell order:
# ╠═b43c0e48-660e-435d-8384-6c675f276c19
# ╠═2d1dc9a6-08b5-4c36-809f-cbbf1a580795
# ╠═2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
# ╠═88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
# ╠═fe5ddb88-1fe3-11ef-133f-e38ab23873d9
