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
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO
	set_theme!(theme_light())
end;

# ╔═╡ 6df01524-46b9-4ded-aa90-67960eca540c
function figure_explain_institutions()
end

# ╔═╡ 2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
function figure_institutional_analysis(S)
	f=Figure(size=(600,length(S)*300))
	k=2
	Label(f[1,1:2],text="Socio-economic Diversity",tellwidth=false)
	Label(f[2,1],text="Hypothetical Scenarios",tellwidth=false)
	Label(f[2,2],text="Incentives & Impacts",tellwidth=false)
	for (i,s) in enumerate(S)
		image_file = download(s.image)
		image = load(image_file)
		a=CairoMakie.Axis(f[i+k,1],aspect=1)
		hidespines!(a)
		hidedecorations!(a)
		image!(a,rotr90(image))

		b=CairoMakie.Axis(f[i+k,2],aspect=1, xlabel="Resource level", ylabel="Participation")
		hidedecorations!(b,label=false)
		phaseplot!(b,s)
	end
	f
end

# ╔═╡ 88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
function Scenarios(;random=false,distribution=Uniform)
	S=[]
	s1=scenario(
		w=SED(min=0.0,max=0.3,normalize=true;random,distribution),
		q=SED(mean=1.0,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and moderate impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	push!(S,s1)
	s1=scenario(
		w=SED(min=0.4,max=0.9,normalize=true;random,distribution),
		q=SED(mean=1.0,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and moderate impact",
		image="http://zahachtah.github.io/CAS/images/case2.png"
	)
	push!(S,s1)
		s1=scenario(
		w=SED(min=0.4,max=0.9,normalize=true;random,distribution),
		q=SED(mean=1.0,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and moderate impact",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	push!(S,s1)
end

# ╔═╡ 2d1dc9a6-08b5-4c36-809f-cbbf1a580795
begin
	S=Scenarios(); 
end

# ╔═╡ b43c0e48-660e-435d-8384-6c675f276c19
figure_institutional_analysis(S)

# ╔═╡ c589b69f-b5ef-47a1-8c25-0c4d7eee426e
fieldnames(typeof(S[1]))

# ╔═╡ a814b70a-ffd2-405e-bf79-2fdd2f3327c7
image_file = download(S[1].image)

# ╔═╡ e65aabad-06fd-448a-abd8-c01ebae950ee
begin
	for i in 1:length(S)
		S[i].institution=[Market(target=:effort)]
	end
	institutional_impact!(S)
end

# ╔═╡ a056a4d9-6599-4a18-b105-c45a46ab3c9e
typeof(S[1].institution[1])

# ╔═╡ d01b8a26-d381-4e0e-8456-b2802beff4df


# ╔═╡ Cell order:
# ╠═b43c0e48-660e-435d-8384-6c675f276c19
# ╠═c589b69f-b5ef-47a1-8c25-0c4d7eee426e
# ╠═2d1dc9a6-08b5-4c36-809f-cbbf1a580795
# ╠═a814b70a-ffd2-405e-bf79-2fdd2f3327c7
# ╠═e65aabad-06fd-448a-abd8-c01ebae950ee
# ╠═a056a4d9-6599-4a18-b105-c45a46ab3c9e
# ╠═6df01524-46b9-4ded-aa90-67960eca540c
# ╠═2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
# ╠═88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
# ╠═d01b8a26-d381-4e0e-8456-b2802beff4df
# ╠═fe5ddb88-1fe3-11ef-133f-e38ab23873d9
