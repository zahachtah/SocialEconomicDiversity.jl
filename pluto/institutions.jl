### A Pluto.jl notebook ###
# v0.19.43

using Markdown
using InteractiveUtils

# ╔═╡ aafff548-39d3-11ef-39ed-d166b0a452b7
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO
	set_theme!(theme_light())
end;

# ╔═╡ ebfca2b0-90ba-44f5-8d73-4fc21d8ca338
s=scenario(ū=sed(mean=2.0,sigma=0.0, normalize=true),institution=Economic_incentive(target=:w,subsidize=true,value=0.7, max=0.99));

# ╔═╡ b57b09da-fd00-481e-9c72-a747bd3b0ee3
q=Economic_incentive(target=:w,subsidize=true,value=0.0, max=0.99,label="one", description="two")

# ╔═╡ 533abaf9-8b4f-49e1-89ec-46417ac31cd4
institutional_impact!(s)

# ╔═╡ ee9407fa-3141-451f-8710-69e1653899ea
heatmap(s.institutional_impacts[1].U)

# ╔═╡ b054678b-a1e0-4620-8335-7fdeb559d451
s.institutional_impacts[1]

# ╔═╡ cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
s.aw̃

# ╔═╡ d975d84f-2adf-49f3-a53a-aedbee4528f4
scatter(s.institutional_impacts[1].target,s.institutional_impacts[1].total)

# ╔═╡ 56564230-1a0c-4aef-9084-ac8f92795b67
s.institutional_impacts[1].total

# ╔═╡ d487ea7b-07d0-4032-b3f5-207315fa962d
argmax(s.institutional_impacts[1].total)

# ╔═╡ 86b4c695-a9b0-4020-a6df-5c588a9d6b72
phaseplot(s)

# ╔═╡ Cell order:
# ╠═ebfca2b0-90ba-44f5-8d73-4fc21d8ca338
# ╠═b57b09da-fd00-481e-9c72-a747bd3b0ee3
# ╠═533abaf9-8b4f-49e1-89ec-46417ac31cd4
# ╠═ee9407fa-3141-451f-8710-69e1653899ea
# ╠═b054678b-a1e0-4620-8335-7fdeb559d451
# ╠═cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
# ╠═d975d84f-2adf-49f3-a53a-aedbee4528f4
# ╠═56564230-1a0c-4aef-9084-ac8f92795b67
# ╠═d487ea7b-07d0-4032-b3f5-207315fa962d
# ╠═86b4c695-a9b0-4020-a6df-5c588a9d6b72
# ╠═aafff548-39d3-11ef-39ed-d166b0a452b7
