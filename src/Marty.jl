	w̃=sed(min=0.1,max=0.9,distribution=LogNormal) #distribution=LogNormal | Uniform
	# change the minimum and maximum of the distribution
    
    ū=sed(mean=2.0, sigma=-1.2, normalize=true)
    # set teh mean as total impact, and normalize to divide by No of actors.
    # sigma=0 means constant for all, sigma value positive or negative induces correlations


    f=plot(w̃,ū, order=false,goal=:oRR)
    # order=true orderes incomes according to total income, instead of index/w̃
    # goal: choose :oRR for resource revenue optima, :oToR for total optima or :oGI for gini



    

    function plot(w̃,ū; order=false, goal=:oRR)
        # base() provides a default setup
        # scenario(s,args) takes a scenario s, and adds or changes any params, arg.
        TUR=scenario(base();w̃,ū, policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05, title="effort")
        TUR_regscan=regulation_scan(TUR)
        sTUR=sim(TUR,regulation=TUR_regscan.r[TUR_regscan[goal]])
        # Tradable quotas needs a market_rate parameter

        TURy=scenario(base();w̃,ū, policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05, title="yield")
        TURy_regscan=regulation_scan(TURy)
        sTURy=sim(TURy,regulation=TURy_regscan.r[TURy_regscan[goal]])
    
        EURf=scenario(base();w̃,ū, policy="Exclusive Use Rights", reverse=false, title="low w̃ excluded")
        EURf_regscan=regulation_scan(EURf)
        sEURf=sim(EURf,regulation=EURf_regscan.r[EURf_regscan[goal]])
        # Exclusive use rigths: exclusions of low w̃  set reverse=false (one could exclude by other criteria also e.g. ū ...)
    
        EUR=scenario(base();w̃,ū, policy="Exclusive Use Rights", reverse=true, title="high w̃ excluded")
        EUR_regscan=regulation_scan(EUR)
        sEUR=sim(EUR,regulation=EUR_regscan.r[EUR_regscan[goal]])

        PA=scenario(base();w̃,ū, policy="Protected Area", m=0.2, title="")
        PA_regscan=regulation_scan(PA)
        sPA=sim(PA,regulation=PA_regscan.r[PA_regscan[goal]])
        f=Figure(size=(800,800))
        OA=scenario(base();w̃,ū,title="")
        sols=vcat(sim(OA),sEUR,sTUR,sPA,sEURf,sTURy)
        incometext(incomes)="R:"*string(round(sum(incomes.resource),digits=2))*"  T:"*string(round(sum(incomes.total),digits=2))*"  G:"*string(round(incomes.gini,digits=2))

        for i in 1:length(sols)
          
            j=  i>3 ?   2 : 0
            k= i> 3 ? 3 : 0
            
            a=Axis(f[i-k,1+j], title=sols[i].prob.p.policy)
            b=Axis(f[i-k,2+j], title=sols[i].prob.p.title)
            hidedecorations!(a)
            hidedecorations!(b)
            phase_plot!(a,sols[i])
            if sols[i].prob.p.policy=="Exclusive Use Rights"
                id=findall(sols[i].prob.p.R.==1.0)
                y=range(0.0,stop=1.0,length=sols[i].prob.p.N)
                z=Γ.(sols[i].prob.p.w̃[id], Ref(scenario(sols[i].prob.p,policy="Open Access")))
            
                lines!(a,sols[i].prob.p.w̃[id],max.(0.005,z), color=:red, linewidth=2)
            elseif sols[i].prob.p.policy=="Tradable Use Rights"

            end
            incomes_plot!(b,sols[i]; order)
            text!(b,0.0,0.9,text=incometext(incomes(sols[i])), space=:relative)
        end
        f
    end