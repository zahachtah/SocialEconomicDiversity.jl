function figure2(;s=base())
    incometext(incomes)="R:"*string(round(sum(incomes.resource),digits=2))*"  T:"*string(round(sum(incomes.total),digits=2))*"  G:"*string(round(incomes.gini,digits=2))

    f=Figure(size=(350,700), rowgap=50)
    a=Axis(f[1,1], xlabel="Resource level, y, corresponds to w̃", ylabel="Participation", title="System Outcomes", titlesize=20, titlecolor=:gray, xticks=([0.0,0.5,1.0],["0","MSY=0.5","1"]))
    b=Axis(f[2,1], ylabel="Incomes", xlabel="Actor's sorted by w̃", title=" \nIndividual Actor incomes", titlesize=20, titlecolor=:crimson)
    hidespines!(a)
    hidespines!(b)
    phase_plot!(a,sim(s), impact_line_color=:steelblue, incentive_line_color=:darkorange)
    sol=sim(s)
    y=range(sol.u[end][end]+0.08, stop=0.87, length=600)
    G=Γ.(y,Ref(s))
    lines!(a,y,G, color=:white, alpha=0.7, linewidth=3)

    attractor_plot!(a,sol, color=:gray, markersize=12)

    text!(a, 0.12,0.79, text="Impact distribution determines\n    participation required\n       for resource equilibrium, Φ(y)", fontsize=14, color=:steelblue)
    text!(a, 0.18,0.01, text="    Cumulative incentive\n  distribution determines\nparticipation level, Γ(y)", color=:darkorange)
    text!(a,0.01,0.585,text="Resource\nincreases", fontsize=10)
    text!(a,0.99,0.585,text="Resource\ndecreases", align=(:right,:bottom), fontsize=10)
    arrows!(a,[0.0],[0.63],[0.34],[0.0], color=:gray)
    arrows!(a,[1.0],[0.63],[-0.60],[0.0], color=:gray)
    text!(a,0.42,0.4,text="Attractor", align=(:center,:bottom))
    arrows!(a,[0.37],[0.46],[0],[0.12])

    incomes_plot!(b,sim(s), order=true, xlabel_as_w̃=false, color=:crimson)
    text!(b,4,0.0024,text="Net resource\nincome", font=:bold, color=:white)
    #text!(b,4,0.0001,text="Opportunity cost\nof resource use", font=:bold)
    text!(b,45,0.0003,text="Alternative\nlivelihood\nincentives, or\nopportunity cost", font=:bold, color=:white)
    arrows!(b,[1],[0.004],[60],[0.0])
    arrows!(b,[60],[0.004],[-58],[0.0])
    text!(b,10,0.0042,text="Resource users")
    inc=incomes(sim(s))
    text!(b,0.05,0.9,text="Total resource income (R): "*string(round(sum(inc.resource),digits=2)), space=:relative)
    text!(b,0.05,0.82,text="              Total income: (T): "*string(round(sum(inc.total),digits=2)), space=:relative)
    text!(b,0.05,0.74,text="                             Gini (G): "*string(round(sum(inc.gini),digits=2)), space=:relative)
    f
end

f2=figure2()

save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/figure2.png",f2)

