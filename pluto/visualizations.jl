### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ cde1b566-1222-11ef-3f9d-3bb37d2b2aa1
begin
	using Pkg
	Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie
	set_theme!(theme_light())
end;

# ╔═╡ e6ec80c3-569d-46b3-92f1-3978a798d4a2
md"The package provides a few graphical elements that can be placed into a figure as desired:"

# ╔═╡ eb0b4511-bc02-4858-9c71-46775205b9ab
function ShowGraphicalElements()
	f=Figure(size=(650,600))
	a11=Axis(f[1,1], title="phaseplot!", xlabel="Resource & Incentives (w̃)", ylabel="Participation")
	a12=Axis(f[1,2], title="incomes!", xlabel="Actor", ylabel="\$")
	a21=Axis(f[2,1], title="SEDplot!")
	a22=Axis(f[2,2], title="individual_u!", xlabel="Time", ylabel="w̃")
	s=scenario(color=:steelblue, q=SED(min=1.0,max=3.0,normalize=true),institution=[Dynamic_permit_allocation(:w̃,true,:inorder,0.3,:value,dynamic_permits)]); dist!(s); sim!(s)
	phaseplot!(a11,s)
	incomes!(a12,s, indexed=false)
	SEDplot!(a21,s,:w,:w̃)
	individual_u!(a22,s)
	xlims!(a22,(0,20))
	Colorbar(f[2,3],colormap=cgrad([:white,s.color]), label="u")
	return f
end

# ╔═╡ 1493a7fd-3b4f-4587-ac71-0d62d43a8d72
ShowGraphicalElements()

# ╔═╡ 0bf6c5f1-2b61-4a2e-9fed-223031c2dd09
function ShowPhaseplot()

	# initiate figure
	f=Figure(size=(900,600))

	# Make figure layout
	a11=Axis(f[1,1], title="show_trajectory=true")
	a12=Axis(f[1,2], title="show_realized=true")
	a21=Axis(f[2,1], title="vector_field=true")
	a22=Axis(f[2,2], title="indicate_incentives=:w")
	a13=Axis(f[1,3], title="show_exploitation=false")
	a23=Axis(f[2,3], title="overlay scenarios")

	# Initiate the scenarios
	s1=scenario(color=:salmon); dist!(s1);sim!(s1);
	s2=scenario(color=:steelblue, q=SED(min=1.0,max=3.0,normalize=true)); dist!(s2);sim!(s2);
	 
	# Add plots to figure
	phaseplot!(a11,s1, show_trajectory=true)
	phaseplot!(a12,s1, show_realized=true)
	phaseplot!(a21,s1,vector_field=true)
	phaseplot!(a22,s1, indicate_incentives=:w, show_realized=true)
	phaseplot!(a13,s1, show_exploitation=false)
	phaseplot!(a23,s1)
	phaseplot!(a23,s2)
	
	# return figure
	return f
end

# ╔═╡ 37215879-de1b-48b9-a7ec-a90cd28f4e05
ShowPhaseplot()

# ╔═╡ 0610cdd4-661d-4022-a49e-7de205f91549
inst=[Dynamic_permit_allocation(:w̃,true,:inorder,0.4,:value,dyn_permits)]

# ╔═╡ Cell order:
# ╟─e6ec80c3-569d-46b3-92f1-3978a798d4a2
# ╠═eb0b4511-bc02-4858-9c71-46775205b9ab
# ╠═1493a7fd-3b4f-4587-ac71-0d62d43a8d72
# ╠═0bf6c5f1-2b61-4a2e-9fed-223031c2dd09
# ╠═37215879-de1b-48b9-a7ec-a90cd28f4e05
# ╠═0610cdd4-661d-4022-a49e-7de205f91549
# ╠═cde1b566-1222-11ef-3f9d-3bb37d2b2aa1
