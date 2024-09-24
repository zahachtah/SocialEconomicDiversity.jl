### A Pluto.jl notebook ###
# v0.19.46

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
		w=sed(min=0.01,max=0.3,normalize=true;random,distribution),
		q=sed(mean=3.5,sigma=1.0,normalize=true;random),
		label="Moderate income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case2.png"
	)
	
	s3=scenario(
		w=sed(min=0.1,max=0.3,normalize=true,distribution=LogNormal;random),
		q=sed(mean=0.8,sigma=-1.0,normalize=true;random),
		label="Few income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case3.png"
	)
	
	s4=scenario(
		w=sed(min=0.4,max=2.5,normalize=true,distribution=LogNormal;random),
		q=sed(mean=2.9,sigma=1.5,normalize=true;random),
		label="Few income opportunities, and high impact,revq",
		image="http://zahachtah.github.io/CAS/images/case4.png"
	)
	
		s5=scenario(
		w=sed(min=0.01,max=90.3,normalize=true;random,distribution),
		q=sed(mean=3.5,sigma=1.0,normalize=true;random),
		label="High inequality, and low impact",
		image="http://zahachtah.github.io/CAS/images/case1.png"
	)
	Scenarios=[s1,s2,s3,s4]


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
	iPH=Dynamic_permit_allocation(criteria=:w, reverse=true, label="Use rights\nGreed")
	iPL=Dynamic_permit_allocation(criteria=:w, reverse=false, label="Use rights\nNeed")
	iSE=Equal_share_allocation(target=:effort, label="Equal share\neffort")
	iSY=Equal_share_allocation(target=:yield, label="Equal share\nyield")
	iTE=Market(target=:effort, label="Tradable\neffort")
	iTY=Market(target=:yield, label="Tradable\nyield")
	iPA=Protected_area()
	iEp=Economic_incentive(target=:p,max=0.9)
	iEq=Economic_incentive(target=:q,max=0.9)
	institutions=[iPH,iPL,iSE,iSY,iTE,iTY,iPA,iEp,iEq] #iPL,iEp
end

# ╔═╡ 196ec14a-cb05-4d7a-80f7-14bfaf1e9b39
md"
Lets check how these institutions work for one scenario. First we do an institutioinal impact simulation for all institutions."

# ╔═╡ 9bfe0351-1104-4eb6-9442-64e14c92ef09
[institutional_impact!(s,inst) for inst in institutions, s in Scenarios]

# ╔═╡ 30976e77-1f49-4e89-810c-6414ff0f8292
institutions

# ╔═╡ 72edff09-b442-4373-bc63-58376ede8e35
[s.y for s in Scenarios]

# ╔═╡ d3068553-dd29-47d5-916d-ebf45ad931f3
md"
For price manipulations an economic incentive would be dynamic and depend on E * x as this is what the price refers to. so price subsidy of p+0.1 would result in a social cost of E * x * p+0.1

For alternative income manipulation we could assume the societal cost is the increase in sum(w) unless it is externa. If it is external (development aid) then the society gains and the developed world takes the cost?

for q its more tricky I think? should we assume that the increase in value that can be extracted is proportional to the cost of increasing q?
"

# ╔═╡ 56564230-1a0c-4aef-9084-ac8f92795b67
md"# Income distributions as options!
# Shade grays as best of institutions!
## y could be a ecosystem status, e.g. preserve coral reef grazing
## somethings fishy with trade revenues for market effort
"

# ╔═╡ 2ce64071-bcf2-431e-8ab6-e9d6a1da2cea
md"
# Cross context/scenario comparison of institutional performance
"

