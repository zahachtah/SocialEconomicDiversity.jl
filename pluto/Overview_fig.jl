### A Pluto.jl notebook ###
# v0.19.45

using Markdown
using InteractiveUtils

# ╔═╡ 5bd4ce7c-6443-11ef-0dbe-0f796c635152
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO, Distributions
	set_theme!(theme_light())
end;

# ╔═╡ d69786f8-fd35-4305-aed0-7cd2308b473f
begin
	f=Figure(size=(240,4*130))
	#Label(f[0,1],"Distributions:", tellheight=true, tellwidth=false)
	health=-rand(LogNormal(0.2,1.0),1000)
	h=CairoMakie.Axis(f[1,1], title="Health")
	hist!(h,health,bins=50, color=:crimson)
	hidedecorations!(h)
	status=rand(LogNormal(1.2,0.5),1000)
	s=CairoMakie.Axis(f[2,1], title="Socio-economic status")
	hidedecorations!(s)
	hist!(s,status,bins=50, color=:darkorange)
	knowledge=rand(LogNormal(2.2,0.1),1000)
	k=CairoMakie.Axis(f[3,1], title="Education",xticks=([minimum(knowledge),maximum(knowledge)],["low","high"]))
	hideydecorations!(k)
	#hidexdecorations!(k, ticks=false)
	hist!(k,knowledge,bins=50, color=:darkorange)
	#Label(f[4,1],"Correlations:", tellheight=true, tellwidth=false)
	sc=CairoMakie.Axis(f[4,1], height=200,aspect=1, xlabel="Socio-economic status", ylabel=rich(rich("Education",color=:darkorange),"/",rich("health",color=:crimson)))
	hidedecorations!(sc, label=false)
	scatter!(sc,status,status.+1.9.*knowledge, color=:darkorange, markersize=3, label="education")
	scatter!(sc,status,status.+1.9.*-health, color=:crimson, markersize=3,label="health")
	#axislegend(sc)
	f
end

# ╔═╡ 470b4845-073a-4cd5-8dc1-8ca8bd657b87
save("../figures/distributions_correlations.png",f)

# ╔═╡ a0ae2b9f-2928-4ea8-a9cf-184c699f005b
S=scenario(q=sed(mean=1.0,sigma=0.5, normalize=true, random=true,distribution=LogNormal),w=sed(min=0.1,max=0.7, random=true,distribution=LogNormal,normalize=true),N=1000)

# ╔═╡ 53b7917e-e1d9-4357-8354-e4a75c91706f
phaseplot(S)

# ╔═╡ 96ae536b-13fb-4552-84c7-f10eceb7c321
begin
	g=Figure(size=(300,600))
	a=CairoMakie.Axis(g[1,1], ylabel="Participation", xlabelcolor=:crimson, ylabelcolor=:crimson,ylabelfont=:bold)
	b=CairoMakie.Axis(g[2,1], ylabel="Participation",xlabel="Resource level", xlabelcolor=:forestgreen, ylabelcolor=:crimson,ylabelfont=:bold,xlabelfont=:bold)
	hist!(b,S.w̃,normalization=:probability, bins=20,color=:gray)
	phaseplot!(a,S, show_potential=false, show_attractor=false, show_exploitation=false)
	phaseplot!(b,S, show_sustained=false, show_attractor=false, show_exploitation=false)
	
	
	g
end

# ╔═╡ c9b1a750-2d0a-4f9b-8a00-6b13ab9ad4a4
save("../figures/incentives_impact.png",g)

# ╔═╡ 90ee4fb3-2b35-4c84-a264-9b4d4868b4fe
hist(S.w̃,bins=20)

# ╔═╡ Cell order:
# ╠═d69786f8-fd35-4305-aed0-7cd2308b473f
# ╠═470b4845-073a-4cd5-8dc1-8ca8bd657b87
# ╠═a0ae2b9f-2928-4ea8-a9cf-184c699f005b
# ╠═53b7917e-e1d9-4357-8354-e4a75c91706f
# ╠═96ae536b-13fb-4552-84c7-f10eceb7c321
# ╠═c9b1a750-2d0a-4f9b-8a00-6b13ab9ad4a4
# ╠═90ee4fb3-2b35-4c84-a264-9b4d4868b4fe
# ╠═5bd4ce7c-6443-11ef-0dbe-0f796c635152
