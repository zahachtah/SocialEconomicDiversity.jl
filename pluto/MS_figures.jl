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

# ╔═╡ Cell order:
# ╠═2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
# ╠═fe5ddb88-1fe3-11ef-133f-e38ab23873d9
