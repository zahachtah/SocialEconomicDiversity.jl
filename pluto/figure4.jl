### A Pluto.jl notebook ###
# v0.19.43

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

# ╔═╡ f672748a-768b-4fb1-a105-e3be975164b8
floor(1.1)

# ╔═╡ d4fa0fe1-7343-4c67-b540-c81907c96f8f
function Figure4b(D,base=180; indexed=:w̃, saveas="../figures/Institutions.png")
	ci=[15,1,3,5,7,9,11,13,17,19,2,4,6,8,10,12,14]
	f=Figure(size=(base*6,base*4))
	L=["Open Access","Use rights","Tradable Quotas ","Protected Area", "Economic incentives"]
	LL=[" ","Selected actors get permits \nto use the resource","Surplus use rights are \ntraded on a market","Part of the resource area \nis no-use, resource \nmoves between areas","Tax on gear effectively reduces q \nwhich affects both ū and w̃"]

	Label(f[0,1], "Example Institutions →", fontsize = 18, font=:bold, tellwidth=false)
	hx=CairoMakie.Axis(f[2,1], aspect=1, yticks=(1:3,["Resource","Total","Gini"]), xticks=(1:4,[rich("UR",color=:crimson),"TQ","PA","EI"]), title="% change from OA")
	h=heatmap!(hx,rand(4,3), colormap=:grays)
	
	Colorbar(f[1,1],h,tellwidth=false,vertical=false)
	for (i,q) in enumerate(D)
		
		d=deepcopy(q)
		d.institution=[]
		d.color=HSL(0,0.0,0.5)
		sim!(d)
		sim!(q)
		q.color=convert(HSL,ColorSchemes.tab20[ci[i]])
		if i>1
			text!(hx,i-1,1,text=string(Int64(round(maximum(d.institutional_impacts[1].resource*100),digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			text!(hx,i-1,2,text=string(Int64(round(maximum(d.institutional_impacts[1].resource*100),digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			text!(hx,i-1,3,text=string(Int64(round(maximum(d.institutional_impacts[1].resource*100),digits=0))), align=(:center,:baseline), color=:white, font=:bold)
			Label(f[0,i],rich(L[i] ,word_wrap_width=180,color=ColorSchemes.tab20[ci[i]], fontsize = 18, font=:bold), tellwidth=false)
			Label(f[1,i],rich(LL[i],word_wrap_width=180,color=ColorSchemes.tab20[ci[i]], fontsize = 12), tellwidth=false)
			x=1.0 -d.institutional_impacts[1].id_total
			cx=CairoMakie.Axis(f[2,i], xticks=(0<x<1 ? [0,x,1] : [0,1],0<x<1 ? ["Open\nAccess","opt","Full"] : ["Open\nAccess","Full"]),height=base) 
			
			lines!(cx,[x,x],[0.0,0.6])
			lines!(cx,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].resource, color=SocialEconomicDiversity.adjustColor(q.color,"l",0.8), linewidth=2) 
			lines!(cx,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].total, color=q.color, linewidth=3)
			lines!(cx,reverse(d.institutional_impacts[1].target),d.institutional_impacts[1].gini, color=SocialEconomicDiversity.adjustColor(q.color,"l",0.3), linewidth=1)
		end
		
		Label(f[3,2:5],"Regulation", tellheight=true, tellwidth=false,height=20,halign=:center,valign=:top)
		Label(f[3,1],"Open Access", tellheight=true, tellwidth=false,height=20, fontsize = 18, font=:bold)
		Label(f[5,0],"Income\ndistribution",rotation=pi/2)
		Label(f[4,0],"Phase plot\nwith realized use (points)",rotation=pi/2)
		ax=CairoMakie.Axis(f[4,i])
		hidedecorations!(ax)
		phaseplot!(ax,d)
		bx=CairoMakie.Axis(f[5,i], height=base/2, xlabel="w̃")
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
function selected_institutions(;distribution=LogNormal,q=1.5)
	iOA=Open_access()
	iPH=Dynamic_permit_allocation(criteria=:w, reverse=true)
	iTY=Market(target=:yield)
	iPA=Protected_area()
	iESq=Economic_incentive(target=:q,subsidize=true)
		institution=[iOA,iPH,iTY,iPA,iESq]
	D=[]
	for (i,inst) in enumerate(institution)
		println(string(inst))
		if i==10 || i==12
			col=:forestgreen
		else
			col=:steelblue
		end

		s=scenario(w=sed(min=0.1,max=1.0,normalize=true;distribution),q=sed(mean=q,sigma=0.0, normalize=true), color=col)
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

# ╔═╡ 18cd66e9-58bc-4e1e-9bbb-8594ad4ac253
Figure4b(DD, indexed=true)

# ╔═╡ 3c990432-abbf-4fc8-8f18-d9c7db5b33ef
DD[2].institutional_impacts[1]

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

# ╔═╡ 64f65364-5ac5-46a9-b136-1df543d553b4
D[10].aw̃

# ╔═╡ 945211f6-e63e-44cb-a411-fc89d1057c64
D[4].institutional_impacts

# ╔═╡ f0073ed2-7fff-4e47-9f4d-751b77fddca4


# ╔═╡ Cell order:
# ╠═73efb782-4f63-4513-8907-a142f136c97a
# ╠═e397e05d-2557-433a-b404-6531f385d91c
# ╠═64f65364-5ac5-46a9-b136-1df543d553b4
# ╠═18cd66e9-58bc-4e1e-9bbb-8594ad4ac253
# ╠═3c990432-abbf-4fc8-8f18-d9c7db5b33ef
# ╠═f672748a-768b-4fb1-a105-e3be975164b8
# ╠═d4fa0fe1-7343-4c67-b540-c81907c96f8f
# ╠═d5063d51-8e41-4f22-9f6c-07a259a466e0
# ╠═0bd5711c-b54e-43d6-9fb0-72bb18f5bb95
# ╠═f5d534ef-5bf3-4f98-82c2-15f07a3f0531
# ╠═5e8d3e1c-0675-41bc-8e37-071a84972861
# ╠═945211f6-e63e-44cb-a411-fc89d1057c64
# ╠═a923a615-d697-4c27-a3e1-c524eed1e700
# ╠═7e20af05-6d5e-4b3c-8b99-79217c7a3e44
# ╠═b5d9584c-c7c5-4c59-85b0-3716c5ce4f7f
# ╠═b1e057b6-1714-4aa3-9451-9a2e06bffa0b
# ╠═8ac51240-3454-11ef-2d81-c51a2580ca5b
# ╠═f0073ed2-7fff-4e47-9f4d-751b77fddca4
