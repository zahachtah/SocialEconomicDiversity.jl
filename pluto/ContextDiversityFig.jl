### A Pluto.jl notebook ###
# v0.19.45

using Markdown
using InteractiveUtils

# ╔═╡ 429a942e-3bc0-11ef-13cb-c91f667111c7
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO
	set_theme!(theme_light())
end;

# ╔═╡ 2dff8a04-6bff-4b5c-8aeb-fdc74b82f756
md"
## Add test-institutions to main repo and use for both inst figs
"

# ╔═╡ 7bc11f71-6583-4010-8db5-c27cb3a32a84
function figure_institutional_analysis(S;dsize=250)
	f=Figure(size=(dsize*5,length(S)*dsize))
	k=2
	Label(f[1,1:3],text="Socio-economic Diversity\n ",tellwidth=false, color=:black)
	Label(f[2,1],text="Envisioned Scenarios",tellwidth=false, color=:black)
	
	Label(f[2,3],text="Incentives & Impacts Plot",tellwidth=false, color=:black)
	Label(f[2,4:5],text="Best Institutional Outcomes",tellwidth=false, color=:forestgreen)
	Label(f[2,6],text="Best Mixed T + G",tellwidth=false, color=:forestgreen)
	for (i,s) in enumerate(S)
		image_file = download(s.image)
		image = load(image_file)
		a=CairoMakie.Axis(f[i+k,1],aspect=1)
		hidespines!(a)
		hidedecorations!(a)
		image!(a,rotr90(image))

		d=CairoMakie.Axis(f[i+k,2],aspect=1)
		lines!(s.w,s.q,linewidth=3, label="")
		#l1=lines!(d,s.w, linewidth=3,label="Alternative opportunities")
		#l2=lines!(d,s.q,linewidth=3, label="Extraction potential")

		b=CairoMakie.Axis(f[i+k,3],aspect=1, xlabel="Resource level", ylabel="Participation")
		hidedecorations!(b,label=false)
		phaseplot!(b,s)

		
		M=zeros(length(s.institutional_impacts),4)
		for (k,inst_impact) in enumerate(s.institutional_impacts)
			M[k,1]=(maximum(inst_impact.resource))/inst_impact.resource[end]
			M[k,2]=(maximum(inst_impact.total))/inst_impact.total[end]
			M[k,3]=(minimum(inst_impact.gini))/inst_impact.gini[end]
			q=inst_impact.gini.^-0.5 .+ inst_impact.total.^1
			M[k,4]=(maximum(q)-q[end])/q[end]
		end
		println(M)
		xt=(1:length(s.institutional_impacts), [i.institution for i in S[1].institutional_impacts])
		yt=(1:4,reverse(["Resource revenue","Total revenue","Gini","Mixed T + G"]))
		c=CairoMakie.Axis(f[i+k,4:5],aspect=length(s.institutional_impacts)/3,xticks = xt, yticks=yt,xticklabelrotation=-pi/6, yaxisposition = :right)
		hidespines!(c)
		hidexdecorations!(c, ticklabels=(i==length(S) ? false : true))
		
		println(size(M))
		heatmap!(c,1:length(s.institutional_impacts),reverse(1:4),M,colormap=:bam,colorrange=(-0,2))
		[text!(c,x,y,text=string(round(M[x,5-y]*100,digits=0))[1:end-2],align=(:center,:baseline), color=abs(M[x,5-y])<0.5 ? :black : :white) for x in 1:length(s.institutional_impacts), y in 1:4]
		Legend(f[2,2],d, tellwidth=false,orientation=:vertical)
		e=CairoMakie.Axis(f[i+k,6])
		hidespines!(e)
		hidexdecorations!(e, ticklabels=(i==length(S) ? false : true))
		hideydecorations!(e)
		incomes!(e,s)
	end
	
	#Legend(f[2,2],text="Dimensional",tellwidth=false)
	f
end

# ╔═╡ cee59481-30d5-431c-a423-171447879c9c
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
		q=sed(mean=2.0,sigma=1.0,normalize=true;random),
		label="Few income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	push!(S,s1)
	s1=scenario(
		w=sed(min=0.5,max=1.9,normalize=true,distribution=LogNormal;random),
		q=sed(mean=2.9,sigma=2.5,normalize=true;random),
		label="Few income opportunities, and high impact,revq",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	push!(S,s1)
		s1=scenario(
		w=sed(min=0.01,max=0.3,normalize=true;random,distribution),
		q=sed(mean=0.3,sigma=0.0,normalize=true;random),
		label="High inequality, and low impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	push!(S,s1)
end

# ╔═╡ 45eb7519-8d4c-4896-b009-23dcc9b2bd88
begin
	S=Scenarios(random=true)
	I=[Market(target=:effort),Market(target=:yield), Protected_area(), Economic_incentive(target=:p, max=0.9),Economic_incentive(target=:q, max=0.9)]#, Dynamic_permit_allocation(criteria=:w), Dynamic_permit_allocation(criteria=:w, reverse=true)]
	for inst in I
		for j in 1:length(S)
			S[j].institution=[inst]
		end
		institutional_impact!(S)
	end
end

# ╔═╡ 05667aa8-4b3a-4b09-92f0-1bfbdbe8421f
figure_institutional_analysis(S)

# ╔═╡ 5f6b8b05-c5d8-4c6a-b611-7f66f512d671
S[1].institutional_impacts[end]

# ╔═╡ e4692397-5db3-41c6-b4a1-e9ad064e4944
lines(S[1].institutional_impacts[end].resource./S[1].institutional_impacts[end].resource[end])

# ╔═╡ 97ee5776-b31d-4eac-b556-6e8a834dc1cf
heatmap(S[1].institutional_impacts[end].U)

# ╔═╡ 20c4a692-d427-4d53-b516-aaf6365ce990
S[end].institution[1].subsidize=true

# ╔═╡ a2c630b0-d53f-4eb4-b838-c796141414d0
S[1].aū

# ╔═╡ Cell order:
# ╠═2dff8a04-6bff-4b5c-8aeb-fdc74b82f756
# ╠═05667aa8-4b3a-4b09-92f0-1bfbdbe8421f
# ╠═5f6b8b05-c5d8-4c6a-b611-7f66f512d671
# ╠═e4692397-5db3-41c6-b4a1-e9ad064e4944
# ╠═97ee5776-b31d-4eac-b556-6e8a834dc1cf
# ╠═20c4a692-d427-4d53-b516-aaf6365ce990
# ╠═a2c630b0-d53f-4eb4-b838-c796141414d0
# ╠═45eb7519-8d4c-4896-b009-23dcc9b2bd88
# ╠═7bc11f71-6583-4010-8db5-c27cb3a32a84
# ╠═cee59481-30d5-431c-a423-171447879c9c
# ╠═429a942e-3bc0-11ef-13cb-c91f667111c7
