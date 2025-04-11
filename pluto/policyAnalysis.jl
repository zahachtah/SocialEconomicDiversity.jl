### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# ╔═╡ 5cda772a-1480-11f0-051b-71408a039c25
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");

end;

# ╔═╡ 70c80389-18c3-401b-afa6-e1e82066aa72
using SocialEconomicDiversity

# ╔═╡ d369d46f-7c93-46cd-926e-36c0a1e7ab13
s=scenario(high_impact())

# ╔═╡ 4441ecc9-ef09-4402-b9c5-42073a10791d
begin
	f=Figure()
end

# ╔═╡ d616345e-ada8-421e-9f62-d7811498de06
phase_plot!(s)

# ╔═╡ Cell order:
# ╠═5cda772a-1480-11f0-051b-71408a039c25
# ╠═70c80389-18c3-401b-afa6-e1e82066aa72
# ╠═d369d46f-7c93-46cd-926e-36c0a1e7ab13
# ╠═4441ecc9-ef09-4402-b9c5-42073a10791d
# ╠═d616345e-ada8-421e-9f62-d7811498de06
