### A Pluto.jl notebook ###
# v0.19.45

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

# ╔═╡ ebfca2b0-90ba-44f5-8d73-4fc21d8ca338
s=scenario(ū=sed(mean=2.0,sigma=0.0, normalize=true),institution=Economic_incentive(target=:w,subsidize=true,value=0.6, max=0.99));

# ╔═╡ a4dfcace-2a9c-406b-a2ae-a56a9bdaba5c
s.sim

# ╔═╡ d3068553-dd29-47d5-916d-ebf45ad931f3
md"
For price manipulations an economic incentive would be dynamic and depend on E * x as this is what the price refers to. so price subsidy of p+0.1 would result in a social cost of E * x * p+0.1

For alternative income manipulation we could assume the societal cost is the increase in sum(w) unless it is externa. If it is external (development aid) then the society gains and the developed world takes the cost?

for q its more tricky I think? should we assume that the increase in value that can be extracted is proportional to the cost of increasing q?
"

# ╔═╡ b57b09da-fd00-481e-9c72-a747bd3b0ee3
q=Economic_incentive(target=:w,subsidize=true,value=0.0, max=0.99,label="one", description="two")

# ╔═╡ e9fea390-4597-4159-8362-661860f342ad
function institutional_impact!(S;M=100, inst=1)
    !isa(S,Array) ? S=[S] : nothing
    for q in S
        s=deepcopy(q)
        total::Array{Float64}=[]
        resource::Array{Float64}=[]
        gini::Array{Float64}=[]
        I::Array{Float64}=[]
        y::Array{Float64}=[]
        t=range(0.7,stop=0.8,length=M)
        told=s.institution[inst].value
        U=zeros(s.N,M)
        for i in 1:M
            s.institution[inst].value=t[i]
            sim!(s, tend=(0.0,20000))
            
            push!(total,sum(s.total_revenue))
            push!(resource,sum(s.resource_revenue))
            push!(gini,s.gini)
            push!(y,s.y)
            U[:,i]=s.resource_revenue
            s.institution[inst].value=0
            du=zeros(s.N+3)
            SocialEconomicDiversity.dudt(du,vcat(s.u,s.y,0.0,s.ϕ),s,0.0)
            push!(I,sum(max.(0.0,du[1:s.N])))
        end
        s.institution[inst].value=told
        #id_total=t[argmax(total)],id_resource=t[argmax(resource)],id_ginnig=t[argmin(gini)],
        push!(q.institutional_impacts,(target=collect(t),id_total=t[argmax(total)],id_resource=t[argmax(resource)],id_gini=t[argmin(gini)],id_y=t[argmin((y.-0.5).^2)],total=total,resource=resource,gini=gini,I=I,y=y,U=U, institution=string(typeof(S[1].institution[1]))[25:end]*" "*string((hasfield(typeof(S[1].institution[1]),:target) ? S[1].institution[1].target : ""))))
    end 
end

# ╔═╡ 533abaf9-8b4f-49e1-89ec-46417ac31cd4
institutional_impact!(s)

# ╔═╡ ee9407fa-3141-451f-8710-69e1653899ea
heatmap(s.institutional_impacts[1].U)

# ╔═╡ b054678b-a1e0-4620-8335-7fdeb559d451
s.institutional_impacts[1]

# ╔═╡ cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
s.aw̃

# ╔═╡ d975d84f-2adf-49f3-a53a-aedbee4528f4
scatter(s.institutional_impacts[1].target,s.institutional_impacts[1].resource)

# ╔═╡ 56564230-1a0c-4aef-9084-ac8f92795b67
s.institutional_impacts[1].target[68]

# ╔═╡ d487ea7b-07d0-4032-b3f5-207315fa962d
argmax(s.institutional_impacts[1].resource)

# ╔═╡ 86b4c695-a9b0-4020-a6df-5c588a9d6b72
phaseplot(s, show_trajectory=true, show_attractor=false)

# ╔═╡ fae2a81e-243d-422c-9b0e-7cbb2237cadf
lines(s.t_u[:,26])

# ╔═╡ Cell order:
# ╠═ebfca2b0-90ba-44f5-8d73-4fc21d8ca338
# ╠═a4dfcace-2a9c-406b-a2ae-a56a9bdaba5c
# ╠═d3068553-dd29-47d5-916d-ebf45ad931f3
# ╠═b57b09da-fd00-481e-9c72-a747bd3b0ee3
# ╠═e9fea390-4597-4159-8362-661860f342ad
# ╠═533abaf9-8b4f-49e1-89ec-46417ac31cd4
# ╠═ee9407fa-3141-451f-8710-69e1653899ea
# ╠═b054678b-a1e0-4620-8335-7fdeb559d451
# ╠═cf8368d1-fdf2-4f3c-8dcb-a3156af92c9d
# ╠═d975d84f-2adf-49f3-a53a-aedbee4528f4
# ╠═56564230-1a0c-4aef-9084-ac8f92795b67
# ╠═d487ea7b-07d0-4032-b3f5-207315fa962d
# ╠═86b4c695-a9b0-4020-a6df-5c588a9d6b72
# ╠═fae2a81e-243d-422c-9b0e-7cbb2237cadf
# ╠═aafff548-39d3-11ef-39ed-d166b0a452b7
