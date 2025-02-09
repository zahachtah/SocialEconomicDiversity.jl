function regscan(; u=false)
    s=high_impact()
    policies=[
    scenario(s,policy="Assigned Use Rights", reverse=true)
    scenario(s,policy="Assigned Use Rights", reverse=false)
    scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
    scenario(s,policy="Protected Area", m=0.3)
    scenario(s,policy="Protected Area", m=0.05)
    scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
    ]
    Labels=Dict(
        :RR=>"Resource\nRevenues",
        :ToR=>"Total\nRevenues",
        :GI=>"Gini\n ",
        :EH=>"Ecological\nStatus",
        :RI=>"Regulation\nImpact",
    )
    policylabels=[
        "Assigned \nUse Rights\nneed",
        "Assigned \nUse Rights\ngreed",
        "Tradable \nUse Rights\neffort",
        "Tradable \nUse Rights\nyield",
        "Protected Area\n\nmobility=0.3",
        "Protected Area\n\nmobility=0.1",
        "Economic incentive\n\nGear tax"
    ]
    RS=[regulation_scan(scenario) for scenario in policies]
    f=Figure(size=(1000,800))
   
    outcomes=[:RR,:ToR,:GI,:EH,:RI]
    Label(f[0,1:length(RS)], text="Policy outcomes", fontsize=25, font=:bold)
    A=Dict()
    for (i,rs) in enumerate(RS)
        for (j,o) in enumerate(outcomes)
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
            A[i,j]=Axis(f[j,i], ylabel=i==1 ? Labels[o] : "",  title=j==1 ? policylabels[i] : "" , titlecolor=ColorSchemes.tab20[i],ylabelfont=:bold,
            xticks =(xtv,xts),
            xticklabelsize=12,
            xtickcolor=:black,
            yticks =(ytv,yts),
            yticklabelsize=12,
            ytickcolor=:black,
            xgridcolor=:black,
            ygridcolor=:black)
            
            #j==length(outcomes) ? hidexdecorations!(A[i,j], label=false, ticklabels=false, grid=true) : hidexdecorations!(A[i,j])
            #i==1 ? hideydecorations!(A[i,j], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,j], grid=false)
            #hidespines!(A[i,j])
            lines!(A[i,j],rs.r,rs[o], color=ColorSchemes.tab20[i], linewidth=3)
            
            
            #vlines!(A[i,j], rs.r[rs[osym]],color=:black, linestyle=:dot)
            
            #text!(A[i,j],0.05,0.95,text=string(round(rs[o][rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:left,:top))
            
            #text!(A[i,j],rs.r[rs[osym]]-0.05,0.05,text=string(round(rs.r[rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:right,:bottom))

        end
        if !u
            A[i,length(outcomes)+1]=Axis(f[length(outcomes)+1,i], ylabel=i==1 ? "Participation\nPattern" : "",ylabelfont=:bold)
            heatmap!(A[i,length(outcomes)+1],rs.sols, colormap=reverse(ColorSchemes.magma))
            hidexdecorations!( A[i,length(outcomes)+1])
            i==1 ? hideydecorations!(A[i,length(outcomes)+1], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,length(outcomes)+1], grid=false)
            hidespines!( A[i,length(outcomes)+1])
        end
    end
  
        [linkyaxes!([A[i,j] for i in 1:length(RS)]...) for j in 1:length(outcomes)]

    f
end

f5=regscan()

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
f=Figure()

a=Axis(f[1,1], limits=(0,1,0,1),xticks=([0.0,1],["0.2",""]))
f