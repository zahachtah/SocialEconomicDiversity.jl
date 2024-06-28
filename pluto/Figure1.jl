### A Pluto.jl notebook ###
# v0.19.43

using Markdown
using InteractiveUtils

# ╔═╡ 5a383090-345f-11ef-3e74-ddbfae006b95
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO, Distributions
	set_theme!(theme_light())
end;

# ╔═╡ 924ed622-71f4-419b-861e-bcd01711c1f4
function Figure1()
	f=Figure(size=(200,600))
	a1=CairoMakie.Axis(f[1,1], xlabel="Health",ylabel="w")
	a2=CairoMakie.Axis(f[1,2], xlabel="Health",ylabel="w")
	a=CairoMakie.Axis(f[3,1], xlabel="Health",ylabel="w")
	b=CairoMakie.Axis(f[4,1], xlabel="Health",ylabel="q")
	c=CairoMakie.Axis(f[5,1],xlabel="q",ylabel="w")
	#d=CairoMakie.Axis(f[4,1],xlabel="q",ylabel="w")
	#[hidespines!(x) for x in [a,b,c]]
	[hidedecorations!(x, label=false, grid=false) for x in [a1,a2,a,b,c]]
	A=rand(Normal(),100)
	B=rand(LogNormal(),100)
	C=A.*0.2 .+ B.*-0.3.+rand(Normal(0.0,0.1),100)
	D=2.0.+ A.*0.0 .+ B.*0.3.+rand(Normal(0.0,0.1),100)
	scatter!(a,A,C)
	scatter!(b,A,D)
	scatter!(c,C,D)
	#scatter!(d,cumsum(D))
	f
end

# ╔═╡ 39ed8d93-0ef3-4ea4-8019-683df56758e5
Figure1()

# ╔═╡ 41314d6d-e0ac-4715-b462-21ae3d989aa5
rand(Normal(),10)

# ╔═╡ Cell order:
# ╠═39ed8d93-0ef3-4ea4-8019-683df56758e5
# ╠═924ed622-71f4-419b-861e-bcd01711c1f4
# ╠═41314d6d-e0ac-4715-b462-21ae3d989aa5
# ╠═5a383090-345f-11ef-3e74-ddbfae006b95
