### A Pluto.jl notebook ###
# v0.19.45

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

# ╔═╡ 8dc1246f-47ac-4a41-af25-bdbf4bad30c7
md"
## First we setup the main scenarios:
"

# ╔═╡ 1a452997-4471-4803-93e7-7b4c66fd676f
begin
	random=false
	distribution=LogNormal
	
	s1=scenario(
		w=sed(min=0.01,max=0.3,normalize=true;random,distribution),
		q=sed(mean=1.0,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and moderate impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	
	s2=scenario(
		w=sed(min=0.4,max=0.9,normalize=true;random,distribution),
		q=sed(mean=2.5,sigma=0.0,normalize=true;random),
		label="Moderate income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case2.png"
	)
	
	s3=scenario(
		w=sed(min=0.1,max=0.4,normalize=true,distribution=LogNormal;random),
		q=sed(mean=0.8,sigma=0.0,normalize=true;random),
		label="Few income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	
	s4=scenario(
		w=sed(min=0.5,max=1.9,normalize=true,distribution=LogNormal;random),
		q=sed(mean=2.9,sigma=1.5,normalize=true;random),
		label="Few income opportunities, and high impact,revq",
		image="http://zahachtah.github.io/CAS/images/case4.png"
	)
	
		s5=scenario(
		w=sed(min=0.01,max=0.3,normalize=true;random,distribution),
		q=sed(mean=0.3,sigma=0.0,normalize=true;random),
		label="High inequality, and low impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	Scenarios=[s1,s2,s3,s4,s5]


end

# ╔═╡ b7319260-9458-4405-b255-03d05a0cbc2a
begin
	f_scenarios=Figure(size=(length(Scenarios)*210,630))
	for (i,s) in enumerate(Scenarios)
		phaseplot!(CairoMakie.Axis(f_scenarios[4,i]),s)
		image_file = download(s.image)
		image = load(image_file)
		a=CairoMakie.Axis(f_scenarios[2,i],aspect=1)
		hidespines!(a)
		hidedecorations!(a)
		image!(a,rotr90(image))
		b=CairoMakie.Axis(f_scenarios[3,i],aspect=1)
		scatter!(b,s.w,s.q,markersize=2)
		c=CairoMakie.Axis(f_scenarios[1,i],aspect=1)
		hidespines!(c)
		hidedecorations!(c)
		text!(c,s.label,word_wrap_width=170,align = (:center, :bottom))
	end
f_scenarios
end

# ╔═╡ ef32418a-b12f-4cb2-a0e0-1a917fbde77f
md"
## Next we define the institutions we want to test"

# ╔═╡ c6a1ff96-8c69-463e-a8d5-b38629095507
begin
	iPH=Dynamic_permit_allocation(criteria=:w, reverse=true)
	iPL=Dynamic_permit_allocation(criteria=:w, reverse=false)
	iSE=Equal_share_allocation(target=:effort)
	iSY=Equal_share_allocation(target=:yield)
	iTE=Market(target=:effort)
	iTY=Market(target=:yield)
	iPA=Protected_area()
	iPAD=Protected_area()
	iEp=Economic_incentive(target=:p)
	iEq=Economic_incentive(target=:q)
	institutions=[iPH,iPL,iSE,iSY,iTE,iTY,iPA,iPAD,iEp,iEq] #iPL
end

# ╔═╡ 196ec14a-cb05-4d7a-80f7-14bfaf1e9b39
md"
Lets check how these institutions work for one scenario. First we do an institutioinal impact simulation for all institutions."

# ╔═╡ d8780d88-9152-49a8-8618-7f61077a7b6f
begin
	s=deepcopy(s4)
	s.institution=iPH
	s.institution.value=0.6
	sim!(s)
	phaseplot(s, show_trajectory=true)
end

# ╔═╡ 9bfe0351-1104-4eb6-9442-64e14c92ef09
[institutional_impact!(s,inst) for inst in institutions, s in Scenarios]

# ╔═╡ 3bea23bf-6fd7-480e-a95e-7d16b463943d
881/60

# ╔═╡ cefb72ec-13a2-4015-ab4e-6b5a607e3af7
begin
	f_inst_an=Figure(size=(600,1000))
	for (i,s) in enumerate(Scenarios)
		a=CairoMakie.Axis(f_inst_an[i,1])
		SocialEconomicDiversity.institutional_analysis!(a,s)
	end
	f_inst_an
end

# ╔═╡ 72edff09-b442-4373-bc63-58376ede8e35
[s.y for s in Scenarios]

# ╔═╡ e5bb31e1-762c-41c9-b640-a2b8b26433f3
[s.institutional_impacts[end-1].institution.subsidize for s in Scenarios]

# ╔═╡ d3068553-dd29-47d5-916d-ebf45ad931f3
md"
For price manipulations an economic incentive would be dynamic and depend on E * x as this is what the price refers to. so price subsidy of p+0.1 would result in a social cost of E * x * p+0.1

For alternative income manipulation we could assume the societal cost is the increase in sum(w) unless it is externa. If it is external (development aid) then the society gains and the developed world takes the cost?

for q its more tricky I think? should we assume that the increase in value that can be extracted is proportional to the cost of increasing q?
"

# ╔═╡ b57b09da-fd00-481e-9c72-a747bd3b0ee3
q=Economic_incentive(target=:w,subsidize=true,value=0.0, max=0.99,label="one", description="two")

# ╔═╡ e3b17d51-f786-44b9-b069-cc64a8d069b7
q.cost(0.1)

# ╔═╡ 533abaf9-8b4f-49e1-89ec-46417ac31cd4
institutional_impact!(s)

# ╔═╡ b054678b-a1e0-4620-8335-7fdeb559d451
s.institutional_impacts

# ╔═╡ cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
argmax(s.institutional_impacts[1].total)

# ╔═╡ d975d84f-2adf-49f3-a53a-aedbee4528f4
scatter(s.institutional_impacts[1].target,s.institutional_impacts[1].total)

# ╔═╡ 47eddb2d-2491-4b91-9a48-f668201b97c9
scatter(s.institutional_impacts[1].target,s.institutional_impacts[1].resource)

# ╔═╡ 1bc9fd6a-aae6-478c-9f0b-973364997d67
scatter(s.institutional_impacts[1].target,s.institutional_impacts[1].y)

# ╔═╡ 56564230-1a0c-4aef-9084-ac8f92795b67
s.institutional_impacts[1].target[68]

# ╔═╡ d487ea7b-07d0-4032-b3f5-207315fa962d
argmax(s.institutional_impacts[1].resource)

# ╔═╡ d6b400b3-cc55-463c-9027-8138a982f6a1
	w1=scenario(
		w=sed(min=0.5,max=1.9,normalize=true,distribution=LogNormal;random),
		q=sed(mean=2.9,sigma=2.5,normalize=true;random),
		label="Few income opportunities, and high impact,revq",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	weirdScenarios=[w1]

# ╔═╡ Cell order:
# ╟─8dc1246f-47ac-4a41-af25-bdbf4bad30c7
# ╠═1a452997-4471-4803-93e7-7b4c66fd676f
# ╠═b7319260-9458-4405-b255-03d05a0cbc2a
# ╟─ef32418a-b12f-4cb2-a0e0-1a917fbde77f
# ╠═c6a1ff96-8c69-463e-a8d5-b38629095507
# ╟─196ec14a-cb05-4d7a-80f7-14bfaf1e9b39
# ╠═d8780d88-9152-49a8-8618-7f61077a7b6f
# ╠═9bfe0351-1104-4eb6-9442-64e14c92ef09
# ╠═3bea23bf-6fd7-480e-a95e-7d16b463943d
# ╠═cefb72ec-13a2-4015-ab4e-6b5a607e3af7
# ╠═72edff09-b442-4373-bc63-58376ede8e35
# ╠═e5bb31e1-762c-41c9-b640-a2b8b26433f3
# ╠═d3068553-dd29-47d5-916d-ebf45ad931f3
# ╠═b57b09da-fd00-481e-9c72-a747bd3b0ee3
# ╠═e3b17d51-f786-44b9-b069-cc64a8d069b7
# ╠═533abaf9-8b4f-49e1-89ec-46417ac31cd4
# ╠═b054678b-a1e0-4620-8335-7fdeb559d451
# ╠═cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
# ╠═d975d84f-2adf-49f3-a53a-aedbee4528f4
# ╠═47eddb2d-2491-4b91-9a48-f668201b97c9
# ╠═1bc9fd6a-aae6-478c-9f0b-973364997d67
# ╠═56564230-1a0c-4aef-9084-ac8f92795b67
# ╠═d487ea7b-07d0-4032-b3f5-207315fa962d
# ╠═d6b400b3-cc55-463c-9027-8138a982f6a1
# ╠═aafff548-39d3-11ef-39ed-d166b0a452b7
