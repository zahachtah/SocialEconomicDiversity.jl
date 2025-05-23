@everywhere using SocialEconomicDiversity

function regscan(; u=false,inc=false,s=high_impact())
    
    policies=[
    scenario(s,policy="Exclusive Use Rights", reverse=true)
    scenario(s,policy="Exclusive Use Rights", reverse=false)
    scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
    scenario(s,policy="Protected Area", m=0.3)
    scenario(s,policy="Protected Area", m=0.5)
    #scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
    ]
    Labels=Dict(
        :RR=>"Resource\nRevenues\nR",
        :ToR=>"Total\nRevenues\nT",
        :GI=>"Gini\nG ",
        :EH=>"Ecological\nStatus\nE",
        :RI=>"Impact\non\nbehaviour\nsum(|u^UO_i-u_i|)",
        :Gov=>"Combined\nGovernance\ngoal\nR^0.5*T^1*G^-0.2*E^0",
        :WR=>"Alternative\nincomes"
    )
    policylabels=[
        "Use Rights\nHIGH w̃\nexcluded",
        "Use Rights\nLOW w̃\nexcluded",
        "Tradable \nUse Rights\nEFFORT",
        "Tradable \nUse Rights\nYIELD",
        "Protected Area\n\nmobility=0.3",
        "Protected Area\n\nmobility=0.5",
        "Economic incentive\n\nRoyalties"
    ]
    policyxlabels=[
        "fraction excluded",
        "fraction excluded",
        "1 - effort quota",
        "1 - yield quota",
        "fraction protected",
        "fraction protected",
        "econ policy"
    ]
    RS=[regulation_scan(scenario,kR=0.5, kT=1.0,kG=-0.2,kE=0.0) for scenario in policies]
    f=Figure(size=(1000,1000))
   
    outcomes=[:RR,:ToR,:GI,:EH,:RI,:Gov]
    #Label(f[0,1:length(RS)], text="Policy outcomes", fontsize=25, font=:bold)
    A=Dict()
    B=Dict()
    C=Dict()
    LL=0 
    for (i,rs) in enumerate(RS)
        for (jj,o) in enumerate(outcomes)
            j=jj+1
            if i==1
                Label(f[j,0], text=Labels[o], tellheight=false)
            end
            
            osym=Symbol("o"*string(o))
            xv= round(rs.r[rs[osym]], digits=2)
            xtv=[0,xv,1]
            xts=["0",string(xv),"1"]
            yv= round(rs[o][rs[osym]], digits=2)
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
            xticklabelcolor=ColorSchemes.tab20[i],
            yticks =(ytv,yts),
            yticklabelsize=12,
            yticklabelrotation=pi/2,
            yticklabelcolor=ColorSchemes.tab20[i],
            xgridcolor=ColorSchemes.tab20[i],
            ygridcolor=ColorSchemes.tab20[i],
            backgroundcolor="#f1f1f1",
            yaxisposition=:right,
            xaxisposition=:top)
            hidespines!(A[i,j])

            if i==1 || jj==length(outcomes)
                B[i,j]=Axis(f[j,i],
                xlabel=policyxlabels[i],
                yaxisposition=:left,
                xaxisposition=:bottom,
                backgroundcolor="#f1f1f1",
                yticklabelsize=12,
                xticklabelsize=12,
                xgridvisible=false,
                ygridvisible=false,
                xticklabelsvisible= jj==length(outcomes),
                xlabelvisible= jj==length(outcomes),
                yticklabelsvisible= i==1)
                lines!(B[i,j],rs.r,rs[o], color=:transparent, linewidth=0)
                hidespines!(B[i,j])
                if o==:RR 
                    B[i,j].yticks=[0.0,0.1,0.2,0.25]
                end
                #jj==length(outcomes) ? hidexdecorations!(B[i,j], ticklabels=false) : hidexdecorations!(B[i,j])
                #jj==length(outcomes)  ?   hideydecorations!(B[i,j],ticklabels=false ) : nothing
             end

             
            #j==length(outcomes) ? hidexdecorations!(A[i,j], label=false, ticklabels=false, grid=true) : hidexdecorations!(A[i,j])
            #i==1 ? hideydecorations!(A[i,j], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,j], grid=false)
            #hidespines!(A[i,j])
            lines!(A[i,j],rs.r,rs[o], color=ColorSchemes.tab20[i], linewidth=3)
            
            
            #vlines!(A[i,j], rs.r[rs[osym]],color=:black, linestyle=:dot)
            
            #text!(A[i,j],0.05,0.95,text=string(round(rs[o][rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:left,:top))
            
            #text!(A[i,j],rs.r[rs[osym]]-0.05,0.05,text=string(round(rs.r[rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:right,:bottom))

        end
        #length(outcomes)
        if u
            A[i,LL+1]=Axis(f[LL+1,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "") 
            heatmap!(A[i,LL+1],rs.sols, colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
            hidexdecorations!( A[i,LL+1])
            hidespines!( A[i,LL+1])
            i==1 ? hideydecorations!(A[i,LL+1], label=false, ticklabels=true, minorgrid=false) : hideydecorations!(A[i,LL+1], minorgrid=false, ticklabels=true)
            #hidespines!( A[i,LL+1])
            Label(f[1,0], text="Participation in\nresource use " , tellheight=false)

            #=[i,LL+2]=Axis(f[LL+2,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "")
            heatmap!(A[i,LL+2],log10.(rs.incdist), colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
            hidexdecorations!( A[i,LL+2])
            i==1 ? hideydecorations!(A[i,LL+2], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,LL+2], grid=false, ticklabels=true)
            #hidespines!( A[i,LL+2])
            Label(f[2,0], text="Incomes\n of actors" , tellheight=false)=#
        end
        if inc
            A[i,length(outcomes)+LL+2]=Axis(f[length(outcomes)+LL+2,i]) 
            incomes_plot!(A[i,length(outcomes)+LL+2],sim(policies[i], regulation=RS[i].r[RS[i].oGov]))
            hidedecorations!(A[i,length(outcomes)+LL+2])
        end
        policylabels[i]
        Label(f[0,i], text=policylabels[i],color=ColorSchemes.tab20[i], tellwidth=false)
    end
    #Label(f[length(outcomes)+LL+2,1:length(RS)], text="Regulation level", tellwidth=false, fontsize=25, font=:bold)
    sa=Axis(f[0,0], aspect=1)
    hidedecorations!(sa)
    hidespines!(sa)
    phase_plot!(sa,sim(s), incentive_line_color=:gray, impact_line_color=:gray)
    #Label(f[0,0], text="Outcomes", tellwidth=false, fontsize=25, font=:bold)

        [linkyaxes!([A[i,j+LL+1] for i in 1:length(RS)]...,B[1,j+1]) for j in 1:length(outcomes)]

    f
end

f5=regscan(s=high_impact(),u=true, inc=false)
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
function monte_carlo_scan(;N=1, k=[1.0,0.0,-0.0,0.0], optvar=false)
    RE=[]
    O=[]
    j=1
    while j<N

        print(string(j)*", ")
        mean_w̃=rand()
        sigma_w̃=rand()
        mean_ū=2*rand()
        sigma_ū=rand()*mean_ū
        s=scenario(base(),w̃=sed(mean=mean_w̃, sigma=sigma_w̃, distribution=LogNormal), ū=sed(mean=mean_ū, sigma=sigma_ū, normalize=true))
        sol=sim(s)
        if sol.u[end][end]<0.5
            policies=[
                scenario(s,policy="Exclusive Use Rights", reverse=true)
                scenario(s,policy="Exclusive Use Rights", reverse=false)
                scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
                scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
                scenario(s,policy="Protected Area", m=0.3)
                scenario(s,policy="Protected Area", m=0.5)
                scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
                scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
            
                ]
            
                maxG=[]
                maxvar=[]
                regulation=[]
                y0=[]
                part0=[]
                y=[]
                part=[]
                opt=[]
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
                push!(opt,(R.oRR, R.oWR, R.oTR, R.oToR, R.oGI, R.oEH, R.oRI,R.oGov))
                push!(maxvar,sum(abs.([R.oToR-R.oRR])))#[R.oRR-R.oGI,R.oToR-R.oRR,R.oGI-R.oRR,R.oGI-R.oToR]
                #=catch
                    push!(RE,scenario)
                    println((mean_w̃,mean_ū,sigma_w̃,sigma_ū, scenario.policy) )
                end=#
            end
            i=optvar ? argmax(maxvar) : argmax(maxG)
            push!(O,(policies[i]...,regulation=regulation[i],y0=y0[1],y=y[i], part0=part0[1], part=part[i], opt=opt[i]))
            j+=1
        end
    end
    return O
end

function monte_carlo_scan2(; M=1,N=100, k=[1.0, 0.0, -0.0, 0.0], optvar=false, mode=:mixed)
    RE = []
    O  = []

j=1
    Pars=MCdist(M*2;mode)


    while j<=M && j<size(Pars,1)
        mod(j,100)==0 ? print(string(j) * ", ") : nothing
        q=range(Pars[j,1]-Pars[j,2],stop=Pars[j,1]+Pars[j,2],length=N)./N
        w=sed(mean=Pars[j,3], sigma=Pars[j,4], distribution=LogNormal)
        dist!(w,N)

        #–– build & simulate baseline
        s = scenario(
            base(),
            w̃ = sed(data=w./q),
            ū = sed(data=q),
            wonky=R[j,5]
        )
        sol = sim(s)

        #–– only proceed if resource density < MSY
        if sol.u[end][end] < 0.5
            #–– enumerate all policy variants
            policies = [
                scenario(s, name="EURneed",policy="Exclusive Use Rights", reverse=true),
                scenario(s, name="EURgreed",policy="Exclusive Use Rights", reverse=false),
                scenario(s, name="TUReffort",policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05),
                scenario(s, name="TURyield",policy="Tradable Use Rights", policy_target=:yield,  market_rate=0.05),
                scenario(s, name="PA03",policy="Protected Area",      m=0.3),
                scenario(s, name="PA05",policy="Protected Area",      m=0.5),
                #scenario(s, name="EPmu",policy="Economic Incentives", policy_target=:μ, policy_method=:taxation),
                #scenario(s, name="EPga",policy="Economic Incentives", policy_target=:γ, policy_method=:taxation),
            ]

            n = length(policies)
            maxG       = zeros(n)
            maxRR      = zeros(n)
            maxToR     = zeros(n)
            maxGI      = zeros(n)
            regulation = Vector{Float64}(undef, n)
            y0         = zeros(n)
            y          = zeros(n)
            part0      = zeros(n)
            part       = zeros(n)
            opt        = Vector{Tuple}(undef, n)

            #–– scan each policy
            for i in 1:n
                p = policies[i]
                R = regulation_scan(p)
                G = R.RR.^k[1] .+ R.ToR.^k[2] .+ R.GI.^k[3] .+ R.EH.^k[4]

                maxG[i]       = maximum(G)
                maxRR[i]      = maximum(R.RR)
                maxToR[i]     = maximum(R.ToR)
                maxGI[i]      = 1-minimum(R.GI)
                regulation[i] = R.r[argmax(G)]
                y0[i]         = R.EH[1]
                y[i]          = R.EH[argmax(G)]
                part0[i]      = sum(R.sols[1, :]       ./ p.ū) / p.N
                part[i]       = sum(R.sols[argmax(G), :] ./ p.ū) / p.N
                opt[i]        = (R.oRR, R.oWR, R.oTR, R.oToR, R.oGI, R.oEH, R.oRI, R.oGov)
            end

            #–– normalize so best = 1.0 for each metric
            rel_G    = maxG    ./ maximum(maxG)
            rel_RR   = maxRR   ./ maximum(maxRR)
            rel_ToR  = maxToR  ./ maximum(maxToR)
            #gi_min = minimum(maxGI)
            #gi_max = maximum(maxGI)
            #rel_GI = (gi_max .- maxGI) ./ (gi_max - gi_min)
            rel_GI = maxGI  ./ maximum(maxGI)

            #–– push one entry per policy, preserving your original tuple shape
            for i in 1:n
                push!(O, (
                    policies[i]...,
                    regulation       = regulation[i],
                    y0               = y0[i],
                    y                = y[i],
                    part0            = part0[i],
                    part             = part[i],
                    opt              = opt[i],
                    relative_score   = rel_G[i],
                    relative_RR      = rel_RR[i],
                    relative_ToR     = rel_ToR[i],
                    relative_GI      = rel_GI[i],
                ))
            end

            #–– count only accepted draws
            j += 1
        end
    end

    return O
end
1+1

GR=monte_carlo_scan2(M=4000, k=[0.2,1.0,-0.2,0.05])

function analyzePolicies(A; goal=:relative_score)
    bgc=:gray
    wm=median([median(s.w̃) for s in A ])
    um=median([median(s.ū) for s in A ])
    policies=unique([s.name for s in A])
    f=Figure(size=(800,1000), title=string(goal))
    a1=Axis(f[2,1],ylabel="High ū", backgroundcolor=bgc)
    hidexdecorations!(a1)
    a2=Axis(f[3,1], ylabel="Low ū", backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
    a3=Axis(f[2,2], backgroundcolor=bgc)
    hidexdecorations!(a3)
    a4=Axis(f[3,2],  backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
    a5=Axis(f[4,1], xlabel="std(w̃)",  backgroundcolor=bgc)
    a6=Axis(f[4,2], xlabel="std(ū)",  backgroundcolor=bgc)
    Label(f[1,1],text="Low w̃", tellwidth=false)
    Label(f[1,2],text="High w̃", tellwidth=false)
    Label(f[0,1:2],text=string(goal),fontsize=30, tellwidth=false)
    alpha=0.5
    markersize=2
    mw=0.3
        id1=findall([median(s.w̃) for s in A].<wm .&& [median(s.ū) for s in A].>um)
        scatter!(a1,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id1]],[s[goal] for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
        #hist!(a1,[s[goal] for s in A[ids][id1]], color=ColorSchemes.tab20[i])
        plotMedians(A,a1,id1, policies,goal)
        id2=findall([median(s.w̃) for s in A].<wm .&& [median(s.ū) for s in A].<um) 
        scatter!(a2,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id2]],[s[goal] for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
        plotMedians(A,a2,id2, policies,goal)

        id3=findall([median(s.w̃) for s in A].>wm .&& [median(s.ū) for s in A].>um)
        scatter!(a3,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id3]],[s[goal] for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
        plotMedians(A,a3,id3, policies,goal)

        id4=findall([median(s.w̃) for s in A].>wm .&& [median(s.ū) for s in A].<um)
        scatter!(a4,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
        plotMedians(A,a4,id4, policies,goal)
        scatter!(a5,[std(s.w̃) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)
        scatter!(a6,[std(s.ū) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)

        linkaxes!([a1,a2,a3,a4])
    f
end

function analyzePoliciesY0(A; goal=:relative_score)
    bgc=:gray
    wm=median([median(s.w̃) for s in A ])
    um=median([median(s.ū) for s in A ])
    policies=unique([s.name for s in A])
    f=Figure(size=(400,400), title=string(goal))
    a1=Axis(f[2,1],ylabel="moderately overfished", backgroundcolor=bgc)
    hidexdecorations!(a1)
    a2=Axis(f[3,1], ylabel="highly overfished", backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
    a3=Axis(f[2,2], backgroundcolor=bgc)
    hidexdecorations!(a3)
    a4=Axis(f[3,2],  backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
   # a5=Axis(f[4,1], xlabel="std(w̃)", backgroundcolor=bgc)
   # a6=Axis(f[4,2], xlabel="std(ū)", backgroundcolor=bgc)
    Label(f[1,1],text="Low w̃", tellwidth=false)
    Label(f[1,2],text="High w̃", tellwidth=false)
    Label(f[0,1:2],text=string(goal),fontsize=30, tellwidth=false)
    alpha=0.5
    markersize=2
    mw=0.3
        id1=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].>0.25)
        scatter!(a1,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id1]],[s[goal] for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
        #hist!(a1,[s[goal] for s in A[ids][id1]], color=ColorSchemes.tab20[i])
        plotMedians(A,a1,id1, policies,goal)
        id2=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].<0.25) 
        scatter!(a2,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id2]],[s[goal] for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
        plotMedians(A,a2,id2, policies,goal)

        id3=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].>0.25)
        scatter!(a3,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id3]],[s[goal] for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
        plotMedians(A,a3,id3, policies,goal)

        id4=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].<0.25)
        scatter!(a4,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
        plotMedians(A,a4,id4, policies,goal)
        #scatter!(a5,[std(s.w̃) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)
        #scatter!(a6,[std(s.ū) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)

        linkaxes!([a1,a2,a3,a4])
    f
end

function analyzePoliciesY02(A; goal=:relative_score)
    bgc=:black
    alpha=0.5
    markersize=2
    mw=1.0
    C=clamp.([cov(s.w̃,s.ū).*100 for s in A],-1,1)

    wm=median([median(s.w̃) for s in A ])
    um=median([median(s.ū) for s in A ])
    policies=unique([s.name for s in A])
    f=Figure(size=(800,800), title=string(goal), rowgap=1, colgap=1)

    goal=:relative_RR
    a1=Axis(f[2,1],xreversed=true, yreversed=true,ylabel="moderately\noverfished", backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hidexdecorations!(a1, grid=false)
    a2=Axis(f[3,1],xreversed=true, yreversed=true, ylabel="highly\noverfished", xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]),backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    a3=Axis(f[2,2],xreversed=true, yreversed=true, backgroundcolor=bgc, ygridvisible=false)
    hidexdecorations!(a3, grid=false)
    hideydecorations!(a3)
    a4=Axis(f[3,2],xreversed=true, yreversed=true,  backgroundcolor=bgc, ygridvisible=false, xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]))
    hideydecorations!(a4)
    Label(f[1,1],text="Low w̃", tellwidth=false)
    Label(f[1,2],text="High w̃", tellwidth=false)
    Label(f[0,1:2],text="Resource Revenue",fontsize=30, tellwidth=false)
    [hidespines!(x) for x in [a1,a2,a3,a4]]

    id1=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].>0.25)
    scatter!(a1,[s[goal] for s in A[id1]],[findall(s.name.==policies)[1].+clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
    plotMedians(A,a1,id1, policies,goal)
    score(a1,A,id1,goal)
    id2=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].<0.25) 
    scatter!(a2,[s[goal] for s in A[id2]],[findall(s.name.==policies)[1].+clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
    plotMedians(A,a2,id2, policies,goal)
    score(a2,A,id2,goal)

    id3=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].>0.25)
    scatter!(a3,[s[goal] for s in A[id3]],[findall(s.name.==policies)[1].+clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
    plotMedians(A,a3,id3, policies,goal)
    score(a3,A,id3,goal)
    id4=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].<0.25)
    scatter!(a4,[s[goal] for s in A[id4]],[findall(s.name.==policies)[1].+clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
    plotMedians(A,a4,id4, policies,goal)
    score(a4,A,id4,goal)
    [xlims!(a,1.01,0.4) for a in [a1,a2,a3,a4]]
    linkaxes!([a1,a2,a3,a4])

    goal=:relative_ToR
    a1=Axis(f[2,3],xreversed=true, yreversed=true,ylabel="moderately\noverfished", backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hidexdecorations!(a1, grid=false)
    hideydecorations!(a1)
    a2=Axis(f[3,3],xreversed=true, yreversed=true, ylabel="highly\noverfished", xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]),backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hideydecorations!(a2)
    a3=Axis(f[2,4],xreversed=true, yreversed=true, backgroundcolor=bgc, ygridvisible=false)
    hidexdecorations!(a3, grid=false)
    hideydecorations!(a3)
    a4=Axis(f[3,4],xreversed=true, yreversed=true,  backgroundcolor=bgc, ygridvisible=false, xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]))
    hideydecorations!(a4)
    Label(f[1,3],text="Low w̃", tellwidth=false)
    Label(f[1,4],text="High w̃", tellwidth=false)
    Label(f[0,3:4],text="Total Revenue",fontsize=30, tellwidth=false)
    [hidespines!(x) for x in [a1,a2,a3,a4]]

    id1=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].>0.25)
    scatter!(a1,[s[goal] for s in A[id1]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
    plotMedians(A,a1,id1, policies,goal)
    score(a1,A,id1,goal)
    id2=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].<0.25) 
    scatter!(a2,[s[goal] for s in A[id2]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
    plotMedians(A,a2,id2, policies,goal)
    score(a2,A,id2,goal)

    id3=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].>0.25)
    scatter!(a3,[s[goal] for s in A[id3]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
    plotMedians(A,a3,id3, policies,goal)
    score(a3,A,id3,goal)

    id4=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].<0.25)
    scatter!(a4,[s[goal] for s in A[id4]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
    plotMedians(A,a4,id4, policies,goal)
    score(a4,A,id4,goal)
    [xlims!(a,1.01,0.4) for a in [a1,a2,a3,a4]]
    linkaxes!([a1,a2,a3,a4])

    goal=:relative_GI
    a1=Axis(f[5,1],xreversed=true, yreversed=true,ylabel="moderately\noverfished", backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hidexdecorations!(a1, grid=false)
    a2=Axis(f[6,1],xreversed=true, yreversed=true, ylabel="highly\noverfished", xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]),backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    a3=Axis(f[5,2],xreversed=true, yreversed=true, backgroundcolor=bgc, ygridvisible=false)
    hidexdecorations!(a3, grid=false)
    hideydecorations!(a3)
    a4=Axis(f[6,2],xreversed=true, yreversed=true,  backgroundcolor=bgc, ygridvisible=false, xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]))
    hideydecorations!(a4)
    Label(f[4,1:2],text="Gini",fontsize=30, tellwidth=false)
    [hidespines!(x) for x in [a1,a2,a3,a4]]
    id1=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].>0.25) #mw.*(0.5 .- rand())
    scatter!(a1,[s[goal] for s in A[id1]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
    plotMedians(A,a1,id1, policies,goal)
    score(a1,A,id1,goal)
    id2=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].<0.25) 
    scatter!(a2,[s[goal] for s in A[id2]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
    plotMedians(A,a2,id2, policies,goal)
    score(a2,A,id2,goal)

    id3=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].>0.25)
    scatter!(a3,[s[goal] for s in A[id3]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
    plotMedians(A,a3,id3, policies,goal)
    score(a3,A,id3,goal)

    id4=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].<0.25)
    scatter!(a4,[s[goal] for s in A[id4]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
    plotMedians(A,a4,id4, policies,goal)
    score(a4,A,id4,goal)
    [xlims!(a,1.01,0.4) for a in [a1,a2,a3,a4]]
    linkaxes!([a1,a2,a3,a4])


    goal=:relative_score
    a1=Axis(f[5,3],xreversed=true, yreversed=true,ylabel="moderately\noverfished", backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hidexdecorations!(a1, grid=false)
    hideydecorations!(a1)
    a2=Axis(f[6,3],xreversed=true, yreversed=true, ylabel="highly\noverfished", xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]),backgroundcolor=bgc, yticks=(1:length(policies),policies),  yticklabelcolor=ColorSchemes.tab20[1:length(policies)], ygridvisible=false)
    hideydecorations!(a2)
    a3=Axis(f[5,4],xreversed=true, yreversed=true, backgroundcolor=bgc, ygridvisible=false)
    hidexdecorations!(a3, grid=false)
    hideydecorations!(a3)
    a4=Axis(f[6,4],xreversed=true, yreversed=true,  backgroundcolor=bgc, ygridvisible=false, xticks=([1,.9,.8,.7,.6,.5,.4],["1",".9",".8",".7",".6",".5",".4"]))
    hideydecorations!(a4)
    Label(f[4,3:4],text="Governance goal",fontsize=30, tellwidth=false)
    [hidespines!(x) for x in [a1,a2,a3,a4]]

    id1=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].>0.25)
    scatter!(a1,[s[goal] for s in A[id1]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
    plotMedians(A,a1,id1, policies,goal)
    score(a1,A,id1,goal)
    id2=findall([median(s.w̃) for s in A].<wm .&& [s.y0 for s in A].<0.25) 
    scatter!(a2,[s[goal] for s in A[id2]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
    plotMedians(A,a2,id2, policies,goal)
    score(a2,A,id2,goal)

    id3=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].>0.25)
    scatter!(a3,[s[goal] for s in A[id3]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
    plotMedians(A,a3,id3, policies,goal)
    score(a3,A,id3,goal)

    id4=findall([median(s.w̃) for s in A].>wm .&& [s.y0 for s in A].<0.25)
    scatter!(a4,[s[goal] for s in A[id4]],[findall(s.name.==policies)[1].-clamp.(cov(s.w̃,s.ū).*50 ,-1,1) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
    plotMedians(A,a4,id4, policies,goal)
    score(a4,A,id4,goal)
    [xlims!(a,1.01,0.4) for a in [a1,a2,a3,a4]]
    linkaxes!([a1,a2,a3,a4])

    f
end



f6=analyzePoliciesY02(GR, goal=:relative_GI)

save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/figure6.png",f6)

A=GR
id1=findall([median(s.w̃) for s in A].<1 .&& [s.y0 for s in A].>0.25)

function score(a,A,id,goal, p=0.99)
    S=zeros(6)
    Su=zeros(6)
    for i in 1:Int64(round(length(id)/6))
        s=[A[id[(i-1)*6+j]][goal] for j in 1:6 ]
        S.+=s.>p
        Su.+=s.>p .&& sum(s.>p)==1
    end
    [text!(a,0.41,i,text=rich(string(Int64(Su[i]))," ",rich(string(Int64(S[i])), color=:darkorange), color=:white, fontsize=10), align=(:right,:center)) for i in 1:6]
end

function analyzePoliciesSigma(A; goal=:relative_score)
    bgc=:gray
    wm=median([median(s.w̃) for s in A ])
    um=median([median(s.ū) for s in A ])
    policies=unique([s.name for s in A])
    f=Figure(size=(800,1000), title=string(goal))
    a1=Axis(f[2,1],ylabel="positive correlation", backgroundcolor=bgc)
    hidexdecorations!(a1)
    
    a2=Axis(f[3,1], ylabel="negative correlation", backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
    a3=Axis(f[2,2], backgroundcolor=bgc)
    hidexdecorations!(a3)
    hideydecorations!(a3)
    a4=Axis(f[3,2],  backgroundcolor=bgc, xticks=(1:length(policies),policies), xticklabelrotation=-pi/4, xticklabelcolor=ColorSchemes.tab20[1:length(policies)])
    a5=Axis(f[4,1], xlabel="std(w̃)", backgroundcolor=bgc)
    a6=Axis(f[4,2], xlabel="std(ū)", backgroundcolor=bgc)
    Label(f[1,1],text="Low w̃", tellwidth=false)
    Label(f[1,2],text="High w̃", tellwidth=false)
    Label(f[0,1:2],text=string(goal),fontsize=30, tellwidth=false)
    alpha=0.5
    markersize=2
    mw=0.3
        id1=findall([median(s.w̃) for s in A].<wm .&& [s.ū.sigma for s in A].>0.0)
        scatter!(a1,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id1]],[s[goal] for s in A[id1]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id1]]]; markersize,alpha)
        #hist!(a1,[s[goal] for s in A[ids][id1]], color=ColorSchemes.tab20[i])
        plotMedians(A,a1,id1, policies,goal)

        id2=findall([median(s.w̃) for s in A].<wm .&& [s.ū.sigma for s in A].<0.0) 
        scatter!(a2,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id2]],[s[goal] for s in A[id2]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id2]]]; markersize,alpha)
        plotMedians(A,a2,id2, policies,goal)

        id3=findall([median(s.w̃) for s in A].>wm .&& [s.ū.sigma for s in A].>0.0)
        scatter!(a3,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id3]],[s[goal] for s in A[id3]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id3]]]; markersize,alpha)
        plotMedians(A,a3,id3, policies,goal)

        id4=findall([median(s.w̃) for s in A].>wm .&& [s.ū.sigma for s in A].<0.0)
        scatter!(a4,[findall(s.name.==policies)[1]+mw.*(0.5 .- rand()) for s in A[id4]],[s[goal] for s in A[id4]], color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A[id4]]]; markersize,alpha)
        plotMedians(A,a4,id4, policies,goal)

        scatter!(a5,[std(s.w̃) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)
        scatter!(a6,[std(s.ū) for s in A],[s[goal] for s in A],color=ColorSchemes.tab20[[findall(s.name.==policies)[1] for s in A]]; markersize,alpha)

        linkaxes!([a1,a2,a3,a4])
    f
end

function plotMedians(A,a1,id1, policies,goal)
    medians = [median([isnan(s[goal]) ? 0.0 : s[goal] for s in A[id1] if s.name .== p ]) for p in policies]
    println([median([isnan(s[goal]) ? 0.0 : s[goal] for s in A[id1] if s.name .== p ]) for p in policies])
# 2) x‐positions are just 1:length(policies)
xs = 1:length(policies)

# 3) overplot as big black diamonds
scatter!(a1,
medians,xs;
marker     = :dot,
markersize = 6,
color      = :white,
strokewidth= 0,
strokecolor=:white,
)
end

function regfig(s)
    R=regulation_scan(s)
    f=Figure()
    a=Axis(f[1,1])
    b=Axis(f[1,2])
    lines!(a,R.RR, label="resource")
    lines!(a,R.ToR, label="total")
    lines!(a,R.GI, label="gini")
    axislegend(a)
    phase_plot!(b,sim(s))
    f
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