function figure3(;s=high_impact())
    no_change=:lightgray
    base_w̃=0.3


    f=Figure(size=(800,600))
    w̃_sigma_plot=Axis(f[2,1])
    w̃_median_plot=Axis(f[3,1])
    ū_mean_plot=Axis(f[2,2])
    ū_cor_plot=Axis(f[3,2])
    α_plot=Axis(f[2,3])
    inc_plot=Axis(f[3,3], xlabel="time  →", ylabel="actor's w̃", yaxisposition=:right, xscale=log10)

    [hidespines!(a) for a in [w̃_sigma_plot,w̃_median_plot,ū_mean_plot,ū_cor_plot,α_plot,inc_plot]]
    [hidedecorations!(a) for a in [w̃_sigma_plot,w̃_median_plot,ū_mean_plot,ū_cor_plot,α_plot]]
    #hideydecorations!(inc_plot)

    
    s=scenario(s,w̃=sed(median=0.3, sigma=0.8, distribution=LogNormal))
    #[phase_plot!(a,sim(s)) for a in [α_plot]]
    
    phase_plot!(w̃_sigma_plot,sim(scenario(s,w̃=sed(median=0.5, sigma=0.8, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_sigma_plot,sim(scenario(s,w̃=sed(median=0.5, sigma=0.3, distribution=LogNormal))), impact_line_color=no_change,show_exploitation=false)
    phase_plot!(w̃_sigma_plot,sim(scenario(s,w̃=sed(median=0.5, sigma=0.0, distribution=LogNormal))), impact_line_color=no_change,show_exploitation=false)
    arrow_arc_deg!(w̃_sigma_plot,[0.5,0.5],0.4,0,60)
    #Γ_plot!(w̃_sigma_plot,sim(s))
    text!(w̃_sigma_plot,0.7,0.5,text="Increasing\nvariance")
    text!(w̃_sigma_plot,0.02,0.91, text="a)")

    phase_plot!(w̃_median_plot,sim(scenario(s,w̃=sed(min=0.1, max=0.5, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_median_plot,sim(scenario(s,w̃=sed(min=0.3, max=0.7, distribution=LogNormal))), impact_line_color=no_change,show_exploitation=false)
    phase_plot!(w̃_median_plot,sim(scenario(s,w̃=sed(min=0.5, max=0.9, distribution=LogNormal))), impact_line_color=no_change,show_exploitation=false)
    #Γ_plot!(w̃_median_plot,sim(s))
    text!(w̃_median_plot,0.7,0.4,text="Increasing\nmean w̃")
    arrows!(w̃_median_plot,[0.24],[0.5],[0.4],[0.0])
    text!(w̃_median_plot,0.02,0.91, text="b)")
    
    phase_plot!(ū_mean_plot,sim(s), incentive_line_color=no_change)
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=0.5,sigma=0.0, normalize=true))))
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=1.0,sigma=0.0, normalize=true))))
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))))
    text!(ū_mean_plot,0.2,0.15,text="Increasing ūᵢ")
    arrow_arc_deg!(ū_mean_plot,[1.0,0.0],0.5,-25,-60, flip_arrow=true)
    attractor_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))), color=:black, markersize=12)
    attractor_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=1.0,sigma=0.0, normalize=true))), color=:black, markersize=12)
    attractor_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=0.5,sigma=0.0, normalize=true))), color=:black, markersize=12)
    text!(ū_mean_plot,0.02,0.91, text="c)")

    phase_plot!(ū_cor_plot,sim(s), incentive_line_color=no_change)
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=4.0, normalize=true))))
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))), color=no_change)
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=-4.0, normalize=true))))
    attractor_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=4.0, normalize=true))), color=:black, markersize=12)
    attractor_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))), color=:black, markersize=12)
    attractor_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=-4.0, normalize=true))), color=:black, markersize=12)
    text!(ū_cor_plot,0.45,0.55,text="cor(w̃,ū)<0")  
    text!(ū_cor_plot,0.2,0.07,text="cor(w̃,ū)>0")  
    text!(ū_cor_plot,0.325,0.35,text="cor(w̃,ū)=0")  
    text!(ū_cor_plot,0.02,0.91, text="d)") 

    phase_plot!(α_plot,sim(s), impact_line_color=no_change,incentive_line_color=no_change, show_trajectory=true, trajectory_color=:darkorange)
    text!(α_plot,0.1,0.85,text="trajectory @ α=0.05", color=:darkorange)
    phase_plot!(α_plot,sim(scenario(s, α=0.01)), impact_line_color=no_change,incentive_line_color=no_change, show_trajectory=true,show_exploitation=false, trajectory_color=:crimson)
    text!(α_plot,0.4,0.5,text="trajectory @ α=0.01", color=:crimson)  
    text!(α_plot,0.02,0.91, text="e)")   


    #incomes_plot!(inc_plot,sim(s))
    a=heatmap!(inc_plot,sim(scenario(s, α=0.05)).t.+1,s.w̃, sim(scenario(s, α=0.05))[1:100,:]', colormap=cgrad([:white,:darkorange]))
    elements=[[PolyElement(color = :darkorange, strokecolor = :lightgray, strokewidth = 1)],[PolyElement(color = :darkorange, strokecolor = :lightgray, strokewidth = 1, alpha=0.5)],[PolyElement(color = :white, strokecolor = :lightgray, strokewidth = 1)]]
          axislegend(inc_plot,elements, ["Full resource use","Half resource use", "No resource use"], framevisible=false, "Individual actor's\nresource use over time", rowgap=0)
          #xlims!(inc_plot,(0.0,10.0))
          ylims!(inc_plot,(0.0,1.0))
          text!(inc_plot,1.3,0.91, text="f)")   
    #[lines!(inc_plot,sim(s).t,sim(s)[i,:], label="w̃=$(round(s.w̃[i],digits=2))", color=cgrad(:viridis)[Int64(round(i/100*255))]) for i in 1:2:100]
   #xlims!(inc_plot,(0.0,20.0))
   #axislegend(inc_plot,framevisible=false)

    Label(f[1,1], text="Incentives, w̃", tellwidth=false, font=:bold)
    Label(f[1,2], text="Impact, ū", tellwidth=false, font=:bold)
    Label(f[1,3], text="Dynamics, α", tellwidth=false, font=:bold)
    Label(f[0,1:3],text="Effects of relational variable's distributions", tellwidth=false, font=:bold, fontsize=22)
    f

end

f3=figure3()

save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/figure3.png",f3)




s=(N=100,q=sed(min=0.0,max=10.0), w=sed(min=0.1,max=0.9,distribution=LogNormal), p=1,ē=1,K=1,r=1, α=0.05)

dist!(s)

N=100
q=range(0.9,stop=0.2, length=N)
w=range(0.1,stop=1.0,length=N)
s=(;w̃=sed(data=w./q), ū=sed(data=q), α=sed(mean=0.05),N)
sol=sim(s)

f=Figure()
a=Axis(f[1,1])
scatter!(a,s.w̃)
scatter!(a,s.ū )
f

M=1000
V=zeros(M,2)
WONK=zeros(M)
N=100
f=Figure()
a=Axis(f[1,1])
for i in 1:M
    qmean=rand()*5 .+0.1
    qvar=(1-2*rand())*qmean
    q=range(qmean-qvar,stop=qmean+qvar,length=N)./N
    wmean=rand()*0.01
    wvar=(1-2*rand())*wmean
    w=sed(mean=wmean, sigma=wvar, distribution=LogNormal)
    dist!(w,N)
    ubar=q
    wtilde=w./q
    wonky=length(unique(sign.(diff(wtilde))))>1 ? true : false
    WONK[i]=wonky
    Y=range(0.0,stop=1.0,length=100)
    wc=[length(findall(wtilde.<y)) for y in Y]
    minimum(wtilde)<1.0 ? lines!(a,wc./N, color=wonky ? :red : :blue) : nothing
    V[i,:].=extrema(wtilde)
end
f
id=findall(V[:,1].>1.0)
sum(WONK)
hist(V[id,2])

function MCdist(M;mode=:mixed)
    R=zeros(M,5)
    k=0
    while k<M
        qmean=rand()*5 .+0.1
        qvar=(1-2*rand())*qmean
        q=range(qmean-qvar,stop=qmean+qvar,length=N)./N
        wmean=rand()*0.01
        wvar=(1-2*rand())*wmean
        w=sed(mean=wmean, sigma=wvar, distribution=LogNormal)
        dist!(w,N)
        ubar=q
        wtilde=w./q
        wonky=length(unique(sign.(diff(wtilde))))>1 ? true : false
        
        Y=range(0.0,stop=1.0,length=100)
        wc=[length(findall(wtilde.<y)) for y in Y]
        minimum(wtilde)<1.0 ? lines!(a,wc./N, color=wonky ? :red : :blue) : nothing
        if mode==:mixed
            k+=1
            R[k,:].=[qmean,qvar,wmean,wvar,wonky]
            
        elseif mode==:wonky && wonky
            k+=1
            R[k,:].=[qmean,qvar,wmean,wvar,wonky]
            
        elseif mode==:nonwonky && !wonky
            k+=1
            R[k,:].=[qmean,qvar,wmean,wvar,wonky]
            
        end
    end
    return R
end