# ╔═╡ 9c5d3d93-17c6-4d15-bd91-abb31f0868cb
function compare_institutions(s;base=130, indexed=:w̃, saveas="../figures/Institutions.png")
	ci=[1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14] # 15 is gray
	I=s.institutional_impacts
	if length(I)<1
		println("No institutional_impacts recorded")
		return
	end
	vlw=3
	vlc=:black
	glw=4
	f=Figure(size=((1+length(I))*base,(5+3)*base))
	q=1
	A=[]
	B=[]
	C=[]
	D=[]
	E=[]
	F=[]
	G=[]
	sc=deepcopy(s)
	s.color=HSL(0,0,0.5)
	mR=maximum([maximum(i.resource) for i in I])
	mT=maximum([maximum(i.total) for i in I])
	mG=minimum([minimum(i.gini) for i in I])
	Label(f[0,1:length(I)],"Policy Instruments:", fontsize = 22, font=:bold, tellwidth=false)
	Label(f[2:4,0],"Governance performance goals", fontsize = 18, font=:bold, tellwidth=true, rotation=pi/2)
	Label(f[5:7,0],"Income distribution at optimal regulation", fontsize = 18, font=:bold, tellwidth=true, rotation=pi/2)
	Label(f[8,0],"Participation", fontsize = 18, font=:bold, tellwidth=true, rotation=pi/2)
	for i =1:length(I)
		Label(f[1,i],I[i].institution.label, fontsize = 16, font=:bold, tellwidth=false,color=convert(HSL,ColorSchemes.tab20[ci[i]]))
		push!(A,CairoMakie.Axis(f[q+7,i]))
		hidedecorations!(A[i])
		sc.institution=[I[i].institution]
		sc.institution[1].value=I[i].target[argmax(I[i].resource)]
		sc.color=convert(HSL,ColorSchemes.tab20[ci[i]])
		sim!(sc)
		phaseplot!(A[i],s)
		phaseplot!(A[i],sc,show_realized=true, show_potential=false)
		
		push!(B,CairoMakie.Axis(f[q+1,i],xreversed=true,backgroundcolor=HSL(0,0,maximum(I[i].resource)/mR), ylabel="Resource",ylabelfont=:bold))
		i==1 ? hidexdecorations!(B[i]) : hidedecorations!(B[i])
		lines!(B[i],I[i].target,getfield(I[i],:resource), color=ColorSchemes.tab20[ci[i]], linewidth=glw)
		vlines!(B[i],I[i].target[argmax(I[i].resource)], color=vlc, linewidth=vlw)
		

		push!(C,CairoMakie.Axis(f[q+2,i],xreversed=true,backgroundcolor=HSL(0,0,maximum(I[i].total)/mT), ylabel="Total",ylabelfont=:bold))
		i==1 ? hidexdecorations!(C[i]) : hidedecorations!(C[i])
		lines!(C[i],I[i].target,getfield(I[i],:total), color=ColorSchemes.tab20[ci[i]], linewidth=glw)
		vlines!(C[i],I[i].target[argmax(I[i].total)], color=vlc, linewidth=vlw)
		

		push!(D,CairoMakie.Axis(f[q+3,i],xreversed=true,backgroundcolor=HSL(0,0,mG/minimum(I[i].gini)), ylabel="Gini",ylabelfont=:bold, xticks=([0,1],["Full","OA"]),xlabel="Regulation level"))
		i>1 ? hideydecorations!(D[i]) : nothing
		hidexdecorations!(D[i], ticklabels=false, label=i==4 ? false : true)#hidexdecorations!(D[i])
		lines!(D[i],I[i].target,getfield(I[i],:gini), color=ColorSchemes.tab20[ci[i]], linewidth=glw)
		vlines!(D[i],I[i].target[argmin(I[i].gini)], color=vlc, linewidth=vlw)
		
		sc.institution[1].value=I[i].target[argmax(I[i].resource)]
		sim!(sc)
		push!(E,CairoMakie.Axis(f[q+4,i], ylabel="Resource",ylabelfont=:bold))
				i==1 ? hidexdecorations!(E[i]) : hidedecorations!(E[i])
		incomes!(E[i],sc)

		sc.institution[1].value=I[i].target[argmax(I[i].total)]
		sim!(sc)
		push!(F,CairoMakie.Axis(f[q+5,i], ylabel="Total",ylabelfont=:bold))
		i==1 ? hidexdecorations!(F[i]) : hidedecorations!(F[i])
		incomes!(F[i],sc)

		sc.institution[1].value=I[i].target[argmin(I[i].gini)]
		sim!(sc)
		push!(G,CairoMakie.Axis(f[q+6,i], ylabel="Gini",ylabelfont=:bold))
		i==1 ? nothing : hideydecorations!(G[i])
		i==1 ? hidexdecorations!(G[i]) : hidedecorations!(G[i])
		incomes!(G[i],sc)
		
		
	end
	linkaxes!(B...)
	linkaxes!(C...)
	linkaxes!(D...)
	linkaxes!(vcat(E,F,G)...)
	f
end

# ╔═╡ b0b502bd-7dd6-441a-a078-d911bd440baf
compare_institutions(Scenarios[1])

