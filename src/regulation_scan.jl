@everywhere using SocialEconomicDiversity

function regscan(; u=false,s=high_impact())
    
    policies=[
    scenario(s,policy="Exclusive Use Rights", reverse=true)
    scenario(s,policy="Exclusive Use Rights", reverse=false)
    scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
    scenario(s,policy="Protected Area", m=0.3)
    #scenario(s,policy="Protected Area", m=0.05)
    scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
    ]
    Labels=Dict(
        :RR=>"Resource\nRevenues",
        :ToR=>"Total\nRevenues",
        :GI=>"Gini\n ",
        :EH=>"Ecological\nStatus",
        :RI=>"Regulation\nImpact",
        :Gov=>"Governance\ngoal"
    )
    policylabels=[
        "Use Rights\nHIGH w̃\nexcluded",
        "Use Rights\nLOW w̃\nexcluded",
        "Tradable \nUse Rights\nEFFORT",
        "Tradable \nUse Rights\nYIELD",
        "Protected Area\n\nmobility=0.3",
        "Economic incentive\n\nRoyalties"
    ]
    RS=[regulation_scan(scenario,kR=0.2, kT=1.0,kG=-0.2) for scenario in policies]
    f=Figure(size=(1000,1000))
   
    outcomes=[:RR,:ToR,:GI,:EH,:RI,:Gov]
    #Label(f[0,1:length(RS)], text="Policy outcomes", fontsize=25, font=:bold)
    A=Dict()
    LL=0 
    for (i,rs) in enumerate(RS)
        for (jj,o) in enumerate(outcomes)
            j=jj+2
            if i==1
                Label(f[j,0], text=Labels[o], tellheight=false)
            end
            
            osym=Symbol("o"*string(o))
            xv=j>3 ? 0.0 : round(rs.r[rs[osym]], digits=2)
            xtv=[0,xv,1]
            xts=["",string(xv),""]
            yv=j>3 ? 0.0 : round(rs[o][rs[osym]], digits=2)
            ytv=[0,yv,1]
            yts=["",string(yv),""]
             if xtv[1]==xtv[2]
                xtv=xtv[2:3]; xts=xts[2:3]
             elseif xtv[2]==xtv[3]
                xtv=xtv[1:2]; xts=xts[1:2]
             end
             if ytv[1]==ytv[2]
                ytv=ytv[2:3]; yts=yts[2:3]
             elseif ytv[2]==ytv[3]
                ytv=ytv[1:2]; yts=yts[1:2]
             end
             xtv=[xv]
             xts=[string(xv)]
             ytv=[yv]
             yts=[string(yv)]
            A[i,j]=Axis(f[j,i], 
            xticks =(xtv,xts),
            xticklabelsize=12,
            xtickcolor=:black,
            yticks =(ytv,yts),
            yticklabelsize=12,
            ytickcolor=:black,
            xgridcolor=:black,
            ygridcolor=:black)
            hidespines!(A[i,j])
            #j==length(outcomes) ? hidexdecorations!(A[i,j], label=false, ticklabels=false, grid=true) : hidexdecorations!(A[i,j])
            #i==1 ? hideydecorations!(A[i,j], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,j], grid=false)
            #hidespines!(A[i,j])
            lines!(A[i,j],rs.r,rs[o], color=ColorSchemes.tab20[i], linewidth=3)
            
            
            #vlines!(A[i,j], rs.r[rs[osym]],color=:black, linestyle=:dot)
            
            #text!(A[i,j],0.05,0.95,text=string(round(rs[o][rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:left,:top))
            
            #text!(A[i,j],rs.r[rs[osym]]-0.05,0.05,text=string(round(rs.r[rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:right,:bottom))

        end
        #length(outcomes)
        if !u
            A[i,LL+1]=Axis(f[LL+1,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "") 
            heatmap!(A[i,LL+1],rs.sols, colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
            hidexdecorations!( A[i,LL+1])
            i==1 ? hideydecorations!(A[i,LL+1], label=false, ticklabels=true, minorgrid=false) : hideydecorations!(A[i,LL+1], minorgrid=false, ticklabels=true)
            #hidespines!( A[i,LL+1])
            Label(f[1,0], text="Participation in\nresource use " , tellheight=false)

            A[i,LL+2]=Axis(f[LL+2,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "")
            heatmap!(A[i,LL+2],rs.incdist, colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
            hidexdecorations!( A[i,LL+2])
            i==1 ? hideydecorations!(A[i,LL+2], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,LL+2], grid=false, ticklabels=true)
            #hidespines!( A[i,LL+2])
            Label(f[2,0], text="Incomes\n of actors" , tellheight=false)
        end
        policylabels[i]
        Label(f[0,i], text=policylabels[i],color=ColorSchemes.tab20[i], tellwidth=false)
    end
    Label(f[length(outcomes)+LL+3,1:length(RS)], text="Regulation level", tellwidth=false, fontsize=25, font=:bold)
        [linkyaxes!([A[i,j+LL] for i in 1:length(RS)]...) for j in 1:length(outcomes)]

    f
end

f5=regscan()
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/figure5.png",f5)
#= questions

why positive sum of trades? (fixed)
tradable use rights using yield can take looong time to steady state => negative total trade?? VERY sensitive at regulation=0.75
why no division in useage in PA?
WTF happens in the last timestep??
Can I block the discriminant from going negative??? what does it mean?


Sensational findings:

Extremely large difference between resource revenues and societal revenues
MUST think about the cost to society!
=#
@everywhere function monte_carlo_scan(;N=1, k=[0.2,1.0,-0.3,0.2])
    RE=[]
    O=[]
    for i in 1:N
        print(string(i)*", ")
        mean_w̃=rand()
        sigma_w̃=rand()
        mean_ū=2*rand()
        sigma_ū=rand()*mean_ū
        s=scenario(base(),w̃=sed(mean=mean_w̃, sigma=sigma_w̃, distribution=LogNormal), ū=sed(mean=mean_ū, sigma=sigma_ū, normalize=true))
        policies=[
            scenario(s,policy="Assigned Use Rights", reverse=true)
            scenario(s,policy="Assigned Use Rights", reverse=false)
            scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
            scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
            scenario(s,policy="Protected Area", m=0.3)
            scenario(s,policy="Protected Area", m=0.05)
            scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
            scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
            scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:subsidy)
            scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:subsidy)
        
            ]
        
            maxG=[]
            regulation=[]
            y0=[]
            part0=[]
            y=[]
            part=[]
        for scenario in policies
            #try
            R=regulation_scan(scenario)
            G=R.RR.^k[1].+R.ToR.^k[2].+R.GI.^k[3].+R.EH.^k[4]
            push!(maxG,maximum(G))
            push!(regulation,R.r[argmax(G)])
            push!(y0,R.EH[1])
            push!(y,R.EH[argmax(G)])
            push!(part0,sum(R.sols[1,:]./scenario.ū)./scenario.N)
            push!(part,sum(R.sols[argmax(G),:]./scenario.ū)./scenario.N)
            #=catch
                push!(RE,scenario)
                println((mean_w̃,mean_ū,sigma_w̃,sigma_ū, scenario.policy) )
            end=#
        end
        i=argmax(maxG)
        push!(O,(policies[i]...,regulation=regulation[i],y0=y0[1],y=y[i], part0=part0[1], part=part[i]))
    end
    return O
end


#=
R_R_only=monte_carlo_scan(N=1000,k=[1.0,0.0,0.0,0.0])
R_T_only=monte_carlo_scan(N=1000,k=[0.0,1.0,0.0,0.0])
R_G_only=monte_carlo_scan(N=1000,k=[0.0,0.0,-1.0,0.0])
R_A_only=monte_carlo_scan(N=1000,k=[0.2,1.0,-0.4,0.0])
=#
# Launch each call on a different process asynchronously
r1 = @spawn monte_carlo_scan(N=1000, k=[1.0, 0.0, 0.0, 0.0])
r2 = @spawn monte_carlo_scan(N=1000, k=[0.0, 1.0, 0.0, 0.0])
r3 = @spawn monte_carlo_scan(N=1000, k=[0.0, 0.0, -1.0, 0.0])
r4 = @spawn monte_carlo_scan(N=1000, k=[0.2, 1.0, -0.4, 0.0])

# Retrieve the results (this blocks until the results are ready)
R_R_only = fetch(r1)
R_T_only = fetch(r2)
R_G_only = fetch(r3)
R_A_only = fetch(r4)

overuse_R=findall([r.y0<0.5 for r in R_R_only].==1)
overuse_T=findall([r.y0<0.5 for r in R_T_only].==1)
overuse_G=findall([r.y0<0.5 for r in R_G_only].==1)
overuse_A=findall([r.y0<0.5 for r in R_A_only].==1)

pol=["Assigned Use Rights", "Tradable Use Rights", "Protected Area", "Economic Incentives"]

pR=[count(i->(i==in),[r.policy for r in R_R_only[overuse_R]]) for in in pol]
pT=[count(i->(i==in),[r.policy for r in R_T_only[overuse_T]]) for in in pol]
pG=[count(i->(i==in),[r.policy for r in R_G_only[overuse_G]]) for in in pol]
pA=[count(i->(i==in),[r.policy for r in R_A_only[overuse_A]]) for in in pol]

cmap=ColorSchemes.tab20[[1,3,5,7]]

f=Figure(size=(800,800))
a=Axis(f[1,1], limits=(0,1,0,1),title="Resource Revenues, R")
b=Axis(f[1,2], limits=(0,1,0,1),title="Total Revenues, T")
c=Axis(f[2,1], limits=(0,1,0,1),title="Gini, G")
d=Axis(f[2,2], limits=(0,1,0,1),title=L"R^{0.2}+T^{1.0}+G^{-0.4}")
[hidespines!(a) for a in [a,b,c,d]]
scatter!(a,[r.y0 for r in R_R_only],[r.part0 for r in R_R_only], color=[findall(r.policy.==pol)[1] for r in R_R_only], colormap=cmap)
scatter!(b,[r.y0 for r in R_T_only],[r.part0 for r in R_T_only], color=[findall(r.policy.==pol)[1] for r in R_T_only], colormap=cmap)
scatter!(c,[r.y0 for r in R_G_only],[r.part0 for r in R_G_only], color=[findall(r.policy.==pol)[1] for r in R_G_only], colormap=cmap)
scatter!(d,[r.y0 for r in R_A_only],[r.part0 for r in R_A_only], color=[findall(r.policy.==pol)[1] for r in R_A_only], colormap=cmap)
Legend(f[0,1:2],
[ MarkerElement(color = cmap[1], marker = :circle, markersize = 15),MarkerElement(color = cmap[2], marker = :circle, markersize = 15),MarkerElement(color = cmap[3], marker = :circle, markersize = 15),MarkerElement(color = cmap[4], marker = :circle, markersize = 15)],
pol,orientation=:horizontal,framevisible=false)

f

f1=Figure(size=(800,800))
a1=Axis(f1[1,1], limits=(0,1,0,1),title="Resource Revenues, R")
b1=Axis(f1[1,2], limits=(0,1,0,1),title="Total Revenues, T")
c1=Axis(f1[2,1], limits=(0,1,0,1),title="Gini, G")
d1=Axis(f1[2,2], limits=(0,1,0,1),title=L"R^{0.2}+T^{1.0}+G^{-0.4}")
[hidespines!(a) for a in [a1,b1,c1,d1]]
scatter!(a1,[r.y for r in R_R_only],[r.part for r in R_R_only], color=[findall(r.policy.==pol)[1] for r in R_R_only], colormap=cmap)
scatter!(b1,[r.y for r in R_T_only],[r.part for r in R_T_only], color=[findall(r.policy.==pol)[1] for r in R_T_only], colormap=cmap)
scatter!(c1,[r.y for r in R_G_only],[r.part for r in R_G_only], color=[findall(r.policy.==pol)[1] for r in R_G_only], colormap=cmap)
scatter!(d1,[r.y for r in R_A_only],[r.part for r in R_A_only], color=[findall(r.policy.==pol)[1] for r in R_A_only], colormap=cmap)
Legend(f1[0,1:2],
[ MarkerElement(color = cmap[1], marker = :circle, markersize = 15),MarkerElement(color = cmap[2], marker = :circle, markersize = 15),MarkerElement(color = cmap[3], marker = :circle, markersize = 15),MarkerElement(color = cmap[4], marker = :circle, markersize = 15)],
pol,orientation=:horizontal,framevisible=false)
f1


using CairoMakie

# Simulated capital amounts (in arbitrary units)
capital = range(1e3, stop=1e7, length=200)

# Conceptual model: risk exposure as a fraction of capital.
# Assume an absolute potential loss L that is similar across investments.
# Relative risk exposure = L / capital. For demonstration, let L = 1e5.
L = 1e5
risk_exposure = L ./ capital  # As capital increases, relative exposure decreases

# Create a figure
fig = Figure(size = (800, 500))
ax = Axis(fig[1, 1],
    xlabel = "Total Capital (units)",
    ylabel = "Risk Exposure (Fraction of Capital)",
    xscale = log10,
    yscale = log10,
    title = "Effect of Capital on Relative Risk Exposure"
)

lines!(ax, capital, risk_exposure, linewidth = 3, color = :dodgerblue)

# Adding a horizontal line at a chosen risk threshold, e.g., 10%
hlines!(ax, [0.10], linestyle = :dash, color = :red, label = "10% Risk Threshold")
axislegend(ax)

fig



using CairoMakie

# Sample data for demonstration
x = 1:10

# Create a figure with 1 row and 6 columns
fig = Figure(size = (1200, 400))
# Create 6 axes; display the x-axis label only for the central facet (column 3)
ax = [Axis(fig[1, j],  xlabel = (j == 3 ? "Time (s)" : "")) for j in 1:6]

# Plot some example data in each facet
for a in ax
    lines!(a, x, rand(length(x)))
end

# Link x-axes to ensure they share the same tick positions
linkxaxes!(ax...)
fig
# Render and save the figure
save("facet_plot.png", fig)


using CairoMakie

function regscan(; u=false, s=high_impact())
    policies = [
        scenario(s, policy="Exclusive Use Rights", reverse=true),
        scenario(s, policy="Exclusive Use Rights", reverse=false),
        scenario(s, policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05),
        scenario(s, policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05),
        scenario(s, policy="Protected Area", m=0.3),
        #scenario(s,policy="Protected Area", m=0.05)
        scenario(s, policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
    ]
    Labels = Dict(
        :RR => "Resource\nRevenues",
        :ToR => "Total\nRevenues",
        :GI => "Gini\n ",
        :EH => "Ecological\nStatus",
        :RI => "Regulation\nImpact"
    )
    policylabels = [
        "Assigned \nUse Rights\nneed",
        "Assigned \nUse Rights\ngreed",
        "Tradable \nUse Rights\neffort",
        "Tradable \nUse Rights\nyield",
        "Protected Area\n\nmobility=0.3",
        "Economic incentive\n\nGear tax"
    ]
    RS = [regulation_scan(scenario) for scenario in policies]
    # Create a figure with size adjusted to accommodate rows (policies) and columns (outcomes)
    f = Figure(size = (1000, 800))
    
    outcomes = [:RR, :ToR, :GI, :EH, :RI]
    # Add an overall title for the columns (i.e., outcomes)
    #Label(f[1, 1:length(outcomes)], text="Policy outcomes", fontsize=25, font=:bold)
    
    A = Dict{Tuple{Int,Int}, Axis}()
    # Now, loop over policies (rows) and outcomes (columns)
    for (i, rs) in enumerate(RS)
        for (j, o) in enumerate(outcomes)
            osym = Symbol("o" * string(o))
            # Compute tick values (here we simply extract a representative value)
            xv = j > 3 ? 0.0 : round(rs.r[rs[osym]], digits=2)
            yv = j > 3 ? 0.0 : round(rs[o][rs[osym]], digits=2)
            # Define tick labels as needed (here we use one value for simplicity)
            xtv = [xv]; xts = [string(xv)]
            ytv = [yv]; yts = [string(yv)]
            # In the new layout, the policy label (from policylabels) goes on the left (i.e., j==1)
            # and the outcome label (from Labels) appears at the top (i==1)
            A[i, j] = Axis(f[i, j],
                ylabel = (j == 1 ? policylabels[i] : ""),
                title  = (i == 1 ? Labels[o] : ""),
                titlecolor = ColorSchemes.tab20[i],
                ylabelfont = :bold,
                xticks = (xtv, xts),
                xticklabelsize = 12,
                xtickcolor = :black,
                yticks = (ytv, yts),
                yticklabelsize = 12,
                ytickcolor = :black,
                xgridcolor = :black,
                ygridcolor = :black
            )
            hidespines!(A[i, j])
            lines!(A[i, j], rs.r, rs[o], color = ColorSchemes.tab20[i], linewidth = 3)
        end
        if !u
            # Additional heatmaps for participation and income patterns can be added as extra columns
            A[i, length(outcomes)+1] = Axis(f[i, length(outcomes)+1],
                ylabel = (i == 1 ? "Participation\nPattern" : ""),
                ylabelfont = :bold)
            heatmap!(A[i, length(outcomes)+1], rs.sols, colormap = reverse(ColorSchemes.magma))
            hidexdecorations!(A[i, length(outcomes)+1])
            hidespines!(A[i, length(outcomes)+1])
    
            A[i, length(outcomes)+2] = Axis(f[i, length(outcomes)+2],
                ylabel = (i == 1 ? "Income\nPattern" : ""),
                ylabelfont = :bold)
            heatmap!(A[i, length(outcomes)+2], rs.incdist, colormap = reverse(ColorSchemes.magma))
            hidexdecorations!(A[i, length(outcomes)+2])
            hidespines!(A[i, length(outcomes)+2])
        end
    end

    # Link x-axes for each outcome (i.e., for each column across all policies)
    for j in 1:length(outcomes)
        linkxaxes!([A[i, j] for i in 1:length(RS)]...)
    end

    f
end
