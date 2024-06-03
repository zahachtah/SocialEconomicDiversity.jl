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

# ╔═╡ 4845050b-3ffe-432b-b426-932c944b8b4e
md"
* illustrate how different w and q can result in similar impact/incentives!
* illustrate a incentive shift
* there are no Panaceas!
* incentive and impact plots reduce scenario diversity

Make a strong point about the usefulness to cast resource use systems into relative impact and incentive distributions! Econometrics can help this by discovering the Copulas! ML can be used to estimate incentive and impact distributions at higher resolutions! Imagine what we could do with the caletas data!!

todo:

* fix the Infinite for economic incentives
* solve the issue of permits taking so long.
* make simple notebook for marty
"

# ╔═╡ 4975bd4b-496b-4368-91e2-77c5cfc3e6c7

function newFigure3(;distribution=Uniform, title_font="Arial", annotation_font="Gloria Hallelujah",N=100,scale=1.0,vector_grid=20)
    f=Figure(size=(1200*scale,800*scale))
    A=Dict()
    basic_dynamics=CairoMakie.Axis(f[1,1],title="System Dynamics",titlefont=title_font)
    individual_dynamics=CairoMakie.Axis(f[2,1],title="Behavioural adaptability",titlefont=title_font)
    income_distribution=CairoMakie.Axis(f[3,1],title="Impact level, ē",titlefont=title_font)
    test=CairoMakie.Axis(f[1,2],title="Individual dynamics",titlefont=title_font)
    A[1,3]=CairoMakie.Axis(f[1,3],title="Development & Inequality",titlefont=title_font)
    A[1,4]=CairoMakie.Axis(f[1,4],title="Impact potential",titlefont=title_font)
    A[1,5]=CairoMakie.Axis(f[1,5],title="covar Impact - Incentive ",titlefont=title_font)

    A[2,2]=CairoMakie.Axis(f[2,2],title="Phase plane dynamics",titlefont=title_font)
    A[2,3]=CairoMakie.Axis(f[2,3],title="Individual actors responses",titlefont=title_font)
    A[2,4]=CairoMakie.Axis(f[2,4],title="Income distribution",titlefont=title_font)
    A[2,5]=CairoMakie.Axis(f[2,5],title="Incentive level, w̃",titlefont=title_font)
    
    A[3,2]=CairoMakie.Axis(f[3,2],title="Resource use, ū",titlefont=title_font)
    A[3,3]=CairoMakie.Axis(f[3,3],title="Resource level, y",titlefont=title_font)
    A[3,4]=CairoMakie.Axis(f[3,4],title="Resource use, u",titlefont=title_font)
    A[3,5]=CairoMakie.Axis(f[3,5],title="Resource use, u",titlefont=title_font)

    Ax=[basic_dynamics,individual_dynamics,income_distribution,test]
    [push!(Ax,A[i]) for i in eachindex(A)]
    [hidespines!(Ax[i]) for i in eachindex(Ax)]
    [hidedecorations!(Ax[i]) for i in eachindex(Ax)]

    Label(f[0,1],text="Dynamics",fontsize=20, tellwidth=false)
    Label(f[0,2],text="Incentives",fontsize=20, tellwidth=false)
    Label(f[0,3],text="Impacts",fontsize=20, tellwidth=false)
    Label(f[0,4],text="Actors",fontsize=20, tellwidth=false)
    Label(f[0,5],text="Sensitivity",fontsize=20, tellwidth=false)
    
    #Basic dynamnics
    s=scenario(a=5.5,r=1.0,w=sed(min=0.15,max=0.85,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)
    phaseplot!(basic_dynamics,s,show_trajectory=true, attractor_size=40,show_sustained=true,show_attractor=true,vector_field=true;vector_grid)

    individual_u!(individual_dynamics,s)
    incomes!(income_distribution,s)

    f
end

# ╔═╡ 5c3d7480-53d4-4be4-81b6-0f9280689be7
newFigure3()

# ╔═╡ 99e442ad-6c7a-496c-a2e0-25152f491d5e
SED(min=0.15,max=0.85,distribution=LogNormal,normalize=true)

# ╔═╡ eca75c3e-e7c7-4d01-9d6b-42d4a5ee7e78
SED(min=0.15,max=0.85)

# ╔═╡ a0593d27-36d8-421f-9ebb-8650b459b4c0


# ╔═╡ ed841aa0-0868-469a-a697-12bfa00c35d4


# ╔═╡ 6df01524-46b9-4ded-aa90-67960eca540c
function figure_explain_institutions()
end

# ╔═╡ 2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
function figure_institutional_analysis(S;dsize=250)
	f=Figure(size=(dsize*5,length(S)*dsize))
	k=2
	Label(f[1,1:3],text="Socio-economic Diversity\n ",tellwidth=false, color=:black)
	Label(f[2,1],text="Envisioned Scenarios",tellwidth=false, color=:black)
	
	Label(f[2,3],text="Incentives & Impacts Plot",tellwidth=false, color=:black)
	Label(f[2,4:5],text="Best Institutional Outcomes",tellwidth=false, color=:forestgreen)
	for (i,s) in enumerate(S)
		image_file = download(s.image)
		image = load(image_file)
		a=CairoMakie.Axis(f[i+k,1],aspect=1)
		hidespines!(a)
		hidedecorations!(a)
		image!(a,rotr90(image))

		d=CairoMakie.Axis(f[i+k,2],aspect=1)
		l1=lines!(d,s.w, linewidth=3,label="Alternative opportunities")
		l2=lines!(d,s.q,linewidth=3, label="Extraction potential")

		b=CairoMakie.Axis(f[i+k,3],aspect=1, xlabel="Resource level", ylabel="Participation")
		hidedecorations!(b,label=false)
		phaseplot!(b,s)

		
		M=zeros(length(s.institutional_impacts),4)
		for (k,inst_impact) in enumerate(s.institutional_impacts)
			M[k,1]=(maximum(inst_impact.resource)-inst_impact.resource[end])/inst_impact.resource[end]
			M[k,2]=(maximum(inst_impact.total)-inst_impact.total[end])/inst_impact.total[end]
			M[k,3]=-(minimum(inst_impact.gini)-inst_impact.gini[end])/inst_impact.gini[end]
			q=inst_impact.gini.^-0.5 .+ inst_impact.total.^1
			M[k,4]=(maximum(q)-q[end])/q[end]
		end
		xt=(1:length(s.institutional_impacts), [i.institution for i in S[1].institutional_impacts])
		yt=(1:4,reverse(["Resource revenue","Total revenue","Gini","Mixed T + G"]))
		c=CairoMakie.Axis(f[i+k,4:5],aspect=length(s.institutional_impacts)/3,xticks = xt, yticks=yt,xticklabelrotation=-pi/6, yaxisposition = :right)
		hidespines!(c)
		hidexdecorations!(c, ticklabels=(i==length(S) ? false : true))
		
		#println(size(M))
		heatmap!(c,1:length(s.institutional_impacts),reverse(1:4),M,colormap=:bam,colorrange=(-1,1))
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
end

# ╔═╡ 2d1dc9a6-08b5-4c36-809f-cbbf1a580795
begin
	S=Scenarios(); 
end

# ╔═╡ b43c0e48-660e-435d-8384-6c675f276c19
figure_institutional_analysis(S)

# ╔═╡ a059afec-8816-4043-9ca5-0474c5697584
md"
Figure 6. The outcomes of $(length(S)) hypothetical scenarios under different institutional arrangements. The images in the leftmost column are AI generated to emphasize that the scenarios are not real and represent an envisioned scenario that we have choosen in order to illustrate some general insights that can be gained from the approach presented in this paper. Here we have opted to only use alternative income distributions, w, and extraction capacity, q, to gereate the underlying socioeconomic diversity that results in the impact and incentive distributions. Note the different y-scales between scenarios.  

Tradable efforts are always better for both total revenues and inequality compared to tradable catches (yields).
"

# ╔═╡ 438f0a66-794c-4efc-89ef-0aaadfb8c148
S[1].institution

# ╔═╡ dc2f5246-53ae-434a-9101-4a848bb215f0
scatter(S[4].w̃)

# ╔═╡ a814b70a-ffd2-405e-bf79-2fdd2f3327c7
image_file = download(S[1].image)

# ╔═╡ e65aabad-06fd-448a-abd8-c01ebae950ee
begin
	I=[Market(target=:effort),Market(target=:yield), Protected_area(), Economic_incentive(target=:p),Economic_incentive(target=:q), Dynamic_permit_allocation(criteria=:w), Dynamic_permit_allocation(criteria=:w, reverse=true)]
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

# ╔═╡ 20aa630b-f177-417a-9daf-400945746df9
S[1].institutional_impacts

# ╔═╡ d01b8a26-d381-4e0e-8456-b2802beff4df
S[1].institutional_impacts

# ╔═╡ Cell order:
# ╠═4845050b-3ffe-432b-b426-932c944b8b4e
# ╠═b43c0e48-660e-435d-8384-6c675f276c19
# ╠═a059afec-8816-4043-9ca5-0474c5697584
# ╠═438f0a66-794c-4efc-89ef-0aaadfb8c148
# ╠═dc2f5246-53ae-434a-9101-4a848bb215f0
# ╠═5c3d7480-53d4-4be4-81b6-0f9280689be7
# ╠═4975bd4b-496b-4368-91e2-77c5cfc3e6c7
# ╠═99e442ad-6c7a-496c-a2e0-25152f491d5e
# ╠═eca75c3e-e7c7-4d01-9d6b-42d4a5ee7e78
# ╠═2d1dc9a6-08b5-4c36-809f-cbbf1a580795
# ╠═a814b70a-ffd2-405e-bf79-2fdd2f3327c7
# ╠═a0593d27-36d8-421f-9ebb-8650b459b4c0
# ╠═e65aabad-06fd-448a-abd8-c01ebae950ee
# ╠═a056a4d9-6599-4a18-b105-c45a46ab3c9e
# ╠═375767f6-fb7d-4b32-bc23-c1cc10d0e5fd
# ╠═ed841aa0-0868-469a-a697-12bfa00c35d4
# ╠═6df01524-46b9-4ded-aa90-67960eca540c
# ╠═2b05ad03-1cf0-4ffc-87d8-4aca8e88dcdb
# ╠═20aa630b-f177-417a-9daf-400945746df9
# ╠═88914d21-71ca-4c8e-88c2-2c1e3fd6f59a
# ╠═d01b8a26-d381-4e0e-8456-b2802beff4df
# ╠═fe5ddb88-1fe3-11ef-133f-e38ab23873d9