# ╔═╡ 4201b03c-4c8c-41a3-8325-437f31387b9a
compare_institutions(Scenarios[2])

# ╔═╡ 1dc905af-0899-4ceb-b9d5-953b8c6b5d27
f=compare_institutions(Scenarios[3])

# ╔═╡ c547cdff-35e5-470c-94f0-31ce65bdb3fc
save("../figures/Institutions.png",f)

# ╔═╡ 666ef234-89f7-42ae-a8c0-cbe8e28550e5
compare_institutions(Scenarios[4])

# ╔═╡ 5920f1db-1ad1-4ed2-b877-57add06b843c
function context_diversity(S;dsize=250,w=[0.0,1.0,-0.2])
	f=Figure(size=(dsize*5,length(S)*dsize))
	ci=[1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14]
	k=1
	#Label(f[1,1:2],text="Socio-economic Diversity\n ",tellwidth=false, color=:black,fontsize=24)
	#Label(f[1,3:length(S[1].institutional_impacts)],text="Outcomes\n ",tellwidth=false, color=:black,fontsize=24)
	Label(f[1,1],text="Scenarios or Context?",tellwidth=false, color=:black)
	
	Label(f[1,5],text="Participation Plot",tellwidth=false, color=:black,fontsize=16)
	Label(f[1,3:4],text="Institutional Performance Fingerprint",tellwidth=false,color=:black,fontsize=16)
	Label(f[1,6],text="Income distributions",color=:black,tellwidth=false,fontsize=16)
	for (i,sc) in enumerate(S)
		s=deepcopy(sc)
		image_file = download(s.image)
		image = load(image_file)
		a=CairoMakie.Axis(f[i+k,1],aspect=1)
		hidespines!(a)
		hidedecorations!(a)
		image!(a,rotr90(image))

		d=CairoMakie.Axis(f[i+k,2],aspect=1)
		#lines!(s.w,s.q,linewidth=3, label="")
		l1=lines!(d,s.w, linewidth=3,color=:black,label="Alternative opportunities")
		l2=lines!(d,s.q,linewidth=3,color=:lightgray, label="Extraction potential")

		b=CairoMakie.Axis(f[i+k,5],aspect=1, xlabel="Resource level", ylabel="Participation")
		hidedecorations!(b,label=false)
		phaseplot!(b,s,show_realized=false)

		
		M=zeros(length(s.institutional_impacts),4)
		mr=maximum([maximum(i.resource) for i in s.institutional_impacts])
		mt=maximum([maximum(i.total) for i in s.institutional_impacts])
		mg=minimum([minimum(i.gini) for i in s.institutional_impacts])
		mq=maximum([maximum(i.resource.^w[1].*i.total.^w[2].*i.gini.^w[3]) for i in s.institutional_impacts])
		for (k,inst_impact) in enumerate(s.institutional_impacts)
			M[k,1]=(maximum(inst_impact.resource))/mr
			M[k,2]=(maximum(inst_impact.total))/mt
			M[k,3]=mg/(minimum(inst_impact.gini))
			q=inst_impact.resource.^w[1].*inst_impact.total.^w[2].* inst_impact.gini.^w[3]
			M[k,4]=(maximum(q))/mq
		end
		
		xt=(1:length(s.institutional_impacts), [rich(replace(i.institution.label,"\n"=>" "),color=ColorSchemes.tab20[ci[j]]) for (j,i) in enumerate(S[1].institutional_impacts)])
		yt=(1:4,reverse(["Resource revenue","Total revenue","Gini",L"R^{%$(w[1])} T^{%$(w[2])} G^{%$(w[3])}"]))
		
		c=CairoMakie.Axis(f[i+k,3:4],aspect=length(s.institutional_impacts)/3,xticks = xt, yticks=yt,xticklabelrotation=-pi/6, yaxisposition = :right, yticklabelsize=18)
		hidespines!(c)
		hidexdecorations!(c, ticklabels=(i==length(S) ? false : true))
		
		heatmap!(c,1:length(s.institutional_impacts),reverse(1:4),M,colormap=:grays,colorrange=(0,1))
		winInst=argmax(M[:,4])
		s.color=convert(HSL,ColorSchemes.tab20[ci[winInst]])
		[text!(c,x,y-0.05,text=string(round(M[x,5-y]*100,digits=0))[1:end-2],align=(:center,:baseline), font = (x==winInst && y==1 ) ? :bold : :regular, fontsize = (x==winInst && y==1 ) ? 20 : 14, color=(x==winInst && y==1 ) ? ColorSchemes.tab20[ci[x]] : abs(M[x,5-y])>0.5 ? :black : :white) for x in 1:length(s.institutional_impacts), y in 1:4]
		Legend(f[1,2],d, tellwidth=false,orientation=:vertical)

		eG=GridLayout(f[i+k,6])

		e=CairoMakie.Axis(eG[1,1], ylabel="OA")
		hidespines!(e)
		hidexdecorations!(e, ticklabels=(i==length(S) ? false : true))
		hideydecorations!(e, label=false)
		s.color=HSL(0,0,0.5)
		incomes!(e,s)
		
		ee=CairoMakie.Axis(eG[2,1], ylabel=rich("Optimal",color=ColorSchemes.tab20[ci[winInst]]))
		hidespines!(ee)
		hidexdecorations!(ee, ticklabels=(i==length(S) ? false : true))
		hideydecorations!(ee, label=false)
		
		s.institution=[s.institutional_impacts[argmax(M[:,4])].institution]
		inst_impact=s.institutional_impacts[argmax(M[:,4])]
		q=inst_impact.resource.^w[1].*inst_impact.total.^w[2].* inst_impact.gini.^w[3]
		s.institution[1].value=s.institutional_impacts[argmax(M[:,4])].target[argmax(q)]
		s.color=convert(HSL,ColorSchemes.tab20[ci[winInst]])
		sim!(s)
		incomes!(ee,s)
		phaseplot!(b,s,show_realized=true, show_potential=false,show_sustained=false)
			
		

	end
	
	#Legend(f[2,2],text="Dimensional",tellwidth=false)
	f
