### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# ╔═╡ 8ac51240-3454-11ef-2d81-c51a2580ca5b
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO
	set_theme!(theme_light())
end;

# ╔═╡ a5e74431-a1e1-4782-8418-714951520882
md"
## public economics and tax cost/benefits"

# ╔═╡ 027e3be5-2804-405c-bec3-74410fea209c
md"
* heatmap gives true values in right places
* think of coherent way toimplement regulation vs _value_
* Make multiple rows for resource, total, gini and stock! heatrow for each!
* push all institutions onto one scenario.institutional_impact array
* single phaseplot with institution/OA
* single institutional_impact plot! based on array in institutional_impact of scenario
"

# ╔═╡ 6cbfc59a-cbc2-4fb5-bf1f-8c141e7a7ea5
function Figure4c(D,base=130; indexed=:w̃, saveas="../figures/Institutions.png")
	ci=[15,1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14]
	f=Figure(size=(base*(length(D)+2),base*7))
	L=["Open Access","Use rights greed","Use rights need","Tradable Quotas ","Tradable Effort ","Protected Area", "Economic incentives"]
	LL=[" ","Only selected actors get \npermits to use the resource","Only selected actors get \npermits to use the resource","Surplus use rights are \ntraded on a market","Surplus use rights are \ntraded on a market","Part of the resource area \nis no-use, resource \nmoves between areas","Tax on gear effectively reduces q \nwhich affects both ū and w̃"]

	Label(f[0,1], "Example Institutions →", fontsize = 18, font=:bold, tellwidth=false)
	Label(f[1,1], "Open Access", fontsize = 18, font=:bold, tellwidth=false)

	## Heatmap
	hx=CairoMakie.Axis(f[7:8,1], aspect=1, yticks=(1:3,["Private","Society","Equity"]), xticks=(1:5,[rich(L[2],color=D[2].color),rich(L[3],color=D[3].color),rich(L[4],color=D[4].color),rich(L[5],color=D[5].color),rich(L[6],color=D[6].color)]), title="% change from OA",xticklabelrotation=pi/5)

	H=zeros(length(D)-1,3)
	for i in 2:length(L)
		H[i-1,1]=(maximum(D[i].institutional_impacts[1].resource)/D[i].institutional_impacts[1].resource[end].-1).*100
		H[i-1,2]=(maximum(D[i].institutional_impacts[1].total)/D[i].institutional_impacts[1].total[end].-1).*100
		H[i-1,3]=abs(minimum(D[i].institutional_impacts[1].gini)/D[i].institutional_impacts[1].gini[end].-1).*100
	end
	println(H)
	h=heatmap!(hx,H, colormap=Makie.Reverse(:grays))
	
	Colorbar(f[5,0],h,tellwidth=false,vertical=true)
	for (i,q) in enumerate(D)
		
		d=deepcopy(q)
		d.institution[1].value=0.0
		d.color=HSL(0,0.0,0.5)
		sim!(d)
		sim!(q)
		q.color=convert(HSL,ColorSchemes.tab20[ci[i]])
		if i>1
			text!(hx,i-1,1,text=string(Int64(round(H[i-1,1],digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			text!(hx,i-1,2,text=string(Int64(round(H[i-1,2],digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			text!(hx,i-1,3,text=string(Int64(round(H[i-1,3],digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			Label(f[0,i],rich(L[i] ,word_wrap_width=180,color=ColorSchemes.tab20[ci[i]], fontsize = 18, font=:bold), tellwidth=false)
			
			Label(f[1,i],rich(LL[i],word_wrap_width=180,color=ColorSchemes.tab20[ci[i]], fontsize = 12), tellwidth=false)
			x=1.0 -d.institutional_impacts[1].id_total
			
			cx=CairoMakie.Axis(f[5,i],height=base/2) 
			hidedecorations!(cx)
			#ylims!(cx,(0.0,0.8))
			#lines!(cx,[x,x],[0.0,0.6], color=:black)
			lines!(cx,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].resource, color=SocialEconomicDiversity.adjustColor(q.color,"l",0.8), linewidth=2) 
			dx=CairoMakie.Axis(f[6,i], height=base/2) 
			hidedecorations!(dx)
			lines!(dx,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].total, color=q.color, linewidth=3)
			ex=CairoMakie.Axis(f[7,i], height=base/2) 
			hidedecorations!(ex)
			lines!(ex,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].gini, color=SocialEconomicDiversity.adjustColor(q.color,"l",0.3), linewidth=1)
			fx=CairoMakie.Axis(f[8,i], xticks=(0<x<1 ? [0,x,1] : [0,1],0<x<1 ? ["Open\nAccess","opt","Full"] : ["Open\nAccess","Full"]),height=base/2) 
			hideydecorations!(fx,label=false)
			lines!(fx,reverse(d.institutional_impacts[1].target),abs.(0.5.-d.institutional_impacts[1].y), color=:black, linewidth=1)
		end
		
		#Label(f[3,2:5],"Regulation", tellheight=true, tellwidth=false,height=20,halign=:center,valign=:top)
		#Label(f[3,1],"Open Access", tellheight=true, tellwidth=false,height=20, fontsize = 18, font=:bold)
		Label(f[4,0],"Resulting \nIncome\ndistribution",rotation=pi/2, halign=:right)
		Label(f[3,0],"Phase plot\nwith realized use (points)",rotation=pi/2, halign=:right)
		ax=CairoMakie.Axis(f[3,i])
		hidedecorations!(ax)
		phaseplot!(ax,d)
		if i==5
			println(d.y)
		end
		bx=CairoMakie.Axis(f[4,i], height=base/2, xlabel="w̃")
		ylims!(bx,-0.003,0.018)
		hidedecorations!(bx, label=i==3 ? false : true)
		incomes!(bx,q,show_text=false;indexed)#:w̃
		
		
		phaseplot!(ax,q, show_potential=i>8 ? true : false, show_sustained=i>8 ? true : false,show_realized=true,show_exploitation=false, show_target=true)

#=
		lines!(resource_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].resource, color=ColorSchemes.tab20[ci[i]])
		lines!(total_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].total, color=ColorSchemes.tab20[ci[i]])
		lines!(gini,d.institutional_impacts[1].target,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
		lines!(comb,d.institutional_impacts[1].total,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
=#
	end
	saveas!="" ? save(saveas,f) : nothing
	f
end

# ╔═╡ d5063d51-8e41-4f22-9f6c-07a259a466e0
ColorSchemes.tab20

# ╔═╡ 0bd5711c-b54e-43d6-9fb0-72bb18f5bb95
function Figure4(D;base=250)
	ci=[1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14]
	# run scenario sims outside!
	# just add a placement/title array for where the scenarios should be placed
	f=Figure(size=(base*4,base*3))
	PH=CairoMakie.Axis(f[1,1], title="Permits for low incentives",ylabel="Participation",titlecolor=ColorSchemes.tab20[ci[1]])
	PL=CairoMakie.Axis(f[1,2], title="Permits for high incentives",titlecolor=ColorSchemes.tab20[ci[2]])
	SE=CairoMakie.Axis(f[2,1], title="Equal share effort", ylabel="Participation",titlecolor=ColorSchemes.tab20[ci[3]])
	SY=CairoMakie.Axis(f[2,2], title="Equal share yield",titlecolor=ColorSchemes.tab20[ci[4]])
	TE=CairoMakie.Axis(f[3,1], title="Tradable effort", ylabel="Participation", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[5]])
	TY=CairoMakie.Axis(f[3,2], title="Tradable yield", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[6]])
	PA=CairoMakie.Axis(f[1,3], title="Protected Area *",titlecolor=ColorSchemes.tab20[ci[7]])
	PAD=CairoMakie.Axis(f[1,4], title="Protected Area no incentives",titlecolor=ColorSchemes.tab20[ci[8]])
	ETp=CairoMakie.Axis(f[2,3], title="Royalties p",titlecolor=ColorSchemes.tab20[ci[9]])
	ESp=CairoMakie.Axis(f[2,4], title="Subsidies p",titlecolor=ColorSchemes.tab20[ci[10]])
	ETq=CairoMakie.Axis(f[3,3], title="Tax on gear", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[11]])
	ESq=CairoMakie.Axis(f[3,4], title="Subsidized gear", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[12]])
	#=
	resource_revenues=CairoMakie.Axis(f[4,1],ylabel="resource revenues", xlabel="regulation",xticks=(0:1,["no","max"]))
	total_revenues=CairoMakie.Axis(f[4,2],ylabel="total revenues", xlabel="regulation",xticks=(0:1,["no","max"]))
	ylims!(total_revenues,(0.0,1.7))
	gini=CairoMakie.Axis(f[4,3],ylabel="gini", xlabel="regulation",xticks=(0:1,["no","max"]))
	ylims!(gini,(0.0,0.6))
	comb=CairoMakie.Axis(f[4,4],ylabel="gini", xlabel="total")
	xlims!(comb,(0.6,1.3))
	ylims!(comb,(0.1,0.4))
	=#
	axes=[PH,PL,SE,SY,TE,TY,PA,PAD,ETp,ESp,ETq,ESq]
	[hidespines!(ax) for ax in axes]
	[hidedecorations!(ax, label=true) for ax in axes]

	for (i,q) in enumerate(D)
		d=deepcopy(q)
		d.institution=[]
		d.color=HSL(0,0.0,0.5)
		sim!(d)
		sim!(q)
		phaseplot!(axes[i],d)

		q.color=convert(HSL,ColorSchemes.tab20[ci[i]])
		
		phaseplot!(axes[i],q, show_potential=i>8 ? true : false, show_sustained=i>8 ? true : false,show_realized=true,show_exploitation=false, show_target=false)
	#=
		lines!(resource_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].resource, color=ColorSchemes.tab20[ci[i]])
		lines!(total_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].total, color=ColorSchemes.tab20[ci[i]])
		lines!(gini,d.institutional_impacts[1].target,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
		lines!(comb,d.institutional_impacts[1].total,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
	=#
	end
	
	f
end

# ╔═╡ f5d534ef-5bf3-4f98-82c2-15f07a3f0531
function Figure4a(D;base=250)
	ci=[1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14]
	# run scenario sims outside!
	# just add a placement/title array for where the scenarios should be placed
	f=Figure(size=(base*4,base*4))
	PH=CairoMakie.Axis(f[1,1], title="Permits for low incentives",ylabel="Participation",titlecolor=ColorSchemes.tab20[ci[1]])
	PL=CairoMakie.Axis(f[1,2], title="Permits for high incentives",titlecolor=ColorSchemes.tab20[ci[2]])
	SE=CairoMakie.Axis(f[3,1], title="Equal share effort", ylabel="Participation",titlecolor=ColorSchemes.tab20[ci[3]])
	SY=CairoMakie.Axis(f[3,2], title="Equal share yield",titlecolor=ColorSchemes.tab20[ci[4]])
	TE=CairoMakie.Axis(f[5,1], title="Tradable effort", ylabel="Participation", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[5]])
	TY=CairoMakie.Axis(f[5,2], title="Tradable yield", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[6]])
	PA=CairoMakie.Axis(f[1,3], title="Protected Area *",titlecolor=ColorSchemes.tab20[ci[7]])
	PAD=CairoMakie.Axis(f[1,4], title="Protected Area no incentives",titlecolor=ColorSchemes.tab20[ci[8]])
	ETp=CairoMakie.Axis(f[3,3], title="Royalties p",titlecolor=ColorSchemes.tab20[ci[9]])
	ESp=CairoMakie.Axis(f[3,4], title="Subsidies p",titlecolor=ColorSchemes.tab20[ci[10]])
	ETq=CairoMakie.Axis(f[5,3], title="Tax on gear", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[11]])
	ESq=CairoMakie.Axis(f[5,4], title="Subsidized gear", xlabel="Resource Level",titlecolor=ColorSchemes.tab20[ci[12]])
	#=
	resource_revenues=CairoMakie.Axis(f[4,1],ylabel="resource revenues", xlabel="regulation",xticks=(0:1,["no","max"]))
	total_revenues=CairoMakie.Axis(f[4,2],ylabel="total revenues", xlabel="regulation",xticks=(0:1,["no","max"]))
	ylims!(total_revenues,(0.0,1.7))
	gini=CairoMakie.Axis(f[4,3],ylabel="gini", xlabel="regulation",xticks=(0:1,["no","max"]))
	ylims!(gini,(0.0,0.6))
	comb=CairoMakie.Axis(f[4,4],ylabel="gini", xlabel="total")
	xlims!(comb,(0.6,1.3))
	ylims!(comb,(0.1,0.4))
	=#
	axes=[PH,PL,SE,SY,TE,TY,PA,PAD,ETp,ESp,ETq,ESq]
	x=[1,2,1,2,1,2,3,4,3,4,3,4]
	y=[2,2,4,4,6,6,2,2,4,4,6,6,]
	[hidespines!(ax) for ax in axes]
	[hidedecorations!(ax, label=true) for ax in axes]

	for (i,q) in enumerate(D)
		d=deepcopy(q)
		d.institution=[]
		d.color=HSL(0,0.0,0.5)
		sim!(d)
		sim!(q)
		phaseplot!(axes[i],d)
		ax=CairoMakie.Axis(f[y[i],x[i]], height=70)
		hidedecorations!(ax)
		incomes!(ax,q,indexed=:w̃)
		q.color=convert(HSL,ColorSchemes.tab20[ci[i]])
		
		phaseplot!(axes[i],q, show_potential=i>8 ? true : false, show_sustained=i>8 ? true : false,show_realized=true,show_exploitation=false, show_target=false)
	#=
		lines!(resource_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].resource, color=ColorSchemes.tab20[ci[i]])
		lines!(total_revenues,d.institutional_impacts[1].target,d.institutional_impacts[1].total, color=ColorSchemes.tab20[ci[i]])
		lines!(gini,d.institutional_impacts[1].target,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
		lines!(comb,d.institutional_impacts[1].total,d.institutional_impacts[1].gini, color=ColorSchemes.tab20[ci[i]])
	=#
	end
	
	f
end

# ╔═╡ 5e8d3e1c-0675-41bc-8e37-071a84972861
1 in [1,2]

# ╔═╡ b5d9584c-c7c5-4c59-85b0-3716c5ce4f7f
function selected_institutions(;distribution=LogNormal,q=1.5,S=scenario(w=sed(min=0.1,max=1.0,normalize=true;distribution),q=sed(mean=q,sigma=0.0, normalize=true), color=:crimson))
	iOA=Open_access()
	iPH=Dynamic_permit_allocation(criteria=:w, reverse=true)
	iPL=Dynamic_permit_allocation(criteria=:w, reverse=false)
	iTY=Market(target=:yield)
	iTE=Market(target=:effort)
	iPA=Protected_area(dispersal=0.4)
	iESq=Economic_incentive(target=:q,subsidize=S.y>0.5 ? true : false, max=0.99, cost=x->x*0.05)
		institution=[iOA,iPH,iPL,iTY,iTE,iPA,iESq]
	D=[]
	for (i,inst) in enumerate(institution)
		println(string(inst))
		if i==10 || i==12
			col=:forestgreen
		else
			col=:steelblue
		end

		s=S
		d=deepcopy(s)
		d.institution=[inst]
		# color
		institutional_impact!(d)
		d.institution[1].value=d.institutional_impacts[1].id_resource

		sim!(d)
		push!(D,d)
	end
	return D
end

# ╔═╡ 7e20af05-6d5e-4b3c-8b99-79217c7a3e44
DD=selected_institutions(q=2.0)

# ╔═╡ 64f65364-5ac5-46a9-b136-1df543d553b4
begin
	f=Figure()
	a=CairoMakie.Axis(f[1,1])
	DD[5].institution[1].value=DD[5].institutional_impacts[1].id_resource
end

# ╔═╡ 3044b724-297c-444c-9a6c-d8b4b18a86d9
DD[5].institutional_impacts[1]

# ╔═╡ b9a43e20-831e-4b59-81d0-59d348f527bb
Figure4c(DD, indexed=true)

# ╔═╡ d34f1871-8a22-47e1-9ae7-aeaeda5e4a77
DD[4].institutional_impacts

# ╔═╡ eaaa1136-9ac4-41fb-9801-b35179f7f43d
length(DD)

# ╔═╡ a3eee5a2-79d7-4c33-977f-e30e81ac37d0
heatmap([maximum(DD[i].institutional_impacts[1].resource./DD[2].institutional_impacts[1].resource[end].-1.0) for i in 2:6, j in 1:1])

# ╔═╡ 7501971a-0d13-487f-bbd9-a72c63bd6418
[maximum(DD[i].institutional_impacts[1].resource./DD[2].institutional_impacts[1].resource[end].-1.0) for i in 2:6]

# ╔═╡ cddff3dc-303d-4777-92ff-94b6b9e9bd14
heatmap([maximum(DD[i].institutional_impacts[1].total./DD[2].institutional_impacts[1].total[end].-1.0) for i in 2:6, j in 1:1])

# ╔═╡ aadd362d-43b4-49a2-8b70-0352cd60e9a9
heatmap([abs(minimum(DD[i].institutional_impacts[1].gini./DD[2].institutional_impacts[1].gini[end].-1.0)) for i in 2:6, j in 1:1])

# ╔═╡ 3bf3cdcc-a354-42a5-b299-df9d3ac408cb
begin
		H=zeros(length(DD)-1,3)
	for i in 2:length(DD)
		H[i-1,1]=(maximum(DD[i].institutional_impacts[1].resource)/DD[i].institutional_impacts[1].resource[end].-1).*100
		H[i-1,2]=(maximum(DD[i].institutional_impacts[1].total)/DD[i].institutional_impacts[1].total[end].-1).*100
		H[i-1,3]=abs(minimum(DD[i].institutional_impacts[1].gini)/DD[i].institutional_impacts[1].gini[end].-1).*100
	end
	heatmap(H, colormap=Makie.Reverse(:grays))
end

# ╔═╡ 0e8078c5-27d9-4ee4-adb3-c25c944b503d
H

# ╔═╡ 3152fc29-ffc7-41ca-8ee8-308b51d7e5f1
DD[6].institutional_impacts[1]

# ╔═╡ 876a1422-936b-42de-a4ad-d167a5152cac
scatter(DD[6].institutional_impacts[1].gini)

# ╔═╡ 60770a2a-4f46-46c6-bfa5-a8b55997a554
scatter(DD[4].institutional_impacts[1].gini./DD[4].institutional_impacts[1].gini[end])

# ╔═╡ b1e057b6-1714-4aa3-9451-9a2e06bffa0b
function institutional_examples(;distribution=LogNormal,q=1.5)

	
	iPH=Dynamic_permit_allocation(criteria=:w, reverse=true)
	iPL=Dynamic_permit_allocation(criteria=:w, reverse=false)
	iSE=Equal_share_allocation(target=:effort)
	iSY=Equal_share_allocation(target=:yield)
	iTE=Market(target=:effort)
	iTY=Market(target=:yield)
	iPA=Protected_area()
	iPAD=Protected_area()
	iETp=Economic_incentive(target=:p, max=0.5)
	iESp=Economic_incentive(target=:p,subsidize=true)
	iETq=Economic_incentive(target=:q, max=0.5)
	iESq=Economic_incentive(target=:q,subsidize=true)
	institution=[iPH,iPL,iSE,iSY,iTE,iTY,iPA,iPAD,iETp,iESp,iETq,iESq]
	D=[]
	for (i,inst) in enumerate(institution)
		println(string(inst))
		if i==10 || i==12
			col=:forestgreen
		else
			col=:steelblue
		end
		if i == 8
			s=scenario(w=sed(min=0.01,max=0.5,normalize=true;distribution),q=sed(mean=q,sigma=0.0, normalize=true), color=col)
		elseif i==10 || i==12
			s=scenario(w=sed(min=0.8,max=2.0,normalize=true;distribution),q=sed(mean=q,sigma=0.0, normalize=true), color=col)
		else
			s=scenario(w=sed(min=0.1,max=1.5,normalize=true;distribution),q=sed(mean=q,sigma=0.0, normalize=true), color=col)
		end
		d=deepcopy(s)
		d.institution=[inst]
		# color
		institutional_impact!(d)
		d.institution[1].value=d.institutional_impacts[1].id_resource

		sim!(d)
		push!(D,d)
	end
	return D
end

# ╔═╡ a923a615-d697-4c27-a3e1-c524eed1e700
D=institutional_examples()

# ╔═╡ 73efb782-4f63-4513-8907-a142f136c97a
Figure4a(D)

# ╔═╡ e397e05d-2557-433a-b404-6531f385d91c
Figure4(D)

# ╔═╡ 945211f6-e63e-44cb-a411-fc89d1057c64
D[4].institutional_impacts

# ╔═╡ 85968d8e-e31f-4556-b416-27f8ce45f7ab
begin
	q=scenario()
	#q.institution=[Equal_share_allocation(target=:effort)]
	institutional_impact!(q,Equal_share_allocation(target=:effort))
	#q.institution=[Equal_share_allocation(target=:yield)]
	institutional_impact!(q,Equal_share_allocation(target=:yield))
end

# ╔═╡ 05471f9c-a132-4f0a-8fa8-67d570f1493a
q.institutional_impacts

# ╔═╡ c3f6d2be-8a8d-4536-8aa9-8672a1f2d4f7
d=Equal_share_allocation(target=:effort)

# ╔═╡ 9bf61753-5287-402a-99d7-3d92001770ed
d.value=1.0

# ╔═╡ 78d711a0-9e84-4f22-b3c4-88d1424aeeb4
Market(target=:effort)

# ╔═╡ 1f5dab9a-63f4-4638-bf83-d897c57cf941
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

# ╔═╡ 769db856-aea3-4489-8659-b7e390e42489
S=Scenarios()

# ╔═╡ f0073ed2-7fff-4e47-9f4d-751b77fddca4


# ╔═╡ Cell order:
# ╠═73efb782-4f63-4513-8907-a142f136c97a
# ╠═e397e05d-2557-433a-b404-6531f385d91c
# ╠═64f65364-5ac5-46a9-b136-1df543d553b4
# ╠═3044b724-297c-444c-9a6c-d8b4b18a86d9
# ╠═a5e74431-a1e1-4782-8418-714951520882
# ╠═027e3be5-2804-405c-bec3-74410fea209c
# ╠═b9a43e20-831e-4b59-81d0-59d348f527bb
# ╠═d34f1871-8a22-47e1-9ae7-aeaeda5e4a77
# ╠═eaaa1136-9ac4-41fb-9801-b35179f7f43d
# ╠═6cbfc59a-cbc2-4fb5-bf1f-8c141e7a7ea5
# ╠═d5063d51-8e41-4f22-9f6c-07a259a466e0
# ╠═0bd5711c-b54e-43d6-9fb0-72bb18f5bb95
# ╠═f5d534ef-5bf3-4f98-82c2-15f07a3f0531
# ╠═5e8d3e1c-0675-41bc-8e37-071a84972861
# ╠═945211f6-e63e-44cb-a411-fc89d1057c64
# ╠═a923a615-d697-4c27-a3e1-c524eed1e700
# ╠═7e20af05-6d5e-4b3c-8b99-79217c7a3e44
# ╠═a3eee5a2-79d7-4c33-977f-e30e81ac37d0
# ╠═7501971a-0d13-487f-bbd9-a72c63bd6418
# ╠═cddff3dc-303d-4777-92ff-94b6b9e9bd14
# ╠═aadd362d-43b4-49a2-8b70-0352cd60e9a9
# ╠═3bf3cdcc-a354-42a5-b299-df9d3ac408cb
# ╠═3152fc29-ffc7-41ca-8ee8-308b51d7e5f1
# ╠═0e8078c5-27d9-4ee4-adb3-c25c944b503d
# ╠═876a1422-936b-42de-a4ad-d167a5152cac
# ╠═60770a2a-4f46-46c6-bfa5-a8b55997a554
# ╠═b5d9584c-c7c5-4c59-85b0-3716c5ce4f7f
# ╠═b1e057b6-1714-4aa3-9451-9a2e06bffa0b
# ╠═85968d8e-e31f-4556-b416-27f8ce45f7ab
# ╠═05471f9c-a132-4f0a-8fa8-67d570f1493a
# ╠═c3f6d2be-8a8d-4536-8aa9-8672a1f2d4f7
# ╠═9bf61753-5287-402a-99d7-3d92001770ed
# ╠═78d711a0-9e84-4f22-b3c4-88d1424aeeb4
# ╠═769db856-aea3-4489-8659-b7e390e42489
# ╠═1f5dab9a-63f4-4638-bf83-d897c57cf941
# ╠═8ac51240-3454-11ef-2d81-c51a2580ca5b
# ╠═f0073ed2-7fff-4e47-9f4d-751b77fddca4
