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
end

# ╔═╡ 045ac957-4baa-4da6-811a-e41b26f7e44d
begin
	s=scenario();
	dist!(s);
	sim!(s);
end;

# ╔═╡ b2817ac6-a848-477c-a37c-d9f649a472bf

	phaseplot(s)

# ╔═╡ c8a9ec8c-ef98-44bb-ba1f-8d038bb624d6


# ╔═╡ e6ec80c3-569d-46b3-92f1-3978a798d4a2
md"The package provides a few graphical elements that can be placed into a figure as desired:"

# ╔═╡ eb0b4511-bc02-4858-9c71-46775205b9ab
function ShowGraphicalElements()
	f=Figure()
	a11=Axis(f[1,1], title="phaseplot!(axis,s)")
	a12=Axis(f[1,2], title="incomes!(axis,s)")
	a21=Axis(f[2,1], title="SEDplot!(axis,s,:w,:w̃)")
	a22=Axis(f[2,2], title="individual_u!(axis,s)")
	s=scenario(color=:salmon); dist!(s); sim!(s)
	phaseplot!(a11,s)
	incomes!(a12,s)
	SEDplot!(a21,s,:w,:w̃)
	individual_u!(a22,s)
	xlims!(a22,(0,10))
	return f
end

# ╔═╡ 1493a7fd-3b4f-4587-ac71-0d62d43a8d72
ShowGraphicalElements()

# ╔═╡ 0bf6c5f1-2b61-4a2e-9fed-223031c2dd09
function ShowPhaseplot()
	f=Figure(size=(600,600))
	a11=Axis(f[1,1], title="show_trajectory=true")
	a12=Axis(f[1,2], title="show_realized=true")
	a21=Axis(f[2,1], title="vector_field=true")
	a22=Axis(f[2,2], title="indicate_incentives")
	s=scenario(color=:salmon); 
	dist!(s); 
	sim!(s);
	phaseplot!(a11,s, show_trajectory=true)
	phaseplot!(a12,s, show_realized=true)
	phaseplot!(a21,s,vector_field=true)
	phaseplot!(a22,s, indicate_incentives=:w, show_realized=true)
	return f
end

# ╔═╡ 37215879-de1b-48b9-a7ec-a90cd28f4e05
ShowPhaseplot()

# ╔═╡ 0610cdd4-661d-4022-a49e-7de205f91549


# ╔═╡ Cell order:
# ╠═cde1b566-1222-11ef-3f9d-3bb37d2b2aa1
# ╠═045ac957-4baa-4da6-811a-e41b26f7e44d
# ╠═b2817ac6-a848-477c-a37c-d9f649a472bf
# ╠═c8a9ec8c-ef98-44bb-ba1f-8d038bb624d6
# ╟─e6ec80c3-569d-46b3-92f1-3978a798d4a2
# ╠═eb0b4511-bc02-4858-9c71-46775205b9ab
# ╠═1493a7fd-3b4f-4587-ac71-0d62d43a8d72
# ╠═0bf6c5f1-2b61-4a2e-9fed-223031c2dd09
# ╠═37215879-de1b-48b9-a7ec-a90cd28f4e05
# ╠═0610cdd4-661d-4022-a49e-7de205f91549