end

# ╔═╡ 1adea7d5-9294-4455-bee2-984ee3e60620
c=context_diversity(Scenarios[1:4],w=[0.0,1.0,-0.25])

# ╔═╡ 8f49c68a-7fa2-4c4a-a338-249db821b57d
save("../figures/Contexts.png",c)

# ╔═╡ f15519b1-6a0c-44eb-9555-531e32f617aa


# ╔═╡ 43e4865a-7ead-4302-b422-8417341f32bc
scatter(h_original)

# ╔═╡ 3a89c366-4b00-4c45-a942-e86d101f7128
scatter(h_transformed)

# ╔═╡ Cell order:
# ╟─8dc1246f-47ac-4a41-af25-bdbf4bad30c7
# ╠═1a452997-4471-4803-93e7-7b4c66fd676f
# ╠═b7319260-9458-4405-b255-03d05a0cbc2a
# ╟─ef32418a-b12f-4cb2-a0e0-1a917fbde77f
# ╠═c6a1ff96-8c69-463e-a8d5-b38629095507
# ╟─196ec14a-cb05-4d7a-80f7-14bfaf1e9b39
# ╠═9bfe0351-1104-4eb6-9442-64e14c92ef09
# ╠═30976e77-1f49-4e89-810c-6414ff0f8292
# ╠═72edff09-b442-4373-bc63-58376ede8e35
# ╠═d3068553-dd29-47d5-916d-ebf45ad931f3
# ╠═56564230-1a0c-4aef-9084-ac8f92795b67
# ╠═b0b502bd-7dd6-441a-a078-d911bd440baf
# ╠═4201b03c-4c8c-41a3-8325-437f31387b9a
# ╠═1dc905af-0899-4ceb-b9d5-953b8c6b5d27
# ╠═c547cdff-35e5-470c-94f0-31ce65bdb3fc
# ╠═666ef234-89f7-42ae-a8c0-cbe8e28550e5
# ╟─2ce64071-bcf2-431e-8ab6-e9d6a1da2cea
# ╠═1adea7d5-9294-4455-bee2-984ee3e60620
# ╠═8f49c68a-7fa2-4c4a-a338-249db821b57d
# ╠═9c5d3d93-17c6-4d15-bd91-abb31f0868cb
# ╠═5920f1db-1ad1-4ed2-b877-57add06b843c
# ╠═aafff548-39d3-11ef-39ed-d166b0a452b7
# ╠═f15519b1-6a0c-44eb-9555-531e32f617aa
# ╠═43e4865a-7ead-4302-b422-8417341f32bc
# ╠═3a89c366-4b00-4c45-a942-e86d101f7128
