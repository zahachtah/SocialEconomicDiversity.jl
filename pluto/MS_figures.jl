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

# ╔═╡ a0593d27-36d8-421f-9ebb-8650b459b4c0


# ╔═╡ ed841aa0-0868-469a-a697-12bfa00c35d4


# ╔═╡ 6df01524-46b9-4ded-aa90-67960eca540c
function figure_explain_institutions()
end

# ╔═╡ 2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
function figure_institutional_analysis(S)
	f=Figure(size=(900,length(S)*300))
	k=2
	Label(f[1,1:2],text="Socio-economic Diversity",tellwidth=false)
	Label(f[2,1],text="Hypothetical Scenarios",tellwidth=false)
	Label(f[2,2],text="Incentives & Impacts Plot",tellwidth=false)
	Label(f[2,3:4],text="Institutional outcomes",tellwidth=false)
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

		
		M=zeros(length(s.institutional_impacts),4)
		for (k,inst_impact) in enumerate(s.institutional_impacts)
			M[k,1]=(maximum(inst_impact.resource)-inst_impact.resource[end])/inst_impact.resource[end]
			M[k,2]=(maximum(inst_impact.total)-inst_impact.total[end])/inst_impact.total[end]
			M[k,3]=(minimum(inst_impact.gini)-inst_impact.gini[end])/inst_impact.gini[end]
			q=inst_impact.gini.^-0.5 .+ inst_impact.total.^1
			M[k,4]=(maximum(q)-q[end])/q[end]
		end
		c=CairoMakie.Axis(f[i+k,3:4],aspect=length(s.institutional_impacts)/3)
		hidespines!(c)
		hidedecorations!(c)
		println(size(M))
		heatmap!(c,1:length(s.institutional_impacts),1:4,M,colormap=:balance,colorrange=(-1,1))
		[text!(c,x,y,text=string(floor(M[x,y]*100)),align=(:center,:baseline), color=abs(M[x,y])<0.5 ? :black : :white) for x in 1:length(s.institutional_impacts), y in 1:4]
text
	end
	f
end

# ╔═╡ 88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
function Scenarios(;random=false,distribution=Uniform)
	S=[]
	s1=scenario(
		w=sed(min=0.01,max=0.3,normalize=true;random,distribution),
		q=sed(mean=1.0,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and moderate impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	push!(S,s1)
	s1=scenario(
		w=sed(min=0.4,max=0.9,normalize=true;random,distribution),
		q=sed(mean=2.5,sigma=0.0,normalize=true;random),
		label="Moderate income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case2.png"
	)
	push!(S,s1)
		s1=scenario(
		w=sed(min=0.1,max=0.9,normalize=true,distribution=LogNormal;random),
		q=sed(mean=2.5,sigma=1.0,normalize=true;random),
		label="Few income opportunities, and high impact",
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
	I=[Market(target=:effort),Market(target=:yield), Protected_area(), Economic_incentive(target=:p), Dynamic_permit_allocation(criteria=:w), Dynamic_permit_allocation(criteria=:w, reverse=true)]
	for inst in I
		for j in 1:length(S)
			S[j].institution=[inst]
		end
		institutional_impact!(S)
	end
end

# ╔═╡ a056a4d9-6599-4a18-b105-c45a46ab3c9e
S[2]

# ╔═╡ 375767f6-fb7d-4b32-bc23-c1cc10d0e5fd
begin
	s=deepcopy(S[2])
	s.institution[1].value=0.47474747474747
	sim!(s)
	ff=Figure()
	aa=CairoMakie.Axis(ff[1,1])
	phaseplot!(aa,s, show_trajectory=true)
	ff
end

# ╔═╡ d01b8a26-d381-4e0e-8456-b2802beff4df
S[1].institutional_impacts

# ╔═╡ Cell order:
# ╠═b43c0e48-660e-435d-8384-6c675f276c19
# ╠═c589b69f-b5ef-47a1-8c25-0c4d7eee426e
# ╠═2d1dc9a6-08b5-4c36-809f-cbbf1a580795
# ╠═a814b70a-ffd2-405e-bf79-2fdd2f3327c7
# ╠═a0593d27-36d8-421f-9ebb-8650b459b4c0
# ╠═e65aabad-06fd-448a-abd8-c01ebae950ee
# ╠═a056a4d9-6599-4a18-b105-c45a46ab3c9e
# ╠═375767f6-fb7d-4b32-bc23-c1cc10d0e5fd
# ╠═ed841aa0-0868-469a-a697-12bfa00c35d4
# ╠═6df01524-46b9-4ded-aa90-67960eca540c
# ╠═2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
# ╠═88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
# ╠═d01b8a26-d381-4e0e-8456-b2802beff4df
# ╠═fe5ddb88-1fe3-11ef-133f-e38ab23873d9
