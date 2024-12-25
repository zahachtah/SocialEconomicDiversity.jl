

include("system_dynamics_figure.jl")

function martyPlot(S)
    f=Figure(size=(1000,800))
    w_q_plot=Axis(f[1,1])
    w̃_ū_plot=Axis(f[1,2])
    w̃_vs_ū_plot=Axis(f[1,3])
    xlims!(w̃_vs_ū_plot,0.1,1.0)
    ylims!(w̃_vs_ū_plot,0.0,0.2)
    phaseplane=Axis(f[2:3,1:2])
    incomes_nd=Axis(f[2,3])
    SEDplot!(w_q_plot,S,:id,:w, color=colorant"crimson")
    SEDplot!(w_q_plot,S,:id,:q, color=colorant"steelblue")
    SEDplot!(w̃_ū_plot,S,:id,:w̃, color=colorant"crimson")
    SEDplot!(w̃_ū_plot,S,:id,:ū, color=colorant"steelblue")
    SEDplot!(w̃_vs_ū_plot,S,:w̃,:ū, color=colorant"gray")
    phaseplot!(phaseplane,S, show_trajectory=true)
    incomes!(incomes_nd,S, fix_xlim=false)
    f
end


function figureInstitutions(;show_realized=false,N=20,size=(1200,900),p=1)
    f=Figure(;size)

        PermitLow=Axis(f[1,1], aspect=1, title="Permits low w")
        hidespines!(PermitLow)
        #hidedecorations!(PermitLow)

        PermitHigh=Axis(f[1,2], aspect=1, title="Permits high w")
        hidespines!(PermitHigh)
        #hidedecorations!(PermitHigh)

        ECeffort=Axis(f[2,1], aspect=1, title="Shared Effort")
        hidespines!(ECeffort)
        #hidedecorations!(ECeffort)

        ECyield=Axis(f[2,2], aspect=1, title="Shared Yield")
        hidespines!(ECyield)
        #hidedecorations!(ECyield)

        TQeffort=Axis(f[3,1], aspect=1, title="Tradable Effort")
        hidespines!(TQeffort)
        #hidedecorations!(TQeffort)

        TQyield=Axis(f[3,2], aspect=1, title="Tradable Yield")
        hidespines!(TQyield)
        #hidedecorations!(TQyield)

        protectedArea=Axis(f[1:2,3:4], aspect=1, title="Protected Area")
        hidespines!(protectedArea)
        #hidedecorations!(protectedArea)

        price=Axis(f[3,3], aspect=1, title="Price tax/sub")
        hidespines!(price)
        #hidedecorations!(price)

        effort=Axis(f[3,4], aspect=1, title="Effort tax/sub")
        hidespines!(effort)
        #hidedecorations!(effort)

        numactors1=Axis(f[4,1], aspect=1, title="Single actor")
        hidespines!(numactors1)
        #hidedecorations!(numactors1)
        numactors2=Axis(f[4,2], aspect=1, title="10 actors")
        hidespines!(numactors2)
        #hidedecorations!(numactors2)
        numactors3=Axis(f[4,3], aspect=1, title="100 actors")
        hidespines!(numactors3)
        #hidedecorations!(numactors3)

        test=Axis(f[1:3,1:4])
        hidespines!(test)
        hidedecorations!(test)
        high=:crimson
        medium=:gray
        low=:steelblue
        phaseplot!(PermitLow,scenario(institution="PLL",target="effort",value=0.1, color=:black;N,p);show_realized)
        phaseplot!(PermitLow,scenario(institution="PLL",target="effort",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(PermitLow,scenario(institution="PLL",target="effort",value=0.25,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(PermitLow,scenario(institution="PLL",target="effort",value=0.4,color=high;N,p);show_realized, show_potential=false, show_required=false)
       
        phaseplot!(PermitHigh,scenario(institution="PHL",target="effort",value=0.1,color=:black;N,p);show_realized)
        phaseplot!(PermitHigh,scenario(institution="PHL",target="effort",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(PermitHigh,scenario(institution="PHL",target="effort",value=0.25,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(PermitHigh,scenario(institution="PHL",target="effort",value=0.4,color=high;N,p);show_realized, show_potential=false, show_required=false)
        I="EC"
        phaseplot!(ECeffort,scenario(institution=I,target="effort",value=0.1,color=:black;N,p);show_realized)
        phaseplot!(ECeffort,scenario(institution=I,target="effort",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(ECeffort,scenario(institution=I,target="effort",value=0.25,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(ECeffort,scenario(institution=I,target="effort",value=0.4,color=high;N,p);show_realized, show_potential=false, show_required=false)

        phaseplot!(ECyield,scenario(institution=I,target="yield",value=0.1,color=:black;N,p);show_realized)
        phaseplot!(ECyield,scenario(institution=I,target="yield",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(ECyield,scenario(institution=I,target="yield",value=0.2,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(ECyield,scenario(institution=I,target="yield",value=0.3,color=high;N,p);show_realized, show_potential=false, show_required=false)

        I="TQ"
        phaseplot!(TQeffort,scenario(institution=I,target="effort",value=0.1,color=:black;N,p);show_realized)
        phaseplot!(TQeffort,scenario(institution=I,target="effort",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(TQeffort,scenario(institution=I,target="effort",value=0.25,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(TQeffort,scenario(institution=I,target="effort",value=0.4,color=high;N,p);show_realized, show_potential=false, show_required=false)

        phaseplot!(TQyield,scenario(institution=I,target="yield",value=0.1,color=:black;N,p);show_realized)
        phaseplot!(TQyield,scenario(institution=I,target="yield",value=0.1,color=low;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(TQyield,scenario(institution=I,target="yield",value=0.2,color=medium;N,p);show_realized, show_potential=false, show_required=false)
        phaseplot!(TQyield,scenario(institution=I,target="yield",value=0.3,color=high;N,p);show_realized, show_potential=false, show_required=false)

        attractor_size=10
        magma=ColorSchemes.viridis
        me=2.0
        y=[sim(scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=v)).y for v in range(0.0,stop=1.0,length=100)]
        U=[sim(scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=v)).U for v in range(0.0,stop=1.0,length=100)]
        lines!(protectedArea,y,U,color=:black)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.1,color=get(magma, 0.1)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.2,color=get(magma, 0.2)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.3,color=get(magma, 0.3)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.4,color=get(magma, 0.4)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.5,color=get(magma, 0.5)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.6,color=get(magma, 0.6)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.7,color=get(magma, 0.7)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.8,color=get(magma, 0.8)), show_target=false;attractor_size)
        phaseplot!(protectedArea,scenario(ē=SED(mean=me,sigma=0.0),institution="PA",target="yield",value=0.9,color=get(magma, 0.9)), show_target=false;attractor_size)

        
        phaseplot!(price,scenario(p=0.5/p, color=:black;N);show_realized)
        phaseplot!(price,scenario(p=0.5/p,color=low;N);show_realized, show_potential=true, show_required=false)
        phaseplot!(price,scenario(p=1.0/p,color=medium;N);show_realized, show_potential=true, show_required=false)
        phaseplot!(price,scenario(p=2.0/p,color=high;N);show_realized, show_potential=true, show_required=false)

        #phaseplot!(effort,scenario(q=SED(mean=0.5,sigma=0.0,normalize=true), color=:black);show_realized)
        phaseplot!(effort,scenario(q=SED(mean=0.5,sigma=0.0,normalize=true),color=low;N,p);show_realized)
        phaseplot!(effort,scenario(q=SED(mean=1.0,sigma=0.0,normalize=true),color=medium;N,p);show_realized)
        phaseplot!(effort,scenario(q=SED(mean=2.0,sigma=0.0,normalize=true),color=high;N,p);show_realized)
        
#        phaseplot!(numactors1,scenario(color=:gray,N=1;p))
#        phaseplot!(numactors2,scenario(color=:gray,N=10;p))
#        phaseplot!(numactors3,scenario(color=:gray,N=100;p))
#        phaseplot!(numactors1,scenario(color=:steelblue,N=1;p);show_realized, show_potential=false, show_required=false)
#        phaseplot!(numactors2,scenario(color=:steelblue,N=10;p);show_realized, show_potential=false, show_required=false)
#        phaseplot!(numactors3,scenario(color=:steelblue,N=100;p);show_realized, show_potential=false, show_required=false)
        
        save("graphics/institutions.png",f)
        #lines!(test,[0,200],[0,200],color=:gray)
        Label(f[0,1:2], "Actor restrictions",fontsize=26,color=:black)
        Label(f[0,3:4], "Changing Incentives",fontsize=26,color=:black)
        text!(test,0.1,0.9,text="Test label inside",space = :relative)
        f
    end

function figure6(s::Scenario;M=100,size=750,institutions=[("Open","access"),("Protected","area"),("Permits","for low w̃"),("Permits","for high w̃"),("Shared","effort"),("Shared","yield"),("Tradable","effort"),("Tradable","yield")], saveas="",colorscheme=ColorSchemes.tab10)
    ms=3
    f=Figure(size=(size,size*4/3))
    imageplot=Axis(f[0,1])
    corrplot=f[2,1]=GridLayout()
    phaseplot=Axis(f[3,1], backgroundcolor=:lightgray )
    insttotal=Axis(f[1,2])
    instresource=Axis(f[2,2])
    instgini=Axis(f[3,2])
    open=Axis(f[0,3])
    total=Axis(f[1,3])
    resource=Axis(f[2,3])
    gini=Axis(f[3,3])
    LS=[]

    img = load("graphics/"*s.image)
    hidespines!(imageplot)

    for plot in [imageplot,phaseplot,insttotal,insttotal,instresource,instgini,open,total,resource,gini]
        hidedecorations!(plot)
    end
    
    image!(imageplot, rotr90(img))

    V=Dict()
    V[1,1]=(:id,:p)
    V[2,1]=(:id,:ē)
    V[3,1]=(:id,:a)
    V[1,2]=(:id,:w)
    V[2,2]=(:id,:q)
    V[3,2]=(:w̃,cumsum)
    V[1,3]=(:id,:w̃)
    V[2,3]=(:id,:ū)
    V[3,3]=(:w̃,:ū)

    function setBG(v)
        if v[1]==:ū || v[1]==:w̃ || v[2]==:ū || v[2]==:w̃
            return :lightgray
        else
            return :white
        end
        
    end

    A=Dict()
    [A[i]=Axis(corrplot[i...], backgroundcolor=setBG(V[i])) for i in keys(V)]

 

    [SEDplot!(A[i], s, V[i][1], V[i][2],markersize=ms) for i in keys(V)]
    [V[i][2]!=cumsum ? text!(A[i],0.05,0.75,text=string(V[i][2]),space=:relative, color=:black) : nothing for i in keys(V)]
    [V[i][1]!=:id ? text!(A[i],0.75,0.01,text=string(V[i][1]),space=:relative, color=:black) : nothing for i in keys(V)]

    
    [hidespines!(A[i,j]) for i in 1:3, j in 1:3]
    [hidedecorations!(A[i,j]) for i in 1:3, j in 1:3]
    rowgap!(corrplot, 1)
    colgap!(corrplot, 1)

    phaseplot!(phaseplot,s,show_trajectory=true)


    de=0
    d=0
    T=0
    TI=()
    R=0
    RI=()
    G=100000000
    GI=()
    LS=[]
    
    for (j,inst) in enumerate(institutions)
        
        s.institution=inst[1]
        s.target=inst[2]
        de=get_best_target(s;M)
        l=lines!(insttotal,de.target,de.total,  color=colorscheme[j])
        lines!(instresource,de.target,de.resource,  color=colorscheme[j])
        lines!(instgini,de.target,de.gini,  color=colorscheme[j])
        push!(LS,PolyElement(color = colorscheme[j], strokecolor = :transparent))

        if maximum(de.total)>T
            T=maximum(de.total)
            TI=(inst[1],inst[2],de.target[argmax(de.total)],j)
        end


        if maximum(de.resource)>R 
            R=maximum(de.resource)
            RI=(inst[1],inst[2],de.target[argmax(de.resource)],j)
        end

        if minimum(de.gini)<G
            G=minimum(de.gini)
            GI=(inst[1],inst[2],de.target[argmin(de.gini)],j)
        end

    end
    scatter!(insttotal,[TI[3]],[T],  color=colorscheme[TI[4]],markersize=15)
    scatter!(instresource,[RI[3]],[R],  color=colorscheme[RI[4]],markersize=15)
    scatter!(instgini,[GI[3]],[G],  color=colorscheme[GI[4]],markersize=15)
    scatter!(insttotal,[1],[de.total[end]],  color=colorscheme[1],markersize=15)
    scatter!(instresource,[1],[de.resource[end]],  color=colorscheme[1],markersize=15)
    scatter!(instgini,[1],[de.gini[end]],  color=colorscheme[1],markersize=15)
    
    
    s.institution="Open"
    s.target="access"
    s.color=convert(HSL,colorscheme[1])
    sim(s)
    incomes!(open,s,anntext="Open Access",annotation_size=10)

    s.institution=TI[1]
    s.target=TI[2]
    s.value=TI[3]
    s.color=convert(HSL,colorscheme[TI[4]])
    sim(s)
    incomes!(total,s,anntext=TI[1]*" "*TI[2]*" @ "*string(round(TI[3],digits=2)),annotation_size=10)


    s.institution=RI[1]
    s.target=RI[2]
    s.value=RI[3]
    s.color=convert(HSL,colorscheme[RI[4]])
    sim(s)
    incomes!(resource,s,anntext=RI[1]*" "*RI[2]*" @ "*string(round(RI[3],digits=2)),annotation_size=10)


    s.institution=GI[1]
    s.target=GI[2]
    s.value=GI[3]
    s.color=convert(HSL,colorscheme[GI[4]])
    sim(s)
    incomes!(gini,s,anntext=GI[1]*" "*GI[2]*" @ "*string(round(GI[3],digits=2)),annotation_size=10)
    linkaxes!([total,resource,gini]...) 

    LI=[inst[1]*" "*inst[2] for inst in institutions][:]
    Legend(f[0,2],LS,LI,nbanks=1,orientation=:vertical,title="Institutions",framevisible = false,backgroundcolor=:lightgray, tellwidth=false)
     
     saveas=="" ? nothing : save("graphics/"*saveas,f)
    f
end


function figure6a(S::Array{Scenario};size=120,institutions=[("Open","access"),("Protected","area"),("Permits","for low w̃"),("Permits","for high w̃"),("Shared","effort"),("Shared","yield"),("Tradable","effort"),("Tradable","yield")],M=100,saveas="Figure6.png", icons=true,showimages=true,resource_revenues=true,covariations=true, ms=2)
    
    width=length(S)*size+50
    caseheight=size+ (showimages ? size : 0) + (covariations ? size : 0)
    institutionsheight=240*0.75+(resource_revenues ? size*0.75 : 0)
    outcomesheight=3*size*0.75+(resource_revenues ? size*0.75 : 0)
    legendheight=size*0.5
    height=caseheight+institutionsheight+outcomesheight+legendheight
    icon_size=30
    f=Figure(;size=(width,height*1.3))
    cases=f[1,1]=GridLayout(height=caseheight)
    institutions_plots=f[2,1]=GridLayout(height=institutionsheight )
    outcomes=f[4,1]=GridLayout(height=outcomesheight )
    total=[]
    resource=[]
    gini=[]
    LS=[]
    #Label(cases[1,0], "Covariances",fontsize=16)
    for (i,s) in enumerate(S)
        
        if showimages
            img = load("graphics/"*s.image)
            s.color=convert(HSL,ColorSchemes.tab10[1])
            imageplot=Axis(cases[1, i], title=s.caption, ylabel="Scenarios")
            hidespines!(imageplot)
            hidexdecorations!(imageplot)
            hideydecorations!(imageplot, label = i==1 ? false : true)
            s.image!="" ? image!(imageplot, rotr90(img)) : nothing
        end

        

        
        if covariations
            tempA=Axis(cases[1+(showimages ? 1 : 0),i])
            i==1 ? tempA.ylabel="Covariation imprint" : nothing
            hidespines!(tempA)
            hideydecorations!(tempA,label=false)
            hidexdecorations!(tempA)
            corrplot=cases[1+(showimages ? 1 : 0),i]=GridLayout()#Axis(cases[1,i])
            colgap!(corrplot, 1)
            rowgap!(corrplot, 1)
            cp=Axis(corrplot[1,1])
            cē=Axis(corrplot[2,1])
            cq=Axis(corrplot[1,2])
            cw=Axis(corrplot[2,2])
            cū=Axis(corrplot[1,3], backgroundcolor=:lightgray)
            cw̃=Axis(corrplot[2,3], backgroundcolor=:lightgray)
            
            # Hide spines and decorations
            for ax in [cp, cē, cq, cw, cū, cw̃]
                hidespines!(ax)
                hidedecorations!(ax)
            end

            # Adjust gaps after all axes are in place
            colgap!(corrplot, 1)
            rowgap!(corrplot, 1)



            scatter!(cp,s.p,markersize=ms)
            scatter!(cē,s.ē,markersize=ms)
            scatter!(cq,s.q,markersize=ms)
            scatter!(cw,s.w,markersize=ms)
            scatter!(cū,s.ū,markersize=ms)
            scatter!(cw̃,s.w̃,markersize=ms)
            
            if icons
                y_icon = load("graphics/p.png")
                scatter!(cp, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)
                y_icon = load("graphics/ē.png")
                scatter!(cē, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)
                y_icon = load("graphics/q.png")
                scatter!(cq, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)
                y_icon = load("graphics/w.png")
                scatter!(cw, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)  
                y_icon = load("graphics/ū.png")
                scatter!(cū, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)
                y_icon = load("graphics/w̃.png")
                scatter!(cw̃, 0.2, 0.85, marker=y_icon, markersize=icon_size, space=:relative)
            end
            
            if icons==false
                text!(cp,0.1,0.7,text="p",space=:relative, color=:black)
                text!(cē,0.1,0.7,text="ē",space=:relative, color=:black)
                text!(cq,0.1,0.7,text="q",space=:relative, color=:black)
                text!(cw,0.1,0.7,text="w",space=:relative, color=:black)
                text!(cū,0.1,0.7,text="ū",space=:relative, color=:black)
                text!(cw̃,0.1,0.7,text="w̃",space=:relative, color=:black)
            end
        end
        phase=Axis(cases[1+(showimages ? 1 : 0) + (covariations ? 1 : 0),i], backgroundcolor=:lightgray, ylabel="System dynamics")     
        hidespines!(phase)     
        hidexdecorations!(phase)
        hideydecorations!(phase, label = i==1 ? false : true)
        phaseplot!(phase,S[i],show_trajectory=true)

        
        push!(total,Axis(institutions_plots[1,i],ylabel="Total",yautolimitmargin=(0.1f0, 0.1f0)))
        hidespines!(total[i])
        hidexdecorations!(total[i],label=false)
        hideydecorations!(total[i],label= i==1 ? false : true)

        
        if resource_revenues
            push!(resource,Axis(institutions_plots[2,i],ylabel="Resource",yautolimitmargin=(0.1f0, 0.1f0)))
            hidespines!(resource[i])
            hidexdecorations!(resource[i],label=false)
            hideydecorations!(resource[i],label=i==1 ? false : true)
        end
        
        push!(gini,Axis(institutions_plots[1+ (resource_revenues ? 2 : 1),i],ylabel="Gini",xlabel="Restriction",xticks = (0:1, ["1", "0"]),yautolimitmargin=(0.1f0, 0.1f0)))
        hidespines!(gini[i])      
        hidexdecorations!(gini[i],label=false,ticks=false,ticklabels=false, grid=true)
        hideydecorations!(gini[i],label=i==1 ? false : true)

        de=0
        d=0
        T=0
        TI=()
        R=0
        RI=()
        G=100000000
        GI=()
        LS=[]
        
        for (j,inst) in enumerate(institutions)
            
            s.institution=inst[1]
            s.target=inst[2]
            de=get_best_target(s;M)
            l=lines!(total[i],de.target,de.total,  color=ColorSchemes.tab10[j])
            resource_revenues ? lines!(resource[i],de.target,de.resource,  color=ColorSchemes.tab10[j]) : nothing
            lines!(gini[i],de.target,de.gini,  color=ColorSchemes.tab10[j])
            push!(LS,PolyElement(color = ColorSchemes.tab10[j], strokecolor = :transparent))

            if maximum(de.total)>T
                T=maximum(de.total)
                TI=(inst[1],inst[2],de.target[argmax(de.total)],j)
            end


            if maximum(de.resource)>R && resource_revenues
                R=maximum(de.resource)
                RI=(inst[1],inst[2],de.target[argmax(de.resource)],j)
            end

            if minimum(de.gini)<G
                G=minimum(de.gini)
                GI=(inst[1],inst[2],de.target[argmin(de.gini)],j)
            end

        end
        scatter!(total[i],[TI[3]],[T],  color=ColorSchemes.tab10[TI[4]],markersize=15)
        resource_revenues ? scatter!(resource[i],[RI[3]],[R],  color=ColorSchemes.tab10[RI[4]],markersize=15) : nothing
        scatter!(gini[i],[GI[3]],[G],  color=ColorSchemes.tab10[GI[4]],markersize=15)
        
        
        Iopen=Axis(outcomes[ 1,i],ylabel="Access")#, ylabelsize=12)#, title="Open Access")
        
        Itotal=Axis(outcomes[ 2,i],ylabel="Total")#, ylabelsize=12)#, title=TI[1]*" "*TI[2]*" "*string(round(TI[3],digits=2)))
        if resource_revenues 
            Iresource=Axis(outcomes[3,i], ylabel="Resource") 
            
        end
        Igini=Axis(outcomes[2 + (resource_revenues ? 2 : 1),i],ylabel="Gini")#, ylabelsize=12)#, title=GI[1]*" "*GI[2]*" "*string(round(GI[3],digits=2)))
        #ylims!(Iopen,0.0,0.015)
        #ylims!(Itotal,0.0,0.015)
        #ylims!(Iresource,0.0,0.015)
        #ylims!(Igini,0.0,0.015)

        hidespines!(Iopen)
        hidespines!(Itotal)
        hidespines!(Igini)

        hidexdecorations!(Iopen)
        hidexdecorations!(Itotal)
        hidexdecorations!(Igini)

        hideydecorations!(Iopen,label=i==1 ? false : true)
        hideydecorations!(Itotal,label=i==1 ? false : true)
        hideydecorations!(Igini,label=i==1 ? false : true)

        if resource_revenues
            hidespines!(Iresource)
            hidexdecorations!(Iresource)
            hideydecorations!(Iresource,label=i==1 ? false : true)
        end

        s.institution="Open"
        s.target="access"
        s.color=convert(HSL,ColorSchemes.tab10[1])
        sim(s)
        incomes!(Iopen,s,anntext="Open Access",annotation_size=10)

        s.institution=TI[1]
        s.target=TI[2]
        s.value=TI[3]
        s.color=convert(HSL,ColorSchemes.tab10[TI[4]])
        sim(s)
        incomes!(Itotal,s,anntext=TI[1]*" "*TI[2]*" @ "*string(round(TI[3],digits=2)),annotation_size=10)

        if resource_revenues
            s.institution=RI[1]
            s.target=RI[2]
            s.value=RI[3]
            s.color=convert(HSL,ColorSchemes.tab10[RI[4]])
            sim(s)
            incomes!(Iresource,s,anntext=RI[1]*" "*RI[2]*" @ "*string(round(RI[3],digits=2)),annotation_size=10)
        end
        s.institution=GI[1]
        s.target=GI[2]
        s.value=GI[3]
        s.color=convert(HSL,ColorSchemes.tab10[GI[4]])
        sim(s)
        incomes!(Igini,s,anntext=GI[1]*" "*GI[2]*" @ "*string(round(GI[3],digits=2)),annotation_size=10)
        resource_revenues ? linkaxes!([Iopen,Itotal,Iresource,Igini]...) : linkaxes!([Iopen,Itotal,Igini]...)
    end
    #b=cases[0:2,0]=GridLayout(f[1, 1], tellwidth = false, tellwidth = false, halign = :right, valign = :bottom)
    #Box(b, color = "#eeeeee", strokecolor = :transparent)
    Label(cases[1:(1+(showimages ? 1 : 0) + (covariations ? 1 : 0)),0], "Scenarios",fontsize=20,color=:gray, rotation=pi/2)
    #Box(institutions_plots[1:3,0], color = "#eeeeee", strokecolor = :transparent)
    Label(institutions_plots[1:(resource_revenues ? 3 : 2),0], "Institutional effects ⇦",fontsize=20,color=:gray, rotation=pi/2)
    #Box(outcomes[1:4,0], color = "#eeeeee", strokecolor = :transparent)
    Label(outcomes[1:(resource_revenues ? 4 : 3),0], "Best Outcomes ⇦",fontsize=20,color=:gray, rotation=pi/2)
    LI=[inst[1]*" "*inst[2] for inst in institutions][:]
   # LS=[LS[1:5],LS[6:8]]
   # LI=[LI[1:5],LI[6:8]]
    Legend(f[3,1],LS,LI,nbanks=2,orientation=:horizontal, height=legendheight,title="Institutions",framevisible = false,backgroundcolor=:lightgray)
    saveas=="" ? nothing : save("graphics/"*saveas,f)
    f
end


function getBestInst(s,institutions;M=100)
    T=0
    TI=[]
    R=0
    RI=[]
    G=100000000
    GI=[]
    AT=[]
    AR=[]
    AG=[]
    YT=[]
    YR=[]
    YG=[]
    for (j,inst) in enumerate(institutions)
        
        s.institution=inst[1]
        s.target=inst[2]
        de=get_best_target(s;M)
        push!(AT,de.total)
        push!(AR,de.resource)
        push!(AG,de.gini)
            T=round(maximum(de.total),digits=4)
            push!(TI,(inst[1],inst[2],de.target[argmax(de.total)],j,T))
            YT=de.y[argmax(de.total)]

            R=round(maximum(de.resource),digits=4)
            push!(RI,(inst[1],inst[2],de.target[argmax(de.resource)],j,R))
            YR=de.y[argmax(de.resource)]

            G=round(minimum(de.gini),digits=4)
            push!(GI,(inst[1],inst[2],de.target[argmin(de.gini)],j,G))
            YG=de.y[argmin(de.gini)]
    end

    return (;TI,RI,GI,T,R,G,AT,AR,AG,institutions,YT,YR,YG)
end



##### We could save the rank of each institution at each position
# and then we can extract all first ranks (and best target) for full figure
function institutionalExploration(;show_fig=true,cov=0,M=5,Q=100, institutions=[("OA","effort"),("PLL","effort"),("PHL","effort"),("EC","effort"),("EC","yield"),("TQ","effort"),("TQ","yield")])
    

    OAT=zeros(M,M)
    OAR=zeros(M,M)
    OAG=zeros(M,M)
    IT=zeros(M,M)
    IR=zeros(M,M)
    IG=zeros(M,M)
    BT=zeros(M,M)
    BR=zeros(M,M)
    BG=zeros(M,M)
    Tv=zeros(M,M)
    Rv=zeros(M,M)
    Gv=zeros(M,M)
    YT=zeros(M,M)
    YR=zeros(M,M)
    YG=zeros(M,M)
    W=zeros(M,M)
    U=zeros(M,M)
    for (i,w̃) in enumerate(range(0.0+0.5/M,stop=1.5-0.5/M,length=M))
        for (j,ū) in enumerate(range(0.0+0.5/M,stop=2.0-0.5/M,length=M))
            L=[]
            s=scenario(;w̃=SED(min=0.0,max=w̃),ū=SED(mean=ū,sigma=ū.*0.99*cov, normalize=true))
            OAT[i,j]=sum(sim(s).total_revenue)
            OAR[i,j]=sum(sim(s).resource_revenue)
            OAG[i,j]=sim(s).gini
            b=getBestInst(s,institutions,M=Q)
            TI=selectBestInst(b.TI,max=true)
            RI=selectBestInst(b.RI,max=true)
            GI=selectBestInst(b.GI,max=false)
            IT[i,j]=TI[1]
            IR[i,j]=RI[1]
            IG[i,j]=GI[1]
            BT[i,j]=b.T
            BR[i,j]=b.R
            BG[i,j]=b.G
            Tv[i,j]=b.TI[TI[1]][3]
            Rv[i,j]=b.RI[RI[1]][3]
            Gv[i,j]=b.GI[GI[1]][3]
            YT[i,j]=b.YT
            YR[i,j]=b.YR
            YG[i,j]=b.YG
            W[i,j]=w̃
            U[i,j]=ū
            if show_fig 
                f=Figure() 
                a=Axis(f[1,1])
                bb=Axis(f[1,2],title="total")
                c=Axis(f[2,1],title="resource")
                d=Axis(f[2,2],title="gini")
                phaseplot!(a,s)
                for (i,t) in enumerate(b.AG)
                    l=lines!(bb,b.AT[i])
                    lines!(c,b.AR[i])
                    lines!(d,b.AG[i])
                    push!(L,l)
                end
                Legend(f[1:2,3],L,[n[1]*" "*n[2] for n in institutions])
                display(f)
            end

            println(i,j)
        end
    end
    w̃=range(0.0+1/M,stop=1.0-1/M,length=M)
    ū=range(0.0+1/M,stop=1.0-1/M,length=M)
    return (;OAT,OAR,OAG,IT,IR,IG,BT,BR,BG,Tv,Rv,Gv,w̃,ū,YT,YR,YG,institutions,W,U)
end

function selectBestInst(x;max=true)
    m=max ? maximum([y[5] for y in x]) : minimum([y[5] for y in x])
    f=findall([y[5] for y in x].==m)
    if 1 in f  # BUT if OA is not at index 1!!!!!
         return 1
    else
       if length(f)>1
            return f
        else
            return f[1]
        end
    end
end

function figureHeatplots(b)
    institutions=[("OA","effort"),("PLL","effort"),("PHL","effort"),("EC","effort"),("EC","yield"),("TQ","effort"),("TQ","yield")]
    f=Figure(size=(900,1200))
    OAT,OAR,OAG,IT,IR,IG,BT,BR,BG,Tv,Rv,Gv=b
    w̃=range(0.0+1/size(OAT,1),stop=1.0-1/size(OAT,1),length=size(OAT,1))
    ū=range(0.0+1/size(OAT,2),stop=1.0-1/size(OAT,2),length=size(OAT,2))
    cmap=Symbol("Set1_"*string(length(institutions)))
   # (OAT,OAR,OAG,IT,IR,IG,BT,BR,BG,Tv,Rv,Gv,w̃,ū)=b
    aOAT=Axis(f[1,1],aspect=1, title="OAT")
    aOAR=Axis(f[1,2],aspect=1,title="OAR")
    aOAG=Axis(f[1,3],aspect=1,title="OAG")
    aIT=Axis(f[2,1],aspect=1,title="IT")
    aIR=Axis(f[2,2],aspect=1,title="IR")
    aIG=Axis(f[2,3],aspect=1,title="IG")
    aBT=Axis(f[3,1],aspect=1,title="BT")
    aBR=Axis(f[3,2],aspect=1,title="BR")
    aBG=Axis(f[3,3],aspect=1,title="BG")
    aTv=Axis(f[4,1],aspect=1,title="Tv")
    aRv=Axis(f[4,2],aspect=1,title="Rv")
    aGv=Axis(f[4,3],aspect=1,title="Gv")
    #=hidespines!(aOAT)
    hidespines!(aOAR)
    hidespines!(aOAG)
    hidespines!(aIT)
    hidespines!(aIR)
    hidespines!(aIG)
    hidespines!(aBT)
    hidespines!(aBR)
    hidespines!(aBG)
    hidespines!(aTv)
    hidespines!(aRv)
    hidespines!(aGv)
    hidedecorations!(aOAT,grid=false)
    hidedecorations!(aOAR,grid=false)
    hidedecorations!(aOAG,grid=false)
    hidedecorations!(aIT,grid=false)
    hidedecorations!(aIR,grid=false)
    hidedecorations!(aIG,grid=false)
    hidedecorations!(aBT,grid=false)
    hidedecorations!(aBR,grid=false)
    hidedecorations!(aBG,grid=false)
    hidedecorations!(aTv,grid=false)
    hidedecorations!(aRv,grid=false)
    hidedecorations!(aGv,grid=false)=#
    heatmap!(aOAT,w̃,ū,OAT',show_axis=false)
    heatmap!(aOAR,w̃,ū,OAR',show_axis=false)
    heatmap!(aOAG,w̃,ū,OAG',show_axis=false)
    heatmap!(aIT,w̃,ū,IT',show_axis=false,colormap=cmap,colorrange=(0,7))
    heatmap!(aIR,w̃,ū,IR',show_axis=false,colormap=cmap,colorrange=(0,7))
    heatmap!(aIG,w̃,ū,IG',show_axis=false,colormap=cmap,colorrange=(0,7))
    heatmap!(aBT,w̃,ū,BT'.-OAT',show_axis=false)
    heatmap!(aBR,w̃,ū,BR'.-OAR',show_axis=false)
    heatmap!(aBG,w̃,ū,OAG'.-BG',show_axis=false)
    heatmap!(aTv,w̃,ū,Tv',show_axis=false)
    heatmap!(aRv,w̃,ū,Rv',show_axis=false)
    heatmap!(aGv,w̃,ū,Gv',show_axis=false)
f
end


SA()=[scenario(q=SED(mean=2.0,sigma=1.9,normalize=true),image="case1.png",label="High effort \n low opportunities",color=convert(HSL,ColorSchemes.tab10[1])),
#scenario(q=SED(mean=2.0,sigma=0.0,normalize=true)),
scenario(q=SED(mean=2.0,sigma=-1.9,normalize=true),image="case2.png",label="High effort \n low opportunities",color=convert(HSL,ColorSchemes.tab10[1])),
scenario(q=SED(mean=0.8,sigma=0.79,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true),image="case3.png",label="High effort \n low opportunities",color=convert(HSL,ColorSchemes.tab10[1])),
#scenario(q=SED(mean=0.8,sigma=0.0,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true)),
scenario(q=SED(mean=0.8,sigma=-0.79,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true),image="case4.png",label="High effort \n low opportunities",color=convert(HSL,ColorSchemes.tab10[1]))
]

SB()=[scenario(q=SED(mean=2.0,sigma=1.9,normalize=true,rand=true),image="case1.png",caption="Mediterranean\n coastal town",color=convert(HSL,ColorSchemes.tab10[1])),
#scenario(q=SED(mean=2.0,sigma=0.0,normalize=true)),
scenario(q=SED(mean=2.0,sigma=-1.9,normalize=true),image="case2.png",caption="High latitude \n western town",color=convert(HSL,ColorSchemes.tab10[1])),
scenario(q=SED(mean=0.8,sigma=0.0,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true, rand=true, distribution=LogNormal),image="case3.png",caption="Latin american \n coastal town",color=convert(HSL,ColorSchemes.tab10[1])),
#scenario(q=SED(mean=0.8,sigma=0.0,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true)),
scenario(q=SED(mean=0.8,sigma=-0.79,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true),image="case4.png",caption="East european \n village",color=convert(HSL,ColorSchemes.tab10[1])),
scenario(q=SED(mean=0.8,sigma=-0.4,normalize=true),w=SED(mean=0.09,sigma=0.089,normalize=true, distribution=LogNormal),image="case5.png",caption="Southeast asian \n fishing community",color=convert(HSL,ColorSchemes.tab10[1]))
]

SC()=[scenario(q=SED(mean=2.0,sigma=1.9,normalize=true,rand=true),image="case1.png",caption="Mediterranean\n coastal town",color=convert(HSL,ColorSchemes.tab10[1])),
#scenario(q=SED(mean=2.0,sigma=0.0,normalize=true)),
scenario(q=SED(mean=2.0,sigma=-1.9,normalize=true),image="case2.png",caption="High latitude \n western town",color=convert(HSL,ColorSchemes.tab10[1]))]

function test(b)
    f=Figure(size=(800,900))
    (OAT,OAR,OAG,IT,IR,IG,BT,BR,BG,Tv,Rv,Gv,w̃,ū)=b
    aOAT=Axis(f[1,1],aspect=1)
    aIT=Axis(f[2,1],aspect=1)
    aBT=Axis(f[3,1],aspect=1)
    aTv=Axis(f[4,1],aspect=1)
    aGv=Axis(f[5,1],aspect=1)
    heatmap!(aOAT,w̃,ū,OAT,show_axis=false)
    heatmap!(aIT,w̃,ū,IT,show_axis=false)
    heatmap!(aBT,w̃,ũ,BT,show_axis=false)
    heatmap!(aTv,w̃,ũ,Tv,show_axis=false)
    heatmap!(aGv,w̃,ũ,Gv,show_axis=false)
end

#=
h5open(homedir()*"/Documents/heatmaps.h5", "w") do file
    # Save each field of the named tuple separately
    for name in keys(test)
        println(name)
        if test[name] isa AbstractRange
            file[String(name)] = collect(test[name]) # Convert range to array before saving
        else 
        file[String(name)] = test[name]
        end
    end
end


w̃=0.2
ū=0.8
W=range(0.0+1/M,stop=1.0-1/M,length=M)
U=range(0.0+1/M,stop=1.0-1/M,length=M)
i=1
j=1
s=scenario(;w̃=SED(mean=W[i],sigma=W[i]*0.99),ū=SED(mean=U[j],sigma=0.0, normalize=true))
i=getBestInst(s,institutions,M=100)
f=Figure()
a=Axis(f[1,1])
#ylims!(a,(0.2359,0.241))
L=[]
for t in i.AG
    l=lines!(a,t)
    push!(L,l)
    println(minimum(t))
end
Legend(f[1,2],L,[n[1]*" "*n[2] for n in institutions])
f
=#




function sed(;N1=20,N2=200,w_dist=LogNormal,ms=1)
    f=Figure()
    low_N_distributions=f[1,1]=GridLayout()
    high_N_distributions=f[2,1]=GridLayout()
    low_N_phaseplot=Axis(f[1,2])
    high_N_phaseplot=Axis(f[2,2])

    s1=scenario(w̃=SED(min=0.1,max=0.6,distribution=w_dist, random=true),ū=SED(mean=0.8,sigma=0.0,normalize=true,random=true),N=N1,color=:black)
    s2=scenario(w̃=SED(min=0.1,max=0.6,distribution=w_dist),ū=SED(mean=0.8,sigma=0.0,normalize=true),N=N1)
    s3=scenario(w̃=SED(min=0.1,max=0.6,distribution=w_dist, random=true),ū=SED(mean=0.8,sigma=0.0,normalize=true,random=true),N=N2,color=:black)
    s4=scenario(w̃=SED(min=0.1,max=0.6,distribution=w_dist),ū=SED(mean=0.8,sigma=0.0,normalize=true),N=N2)


    V=Dict()
    V[1,1]=(:id,:p)
    V[2,1]=(:id,:ē)
    V[3,1]=(:id,:a)
    V[1,2]=(:id,:w)
    V[2,2]=(:id,:q)
    V[3,2]=(:w̃,cumsum)
    V[1,3]=(:id,:w̃)
    V[2,3]=(:id,:ū)
    V[3,3]=(:w̃,:ū)

    function setBG(v)
        if v[1]==:ū || v[1]==:w̃ || v[2]==:ū || v[2]==:w̃
            return :lightgray
        else
            return :white
        end
        
    end

    A=Dict()
    [A[i]=Axis(low_N_distributions[i...], backgroundcolor=setBG(V[i])) for i in keys(V)]
    B=Dict()
    [B[i]=Axis(high_N_distributions[i...], backgroundcolor=setBG(V[i])) for i in keys(V)]

 

    [SEDplot!(A[i], s1, V[i][1], V[i][2],markersize=ms) for i in keys(V)]
    [SEDplot!(A[i], s2, V[i][1], V[i][2],markersize=ms) for i in keys(V)]
    [SEDplot!(B[i], s3, V[i][1], V[i][2],markersize=ms) for i in keys(V)]
    [SEDplot!(B[i], s4, V[i][1], V[i][2],markersize=ms) for i in keys(V)]
    [V[i][2]!=cumsum ? text!(A[i],0.05,0.75,text=string(V[i][2]),space=:relative, color=:black) : text!(A[i],0.05,0.75,text="cdf",space=:relative, color=:black) for i in keys(V)]
    [V[i][1]!=:id ? text!(A[i],0.75,0.01,text=string(V[i][1]),space=:relative, color=:black) : nothing for i in keys(V)]
    [V[i][2]!=cumsum ? text!(B[i],0.05,0.75,text=string(V[i][2]),space=:relative, color=:black) : text!(B[i],0.05,0.75,text="cdf",space=:relative, color=:black) for i in keys(V)]
    [V[i][1]!=:id ? text!(B[i],0.75,0.01,text=string(V[i][1]),space=:relative, color=:black) : nothing for i in keys(V)]

    
    [hidespines!(A[i,j]) for i in 1:3, j in 1:3]
    [hidedecorations!(A[i,j]) for i in 1:3, j in 1:3]
    rowgap!(low_N_distributions, 1)
    colgap!(low_N_distributions, 1)    
    [hidespines!(B[i,j]) for i in 1:3, j in 1:3]
    [hidedecorations!(B[i,j]) for i in 1:3, j in 1:3]
    rowgap!(high_N_distributions, 1)
    colgap!(high_N_distributions, 1)




    phaseplot!(low_N_phaseplot,s1,show_realized=false, show_attractor=false)
    phaseplot!(low_N_phaseplot,s2,show_realized=false, show_attractor=false,show_vertical_potential=true)
    phaseplot!(high_N_phaseplot,s3,show_realized=false, show_attractor=false)
    phaseplot!(high_N_phaseplot,s4,show_realized=false, show_attractor=false,show_vertical_potential=true)

    display(f)
end

function arrow_arc!(ax, origin, radius, start_angle, stop_angle; linewidth=1, color=:black,flip_arrow=false,linestyle=:dot)
    # Draw the arc
    arc!(ax, origin, radius, start_angle, stop_angle, linewidth=linewidth, color=color;linestyle)

    # Function to calculate a point on the circle
    point_on_circle(θ) = origin .+ radius * Point2f(cos(θ), sin(θ))

    # Calculate the direction of the arrow at the start and end of the arc
    start_dir = Point2f(cos(start_angle + π/2 + (flip_arrow ? pi/2 : 0)), sin(start_angle + π/2+ (flip_arrow ? pi/2 : 0)))
    end_dir = Point2f(cos(stop_angle - π/2 + (flip_arrow ? pi : 0)), sin(stop_angle - π/2+ (flip_arrow ? pi : 0)))
    dx=0.001
    # Add arrow at the start and end of the arc
    # Adjust the multiplier for start_dir and end_dir to control the arrow orientation
    arrows!(ax, [point_on_circle(start_angle)[1]],[point_on_circle(start_angle)[2]], [start_dir[1]]*dx,[start_dir[2]]*dx, color=color, linewidth=linewidth)
    arrows!(ax, [point_on_circle(stop_angle)[1]],[point_on_circle(stop_angle)[2]], [end_dir[1]]*dx,[end_dir[2]]*dx, color=color, linewidth=linewidth)
end

function region_of_control(;N=1000, distribution=LogNormal)
    dc=1.1
    scale=0.7
    f=Figure(size=(1800*scale,1200*scale))
    ax1=Axis(f[1,1])
    ax2=Axis(f[1,2])
    ax3=Axis(f[2,1])
    ax4=Axis(f[2,2])
    ax5=Axis(f[1,3])
    ax6=Axis(f[2,3])
    myscheme = ColorScheme([colorant"forestgreen",colorant"darkorange", colorant"steelblue"],
    "custom", "a name")
    for u in [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.92,1.07,1.26,1.5,1.87,2.5,3.75,8.0]
        s=scenario(w̃=SED(mean=0.3,sigma=0.0),    ū=SED(mean=u,sigma=0.0, normalize=true), color=u<0.8 ? :forestgreen : :steelblue;N)
        du=scenario(w̃=SED(mean=0.3,sigma=0.0),    ū=SED(mean=u*dc,sigma=0.0, normalize=true), color=u<0.8 ? :forestgreen : :steelblue;N)
        dw=scenario(w̃=SED(mean=0.3*dc,sigma=0.0),    ū=SED(mean=u,sigma=0.0, normalize=true), color=u<0.8 ? :forestgreen : :steelblue;N)
        dwV=(sum(dw.resource_revenue)-sum(s.resource_revenue))/(1-dc)
        duV=(sum(du.resource_revenue)-sum(s.resource_revenue))/(1-dc)
        s.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax1,s,show_realized=false, show_attractor=true,show_vertical_potential=true)
        dwV=(sum(dw.total_revenue)-sum(s.total_revenue))/dc
        duV=(sum(du.total_revenue)-sum(s.total_revenue))/dc
        s.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax3,s,show_realized=false, show_attractor=true,show_vertical_potential=true)
        distribution=Uniform
        sLN=scenario(w̃=SED(mean=0.3,sigma=0.4,distribution=distribution),    ū=SED(mean=u,sigma=0.0, normalize=true);N)
        du=scenario(w̃=SED(mean=0.3,sigma=0.4,distribution=distribution),    ū=SED(mean=u*dc,sigma=0.0, normalize=true);N)
        dw=scenario(w̃=SED(mean=0.3*dc,sigma=0.4,distribution=distribution),    ū=SED(mean=u,sigma=0.0, normalize=true);N)
        dwV=(sum(dw.resource_revenue)-sum(sLN.resource_revenue))/(1-dc)
        duV=(sum(du.resource_revenue)-sum(sLN.resource_revenue))/(1-dc) 
    
        sLN.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax2,sLN,show_realized=false, show_attractor=true,show_vertical_potential=true)
        dwV=(sum(dw.total_revenue)-sum(sLN.total_revenue))/(1-dc)
        duV=(sum(du.total_revenue)-sum(sLN.total_revenue))/(1-dc)
    
        sLN.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax4,sLN,show_realized=false, show_attractor=true,show_vertical_potential=true)
        distribution=LogNormal
        sLN=scenario(w̃=SED(mean=0.3,sigma=0.4,distribution=distribution),    ū=SED(mean=u,sigma=0.0, normalize=true);N)
        du=scenario(w̃=SED(mean=0.3,sigma=0.4,distribution=distribution),    ū=SED(mean=u*dc,sigma=0.0, normalize=true);N)
        dw=scenario(w̃=SED(mean=0.3*dc,sigma=0.4,distribution=distribution),    ū=SED(mean=u,sigma=0.0, normalize=true);N)
        dwV=(sum(dw.resource_revenue)-sum(sLN.resource_revenue))/(1-dc)
        duV=(sum(du.resource_revenue)-sum(sLN.resource_revenue))/(1-dc) 
        
        sLN.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax5,sLN,show_realized=false, show_attractor=true,show_vertical_potential=true)
        dwV=(sum(dw.total_revenue)-sum(sLN.total_revenue))/(1-dc)
        duV=(sum(du.total_revenue)-sum(sLN.total_revenue))/(1-dc)
    
        sLN.color=convert(HSL,get(myscheme,abs(dwV)/(abs(dwV)+abs(duV))))
        phaseplot!(ax6,sLN,show_realized=false, show_attractor=true,show_vertical_potential=true)
   
    end
    arrows!(ax1,[0.3],[0.5],[0.14],[0.0],linewidth=2.0,color=:steelblue)
    arrows!(ax1,[0.3],[0.5],[-0.14],[0.0],linewidth=2.0,color=:steelblue)
    #arrows!(ax1,[0.65],[0.95],[0.34],[0.0],linewidth=2.0,color=:forestgreen)
    #arrows!(ax1,[0.65],[0.95],[-0.34],[0.0],linewidth=2.0,color=:forestgreen)
    arrow_arc!(ax1,Point2f(1, 0),0.9,pi-0.96-0.01,pi/2+0.01,linewidth=2.0,color=:forestgreen)
    text!(ax1,0.47,0.45,text="mean incentive\ncontrols resource", color=:steelblue,fontsize=20)
    text!(ax1,0.60,0.65,text="mean impact\ncontrols resource", color=:forestgreen,fontsize=20,rotation=0.32)
    #text!(ax2,0.37,0.45,text="Mixed control of\nmean incentive and impact", color=:black,fontsize=20)
   
    #text!(ax2,0.37,0.25,text="when does individual u affect \n total revenues?", color=:black,fontsize=20)
    Colorbar(f[1:2, 4],limits = (0, 1), colormap = myscheme,flipaxis = true,ticks=([0,1],["impact","incentive"]))
    Label(f[1,0],text="Resource revenue",fontsize=20, tellheight=false,rotation=pi/2)
    Label(f[2,0],text="Total revenue",fontsize=20,tellheight=false,rotation=pi/2)
    Label(f[0,1],text="No diversity",fontsize=20,tellwidth=false)
    Label(f[0,2],text="Linear distribution",fontsize=20,tellwidth=false)
    Label(f[0,3],text="Realistic distribution",fontsize=20,tellwidth=false)
    Label(f[0,4],text="Control",fontsize=20,tellwidth=false,halign=:left)
    Label(f[3,1:3],text="Resource level",fontsize=20,tellwidth=false)
    save("graphics/region_of_control.png",f)
    f
end

font="Georgia"

function figure3()

	function get_deriv_vector(y,u,z)
		p=z.final.p
		du=zeros(p.N+2)
		usum=cumsum(p.ū)
		Q=findall(usum.<=u)
		n=length(Q)
		deltau=usum[min(p.N,Q[end]+1)]-u
		U=zeros(p.N+2)
		U[Q]=p.ū[Q]
		U[min(p.N,n+1)]=deltau
		U[p.N+1]=y
		dudt(du,U,p,0)
		radian_angle = atan(sum(du[1:p.N]),du[p.N+1])
    	#rad2deg(radian_angle)+180
		#(du[p.N+1],sum(du[1:p.N]))
		radian_angle-pi/2,sqrt(sum(du[1:p.N])^2+du[p.N+1]^2)
	end


	
	N=200
	fig3=Figure(size=(1000,800))
	ax11_fig3=Axis(fig3[1,2], title="Impact potential",yticks = 0:1,titlefont=font)#, titlecolor=:black
	hidexdecorations!(ax11_fig3)
	ax21_fig3=Axis(fig3[2,2], title="covar Impact - Incentive ",yticks = 0:1,titlefont=font)
	hidexdecorations!(ax21_fig3)
	Behavioural_adaptability=Axis(fig3[3,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	ax12_fig3=Axis(fig3[1,1], title="Inequality (slope^-1)",titlefont=font)
	hidexdecorations!(ax12_fig3)
	hideydecorations!(ax12_fig3)
	ax22_fig3=Axis(fig3[2,1], title="Development (position)",titlefont=font)
	hidexdecorations!(ax22_fig3)
	hideydecorations!(ax22_fig3)
	ax32_fig3=Axis(fig3[3,1], title="Development & Inequality",xticks = 0:1,titlefont=font)
	hideydecorations!(ax32_fig3)
	ax13_fig3=Axis(fig3[1,3], title="Phase plane dynamics",yticks = 0:1,xticks = 0:1,titlefont=font)
	ax23_fig3=Axis(fig3[2,3], xscale = identity,title="Individual actors responses",titlefont=font)
	#ax33_fig3=Axis(fig3[3,3],title="Income distribution",titlefont=font)
	
	#hideydecorations!(ax23_fig3)
	ax23_fig3.ylabel="resource use"
	#ax33_fig3=Axis(fig3[3,4], title="ū")



	#Main Phaseplot
    s13=scenario(a=5.5,r=1.0,w=SED(min=0.15,max=0.85,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)
	dist!(s13)
    sim!(s13)#, ē=Linear(1.9,0.1)
	#=
	points = [Point2f(x/11, y/11) for y in 1:10 for x in 1:10]
	rotations = [get_deriv_vector(p[1],p[2],s13)[1] for p in points]
	markersize13 = [(get_deriv_vector(p[1],p[2],s13)[2]*20)^0.2*15 for p in points]

	scatter!(ax13_fig3,points, rotations = rotations, markersize = markersize13, marker = '↑', color=:lightgray)
	=#
	phaseplot!(ax13_fig3,s13,vector_field=false)

	# Individual u's
	testbands=false
	cbarPal = :rainbow2
	cmap = cgrad(colorschemes[cbarPal], s13.N, categorical = true)
    #period=s13.period
	cs=cumsum(s13.u,dims=1)
    for i in 1:s13.N
		if testbands
			band!(ax23_fig3,s13.t[period[2:end]].+1,i==1 ? 0. *cs[i,period[2:end]] :  cs[i-1,period[2:end]],cs[i,period[2:end]], color=cmap[i])
		else
        lines!(ax23_fig3,s13.t.+1,s13.u[i,:], color=cmap[i],linestyle=:dot)#./s13.final.p.ū[i]
		end
    end
	Colorbar(fig3[2,4] , label="Incentive level, w̃", limits = (minimum(s13.w̃), maximum(s13.w̃)), colormap = :rainbow2,halign=:left,tellwidth=true)



	
		#income distribution



	#Base scenario with dynamics
	phaseplot!(ax13_fig3,s13,show_trajectory=true)

	#Increasing inequalsity
	phaseplot!(ax12_fig3,sim(scenario(a=1,w=SED(min=0.5,max=0.5,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)),show_trajectory=false, attractor_size=40,show_required=false,show_attractor=false)
	phaseplot!(ax12_fig3,sim(scenario(w=SED(min=0.33,max=0.75,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false, attractor_size=30,show_required=false,show_attractor=false)
	phaseplot!(ax12_fig3,sim(scenario(w=SED(min=0.15,max=1.69,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false, attractor_size=20,show_required=false,show_attractor=false)
	lines!(ax12_fig3,[0.5,0.5],[0.0,1.0],color=:crimson)
	text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	#Increasing wealth
	phaseplot!(ax22_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplot!(ax22_fig3,sim(scenario(w=SED(min=0.1,max=0.4,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplot!(ax22_fig3,sim(scenario(w=SED(min=0.6,max=0.9,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false,show_required=false,show_attractor=false)
	#text!(ax22_fig3,0.2,0.2,text="increasing wealth",font="Gloria Hallelujah", align=(:left, :top), color=:black)
	#arrows!(ax22_fig3,0.2, 0.1, 0.5, 0)
	#text!(ax22_fig3, 0.5, 0.4, text=L"\tilde{w}=\frac{w}{q p K}", align=(:left, :top), color=:black)

	#Increasing inequality & dev
	phaseplot!(ax32_fig3,sim(scenario(w=SED(min=0.05,max=0.3,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplot!(ax32_fig3,sim(scenario(w=SED(min=0.05,max=0.95,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplot!(ax32_fig3,sim(scenario(w=SED(min=0.05,max=2.25,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false,show_required=false,show_attractor=false)
	text!(ax32_fig3,0.55,0.75,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax32_fig3,0.09,1.07,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:crimson)
	text!(ax32_fig3,0.12,0.04,text="<- low end stuck",font="Gloria Hallelujah", align=(:left, :bottom), color=:gray)

	# Increasing impact potential
	phaseplot!(ax11_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)),show_trajectory=false)
	phaseplot!(ax11_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),ē=SED(min=0.4,max=0.4),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false)
	phaseplot!(ax11_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),ē=SED(min=1.6,max=1.6),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false)
		text!(ax11_fig3,0.55,0.3,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax11_fig3,0.8,0.85,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)
	text!(ax11_fig3,0.56,0.95,text="↑ maximum resource reduction",font="Gloria Hallelujah", align=(:left, :top), color=:gray, fontsize=10)
	text!(ax11_fig3,0.0,0.7,text="<- fraction use that crashes resource",font="Gloria Hallelujah", align=(:left, :top), color=:gray, fontsize=10)

	# bending impact potential
	phaseplot!(ax21_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)),show_trajectory=false)
	phaseplot!(ax21_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),ē=SED(min=0.1,max=1.9),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false)
	phaseplot!(ax21_fig3,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),ē=SED(min=1.9,max=0.1),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false)
	text!(ax21_fig3,0.05,0.4,text="positive",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax21_fig3,0.6,0.8,text="negative",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)

	# Dynamics
	phaseplot!(Behavioural_adaptability,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),a=0.5,color=convert(HSL,colorant"crimson");N)))
	phaseplot!(Behavioural_adaptability,sim(scenario(w=SED(min=0.35,max=0.55,distribution=LogNormal,normalize=true),a=2,color=convert(HSL,colorant"steelblue");N)))
	text!(Behavioural_adaptability,0.8,0.85,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)
	text!(Behavioural_adaptability,0.7,0.65,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:crimson)
	



	fig3
end


function show_diversity(a;N=20,distribution=Uniform)
    s=scenario(a=1,w=SED(min=0.5,max=0.5,normalize=true;distribution),color=convert(HSL,colorant"crimson");N)
    phaseplot!(a,s)
    s=scenario(a=1,w=SED(min=0.3,max=0.7,normalize=true;distribution),color=convert(HSL,colorant"crimson");N)
    phaseplot!(a,s)
    s=scenario(a=1,w=SED(min=0.1,max=0.9,normalize=true;distribution),color=convert(HSL,colorant"crimson");N)
    phaseplot!(a,s)
end

function newFigure3(;distribution=Uniform, title_font="Arial", annotation_font="Gloria Hallelujah",N=100,scale=1.0,vector_grid=20)
    f=Figure(size=(1200*scale,800*scale))
    A=Dict()
    basic_dynamics=Axis(f[1,1],title="System Dynamics",titlefont=title_font)
    individual_dynamics=Axis(f[2,1],title="Behavioural adaptability",titlefont=title_font)
    income_distribution=Axis(f[3,1],title="Impact level, ē",titlefont=title_font)
    test=Axis(f[1,2],title="Individual dynamics",titlefont=title_font)
    A[1,3]=Axis(f[1,3],title="Development & Inequality",titlefont=title_font)
    A[1,4]=Axis(f[1,4],title="Impact potential",titlefont=title_font)
    A[1,5]=Axis(f[1,5],title="covar Impact - Incentive ",titlefont=title_font)

    A[2,2]=Axis(f[2,2],title="Phase plane dynamics",titlefont=title_font)
    A[2,3]=Axis(f[2,3],title="Individual actors responses",titlefont=font)
    A[2,4]=Axis(f[2,4],title="Income distribution",titlefont=title_font)
    A[2,5]=Axis(f[2,5],title="Incentive level, w̃",titlefont=title_font)
    
    A[3,2]=Axis(f[3,2],title="Resource use, ū",titlefont=title_font)
    A[3,3]=Axis(f[3,3],title="Resource level, y",titlefont=title_font)
    A[3,4]=Axis(f[3,4],title="Resource use, u",titlefont=title_font)
    A[3,5]=Axis(f[3,5],title="Resource use, u",titlefont=title_font)

    Ax=[basic_dynamics,individual_dynamics,income_distribution,test]
    [push!(Ax,A[i]) for i in eachindex(A)]
    [hidespines!(Ax[i]) for i in eachindex(Ax)]
    [hidedecorations!(Ax[i]) for i in eachindex(Ax)]

    Label(f[0,1],text="Dynamics",fontsize=20, tellwidth=false)
    Label(f[0,2],text="Incentives",fontsize=20, tellwidth=false)
    Label(f[0,3],text="Impacts",fontsize=20, tellwidth=false)
    Label(f[0,4],text="Actors",fontsize=20, tellwidth=false)
    Label(f[0,5],text="Sensitivity",fontsize=20, tellwidth=false)
    
    #Basic dynamnics
    s=scenario(a=5.5,r=1.0,w=SED(min=0.15,max=0.85,distribution=LogNormal,normalize=true),color=convert(HSL,colorant"crimson");N)
    phaseplot!(basic_dynamics,s,show_trajectory=true, attractor_size=40,show_sustained=true,show_attractor=true,vector_field=true;vector_grid)

    individual_u!(individual_dynamics,s)
    incomes!(income_distribution,s)

    f
end

function actor_density(;distribution=Uniform)
    scale=0.7
    f=Figure(size=(1200*scale,450*scale))
    one_actor=Axis(f[1,1], title="Single actor/No diversity")
    five_actor=Axis(f[1,2],title="Five Actors")
    many_actor=Axis(f[1,3],title="Many Actors")
    one_s=scenario(w̃=SED(mean=0.5,sigma=0.9,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true),N=1)
    five_s=scenario(w̃=SED(mean=0.5,sigma=0.9,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true),N=5)
    many_s=scenario(w̃=SED(mean=0.5,sigma=0.9,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true),N=1000)
    phaseplot!(one_actor,one_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    phaseplot!(five_actor,five_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    phaseplot!(many_actor,many_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    
    [hidespines!(a) for a in [one_actor,five_actor,many_actor]]
    save("graphics/actor_density.png",f)
    f   
end

function potential_realized_sustained(;distribution=Uniform,N=20)
    scale=0.7
    myscheme = ColorScheme([colorant"white",colorant"crimson"],
    "custom", "a name")
    f=Figure(size=(scale*1200,scale*430))
    phase_plot_PS=Axis(f[1:2,1], title="Potential and Sustained")
    phase_plot_RS=Axis(f[1:2,2],title="Realised and Sustained")
    individual=Axis(f[2,3],limits = ((0, 1), nothing),ylabel="time →",xlabel="w̃",title="individual uᵢ over time",xticks=(0:0.5:1,["0","0.5","1"]))
   incomes=Axis(f[1,3],xlabel="actor",ylabel="Income")
    [hidespines!(a) for a in [phase_plot_PS,phase_plot_RS,individual]]
   #income=Axis(f[2,1],xlabel="actor",ylabel="Income")
    #many_actor=Axis(f[1,3])
    phase_s=scenario(w̃=SED(mean=0.5,sigma=0.9,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true);N)
    phaseplot!(phase_plot_PS,phase_s,show_realized=false, show_attractor=true,show_vertical_potential=true,show_legend=:ct)
    phaseplot!(phase_plot_RS,phase_s,show_realized=true,show_potential=false, show_attractor=true,show_vertical_potential=true,show_trajectory=true,show_legend=:rt)
    individual_u!(individual,phase_s,rot=true)
    incomes!(incomes,phase_s)
    Colorbar(f[2,4],ticks=([0,1],["0","ū"]),limits=(0,1),colormap=myscheme,flipaxis=true)
    #incomes!(income,phase_s)
    #phaseplot!(five_actor,five_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    #phaseplot!(many_actor,many_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    save("graphics/potential_realized_sustained.png",f)
    f   
end

function convexities(;distribution=Uniform,N=200)
    scale=0.7
    myscheme = ColorScheme([colorant"white",colorant"crimson"],
    "custom", "a name")
    f=Figure(size=(scale*1200,scale*480))
    phase_plot_PS=Axis(f[1,1])
    phase_plot_RS=Axis(f[1,2])
    [hidespines!(a) for a in [phase_plot_PS,phase_plot_RS,]]
    incomes=f[1,3]=GridLayout()
   
    arrows!(phase_plot_PS,[0.11],[0.2],[0.4],[0.0],linewidth=2.0,color=:black,linestyle=:dot)
    arrows!(phase_plot_PS,[0.62],[0.29],[0.08],[0.11],linewidth=2.0,color=:gray,linestyle=:dot)
    
    phase_s=scenario(w̃=SED(min=0.1,max=0.9,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_PS,phase_s,show_realized=false, show_sustained=false,show_attractor=true,show_vertical_potential=true,attractor_color=:black)
    phase_s.color=convert(HSL,colorant"black")
    phaseplot!(phase_plot_PS,phase_s,show_realized=false, show_sustained=false,show_attractor=true,show_vertical_potential=true,attractor_color=:black)
  
    phase_s=scenario(w̃=SED(min=0.5,max=0.5,distribution=distribution),    ū=SED(mean=1,sigma=0.0, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_PS,phase_s,show_realized=false,show_potential=false,show_sustained=true, show_attractor=true,show_vertical_potential=true,attractor_color=:black)
    phase_s.color=convert(HSL,colorant"black")

    phase_s=scenario(w̃=SED(min=0.5,max=0.5,distribution=distribution),    ū=SED(mean=1,sigma=1.0, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_PS,phase_s,show_realized=false,show_potential=false,show_sustained=true, show_attractor=false,show_vertical_potential=false,attractor_color=:black)
    phase_s.color=convert(HSL,colorant"black")
    phase_s=scenario(w̃=SED(min=0.5,max=0.5,distribution=distribution),    ū=SED(mean=1,sigma=-1.0, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_PS,phase_s,show_realized=false,show_potential=false,show_sustained=true, show_attractor=false,show_vertical_potential=false,attractor_color=:black)
    phase_s.color=convert(HSL,colorant"black")
    #phaseplot!(phase_plot_PS,phase_s,show_realized=false,show_sustained=false, show_attractor=true,show_vertical_potential=true,attractor_color=:crimson)
    arrow_arc!(phase_plot_PS,Point2f(0.5, 0.5),0.4,0+0.21,pi/2-0.21,linewidth=2.0,color=:black,flip_arrow=true,linestyle=:dot)
    arrow_arc!(phase_plot_PS,Point2f(1.0, 0.0),1.1,pi-0.3-0.21,pi/2+0.3+0.21,linewidth=2.0,color=:gray,flip_arrow=true,linestyle=:dot)
    text!(phase_plot_PS,0.37,0.18,text="position:\nmean(w̃)",font="Arial", align=(:left, :top), color=:black, fontsize=10)
    text!(phase_plot_PS,0.68,0.66,text="slope:\nvar(w̃)",font="Arial", align=(:left, :top), color=:black, fontsize=10)
    text!(phase_plot_PS,0.1,0.55,text="tilt\nmean(ū)",font="Arial", align=(:left, :top), color=:gray, fontsize=10)
    text!(phase_plot_PS,0.77,0.45,text="convexity:\nvar(ū)",font="Arial", align=(:left, :top), color=:gray, fontsize=10)
    #=

    W=[SED(min=0.01,max=0.99,distribution=LogNormal),SED(min=5,max=1,distribution=Beta)]
    U=[SED(mean=0.5,distribution=Exponential, normalize=true),SED(min=5,max=1,distribution=LogNormal,normalize=true)]
    
    [phaseplot!(phase_plot_RS,scenario(w̃=w,ū=u;N),show_realized=false,show_potential=true, show_attractor=true,show_vertical_potential=true) for w in W, u in U]
  =#
    s1=scenario(w̃=SED(min=0.01,max=0.99,distribution=LogNormal),    ū=ū=SED(mean=0.5,distribution=Exponential, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_RS,s1,show_realized=false,show_sustained=false,show_potential=true, show_attractor=true,show_vertical_potential=true,attractor_color=:forestgreen)
    
    s2=scenario(w̃=SED(min=5,max=1,distribution=Beta),    ū=SED(min=5,max=1,distribution=LogNormal,normalize=true),color=:gray;N)
    phaseplot!(phase_plot_RS,s2,show_realized=false,show_potential=true, show_attractor=true,show_vertical_potential=true,attractor_color=:steelblue)
    
    s3=scenario(w̃=SED(min=0.01,max=0.99,distribution=LogNormal),    ū=SED(min=5,max=1,distribution=LogNormal, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_RS,s3,show_realized=false,show_potential=true, show_attractor=true,show_vertical_potential=true,attractor_color=:darkorange)
    
    s4=scenario(w̃=SED(min=5,max=1,distribution=Beta),    ū=SED(mean=0.5,distribution=Exponential, normalize=true),color=:gray;N)
    phaseplot!(phase_plot_RS,s4,show_realized=false,show_potential=true, show_attractor=true,show_vertical_potential=true,attractor_color=:crimson)
    
    
    a1=Axis(incomes[1,1])
    a2=Axis(incomes[1,2])
    a3=Axis(incomes[2,1])
    a4=Axis(incomes[2,2])
    [hidespines!(a) for a in [a1,a2,a3,a4]]
    [hidedecorations!(a) for a in [a1,a2,a3,a4]]


    for  (a,s,c) in zip([a1,a2,a3,a4],[s1,s2,s3,s4],[colorant"forestgreen",colorant"steelblue",colorant"darkorange",colorant"crimson"])
        s.color=convert(HSL,c)
        incomes!(a,s,show_text=false, indexed=true)
        #scatter!(a,[0.1],[0.9],color=c,markersize=20, space=:relative)
    end
    Label(f[0,1],text="Shape factors",fontsize=20, tellwidth=false)
    Label(f[0,2],text="Scenarios",fontsize=20, tellwidth=false)
    Label(f[0,3],text="Incomes",fontsize=20, tellwidth=false)
     #incomes!(income,phase_s)
    #phaseplot!(five_actor,five_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    #phaseplot!(many_actor,many_s,show_realized=false, show_attractor=true,show_vertical_potential=true)
    save("graphics/convexities.png",f)
    f   
end

function jhfeglkh()
    x = y = -10:0.11:10
y1d = sin.(x) ./ x
# 3D heatmap
sinc2d(x, y) = sin.(sqrt.(x .^ 2 + y .^ 2)) ./ sqrt.(x .^ 2 + y .^ 2)
fxy = [sinc2d(x, y) for x in x, y in y]

fig = Figure(size = (600, 400))
ax1 = Axis(fig[1, 1], xlabel = "x", ylabel = "f(x)", xgridvisible = true,
    ygridvisible = true)
lines!(ax1, x, y1d, color = :red, label = "sinc(x)")
axislegend()
# inset
ax2 = Axis(fig, bbox = BBox(140, 260, 260, 350), xticklabelsize = 12,
    yticklabelsize = 12, title = "inset  at (140, 260, 260, 350)")
hmap = heatmap!(ax2, x, y, fxy, colormap = :Spectral_11)
Colorbar(fig[1, 1], hmap, label = "sinc(x,y)", labelpadding = 5,
    tellheight = false, tellwidth = false, ticklabelsize = 12,
    width = 10, height = Relative(1.5 / 4),
    halign = :right, valign = :center)
limits!(ax2, -10, 10, -10, 10)
hidespines!(ax2)
ax2.yticks = [-10, 0, 10]
ax2.xticks = [-10, 0, 10]
fig
end

function diversity()
    f=Figure(size=(1000,1000))
    a=Axis(f[1,1])
    hidedecorations!(a)
    hidespines!(a)
    #left, right, bottom and top
    a1=Axis(f, bbox = BBox(140, 260, 260, 350))
    scatter!(a1,rand(10))
    a2=Axis(f, bbox = BBox(540, 860, 660, 950))
    scatter!(a2,rand(10))
    f
end

function bezier()

   

    
    batsymbol_string = "M96.84 141.998c-4.947-23.457-20.359-32.211-25.862-13.887-11.822-22.963-37.961-16.135-22.041 6.289-3.005-1.295-5.872-2.682-8.538-4.191-8.646-5.318-15.259-11.314-19.774-17.586-3.237-5.07-4.994-10.541-4.994-16.229 0-19.774 21.115-36.758 50.861-43.694.446-.078.909-.154 1.372-.231-22.657 30.039 9.386 50.985 15.258 24.645l2.528-24.367 5.086 6.52H103.205l5.07-6.52 2.543 24.367c5.842 26.278 37.746 5.502 15.414-24.429 29.777 6.951 50.891 23.936 50.891 43.709 0 15.136-12.406 28.651-31.609 37.267 14.842-21.822-10.867-28.266-22.549-5.549-5.502-18.325-21.147-9.341-26.125 13.886z"

    batsymbol = BezierPath(batsymbol_string, fit = true, flipy = true)
    
    scatter(1:10, marker = batsymbol, markersize = 50, color = :black)
end




function SI_figure_PA_yield(;R=100, minw=0.01,k=3, dispersal=0.2, save_fig=false)
    # institution="PA"
    # target="dispersal"
    # value

    # institutions=[protected_area(fraction::Float64)]
    # institutions=[permits(fraction::Float64, target::String, selection::symbol, reverse::Bool)]
    # institutions=[tax(fraction::Float64, target::String, selection::symbol, reverse::Bool)]
    # institutions=[subsidy(fraction::Float64, target::String, selection::symbol, reverse::Bool)]
    # institutions=[norm(strength::Float64)]
    f=Figure(size=(800,800))

    mw=range(0.1,stop=0.9,length=k)
    mq=range(0.6,stop=1.4,length=k)
    for a=1:k
        Label(f[a,0],text="max w̃ = $(round(mw[a],digits=1))",fontsize=16, tellheight=false, rotation=pi/2)
        for b=1:k
            
            a==1 ? Label(f[0,b],text="sum q = $(round(mq[b],digits=2))",fontsize=16, tellwidth=false) : nothing
            ax=Axis(f[a,b])
            a<k ? hidexdecorations!(ax) : nothing
            b>1 ? hideydecorations!(ax) : nothing
            #hidespines!(ax)
            #s=scenario(q=SED(mean=mq[b],sigma=0,normalize=true),w=SED(min=minw,max=minw+mw[a],normalize=true,distribution=LogNormal),color=:lightgray; dispersal)
            s=scenario(  ū=SED(mean=mq[b],sigma=0,normalize=true),w̃=SED(min=minw,max=minw+mw[a],normalize=false,distribution=LogNormal),color=:lightgray; dispersal)
            dist!(s)
            sim!(s)
            phaseplot!(ax,s,attractor_color=:black, attractor_size=10)
            t=[]
            r=[]
            y=[]
            U=[]
            for i in 0:R
                #print([mq[b],mw[a],i],"\r")
                s.protected=i/R
                #s.aw̃=fill(1.0+i/R*0.5,s.N)
                sim!(s)
                push!(U,sum(s.u)/sum(s.ū))
                push!(y,s.y)
                push!(t,sum(s.total_revenue))
                push!(r,sum(s.resource_revenue))
            end
            #phaseplot!(ax,s,attractor_color=:black, attractor_size=10) need to add aw and au to show the change
            scatter!(ax,Float64.(y),Float64.(U), markersize=3,color=:black)
            l1=lines!(ax,collect((0:R)./R),Float64.(r)./0.33, linewidth=3,color=:forestgreen, label="Resource")
            l2=lines!(ax,collect((0:R)./R),Float64.(t)./0.33, linewidth=3,color=:darkorange,label="Total")
            
            print(argmax(r),"\r")
            argmax(r)!=1 ? scatter!(ax,[argmax(r)/R],[maximum(r)/0.33], markersize=10,color=:forestgreen) : nothing
            argmax(t)!=1 ? scatter!(ax,[argmax(t)/R],[maximum(t)/0.33], markersize=10,color=:darkorange) : nothing
            #a==1 && b==k ? Legend(f,ax,[l1,l2],["Resource","Total"],"Revenues",valign=:top,halign=:right) : nothing
        end
    end
    Label(f[k+1,1:k],text="fraction Protected Area",fontsize=16, tellwidth=false)
    save_fig ? save("graphics/SI_figure_PA_yield.png",f) : nothing
    f
end

function explain_institutions(s)
    d=200
    f=Figure(size=(5*d,3*d))
    a1=Axis(f[1,1])
    a2=Axis(f[1,2])
    a3=Axis(f[1,3])
    a4=Axis(f[1,4])
    a5=Axis(f[1,5])
    b1=Axis(f[2,1])
    b2=Axis(f[2,2])
    b3=Axis(f[2,3])
    b4=Axis(f[2,4])
    b5=Axis(f[2,5])
    linkyaxes!(b1, b2,b3,b4,b5)
    c1=Axis(f[3,1])
    c2=Axis(f[3,2])
    c3=Axis(f[3,3])
    c4=Axis(f[3,4])
    c5=Axis(f[3,5])
    s.institution=[]
    sim!(s,y0=0.7)
    u0=s.u
    y0=s.y
    barplot!(a1,s.w̃,s.u)
    barplot!(a1,s.w̃,s.ū.-s.u)
    incomes!(b1,s)
    phaseplot!(c1,s,show_realized=true, show_trajectory=true)
    s.institution=[Dynamic_permit_allocation(value=0.3, reverse=false)]
    sim!(s)
    barplot!(a2,s.w̃,s.u)
    barplot!(a2,s.w̃,s.ū.-s.u,offset=s.u)
    incomes!(b2,s)
    phaseplot!(c2,s,show_realized=true, show_trajectory=true)
    s.institution=[Dynamic_permit_allocation(value=0.3, reverse=true)]
    sim!(s)
    barplot!(a3,s.w̃,s.u)
    barplot!(a3,s.w̃,s.ū.-s.u,offset=s.u)
    incomes!(b3,s)
    phaseplot!(c3,s,show_realized=true, show_trajectory=true)
    s.institution=[Market(value=0.6, target=:effort)]
    sim!(s)
    #println(s.t_ϕ)
    barplot!(a4,s.w̃,s.u)  
    barplot!(a4,s.w̃,s.ū.-s.u,offset=s.u)
    incomes!(b4,s) 
    #scatter!(c4,s.t_y,markersize=3)
    phaseplot!(c4,s,show_realized=true, show_trajectory=true)
    s.institution=[Market(value=0.3, target=:yield)]
    sim!(s)
    barplot!(a5,s.w̃,s.u)
    barplot!(a5,s.w̃,s.ū.-s.u,offset=s.u)
    incomes!(b5,s)
    phaseplot!(c5,s,show_realized=true, show_trajectory=true)

    f
end

function explain_institutions(;sort_w=true)
    ms=10
    mso=5
    f=Figure(size=(900,600))
    a1=Axis(f[1,1])
    a2=Axis(f[2,1])
    a3=Axis(f[1,2])
    a4=Axis(f[2,2])
    a5=Axis(f[1,3])
    a6=Axis(f[2,3])
    s=scenario(ū=sed(mean=2.0,sigma=0.0, normalize=true),w̃=sed(min=0.05,max=0.5,distribution=LogNormal),N=100)
    sim!(s)

    id=findall(s.u.>0)
    A=fill(0.0,s.N)
    B=fill(0.0,s.N)
    A[id[1:20]].=1.0
    B[id[20]:end].=1.0

    Φ(y,s;X=fill(1.0,s.N),Y=fill(0.0,s.N))=length(findall(s.w̃.*X.+Y.<y))/s.N

    y=range(0.0,stop=1.0,length=100)
    lines!(a1,y,Φ.(y,Ref(s)), color=:lightgray)
    lines!(a1,y,Φ.(y,Ref(s),X=fill(2.0,100)))

    lines!(a2,y,Φ.(y,Ref(s)),color=:lightgray)
    lines!(a2,y,Φ.(y,Ref(s),Y=fill(0.3,100)))

    lines!(a3,y,Φ.(y,Ref(s)), color=:lightgray)
    lines!(a3,y,Φ.(y,Ref(s),Y=A))

    lines!(a4,y,Φ.(y,Ref(s)), color=:lightgray)
    lines!(a4,y,Φ.(y,Ref(s),Y=B))

    scatter!(a5,s.w̃,Φ.(y,Ref(s)),markersize=mso, color=:lightgray)
    scatter!(a6,s.w̃,Φ.(y,Ref(s)),markersize=mso, color=:lightgray)
    linkaxes!(a1,a2,a3,a4,a5,a6)
    println(id)
    f
end



function EI()
    T=[
        "Open access",
        "Assigned use rights are commonly employed in smaller communities where resource access is controlled collectively or by leadership (ref). Ideally, these rights are allocated based on need, prioritizing individuals with limited alternative income opportunities. However, in practice, they may often be assigned to those with higher socio-economic status, who already have better opportunities or greater capacity to invest in efficient extraction methods. This disparity can exacerbate income inequalities and reduce overall social equity.",
    "Tradable use rights are a market-based approach where rights to harvest a specific amount of a resource are allocated and can be bought, sold, or traded among individuals or groups. This system is often touted  for flexibility and efficiency in resource utilization while promoting sustainable management (refs) (Tietenberg 2005). Tradable use rights can be based on yield (e.g., quotas) or effort (e.g., number of traps).",
    "Protected areas (PA) are often proposed to curb resource overexploitation, but their effectiveness and equity impacts vary by context. We approximate the effectof PA by reducing Impact by adding the term m(yₚ, y), capturing spillover effects and increased fecundity (e.g., from larger individuals). The accessible resource declines by the protected fraction, Aₚ, which in turn increases the Incentive to leave resource use by (1−Aₚ)⁻¹. This loss of direct resource access may be offset by alternative income sources, such as tourism, which depend on the ecological state of the protected area, wᵀᵢ(yₚ). The distribution of wᵀᵢ reflects potential inequalities in the benefits of tourism.",
    "Economic incentives, such as taxes, subsidies, or royalties, influence resource use by altering core model variables like price or efficiency, leading to changes in incentives and impacts. Accurately assessing the public costs and benefits of these incentives is critical. For example, a fishery royalty could reduce the need for other forms of taxation, distributing benefits more equitably across society. Conversely, subsidies must be carefully evaluated against the public costs they impose to ensure a net positive societal impact.",
    "Kuznets dynamics of economic development"]
    L=[ [L"\gamma_i=w_i",L"w_i= \text{alternative opportunities}"],
        [L"\gamma_i=w_i+c_i",L"c_i=\text{discentive for violation}"],
        [L"\gamma_i=w_i+\phi",L"\dot{\phi}=\text{D}-\text{S}", L"\text{S} = \sum_{i} \max\{0, U_i - u_i\}",L"\text{D} = \sum_{i} \text{if()} u_i \ge U_i \text{ and } \dot{u}_i > 0, \dot{u}_i, 0),"],
        [L"\gamma_i= \frac{w_i+w_i^T(y_p)}{1-f_p} ",L"  \bar{u}_i=\frac{q_i \bar{e}_i}{r+m(y_p,y)}",L"w_i^T(y_p)=\text{tourism benefits}",L"m(y_p,y)=\text{spillover effect}"],
        [L"\gamma_i=w(E)_i","and/or",L"\bar{u}=\frac{\bar{e} q_i(E)}{r}"],
        [L"\gamma_i=w_i(E(t))",L"\bar{u}=\frac{\bar{e} q_i(E(t))}{r}"]
    ]
    Lab=[
        "Open Access","Assigned Use Rights","Trrdable Use Rights", "Protected Areas", "Economic Incentives", "Kuznets Dynamics"
    ]
    img = load(assetpath(homedir()*"/SciML/protected.png"))
    img2=load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/Latex/TradableUseRights.tex.png"))
    offset = Dict()
    offset[1,1]=Vec2f(0, 0)
    offset[1,2]=Vec2f(0, -40)
    offset[2,1]=Vec2f(0, 0)
    offset[2,2]=Vec2f(0, -40)
    offset[3,1]=Vec2f(0, 0)
    offset[3,2]=Vec2f(0, -40)
    offset[3,3]=Vec2f(0, -80)
    offset[3,4]=Vec2f(0, -120)
    offset[4,1]=Vec2f(0, 10)
    offset[4,2]=Vec2f(0, -50)
    offset[4,3]=Vec2f(0, -110)
    offset[4,4]=Vec2f(0, -140)
    offset[5,1]=Vec2f(0, 0)
    offset[5,2]=Vec2f(0, -40)
    offset[5,3]=Vec2f(0, -80)
    offset[6,1]=Vec2f(0, 0)
    offset[6,2]=Vec2f(0, -60)
    colArray=[15,1,3,7,9,5]
    width=1200
    height=1600
    f=Figure(size=(width,height))
    A=Dict()
    U=ones(100)
    U[70:100].=0.0
    fs=20
    Label(f[0,0:1],"Policy Instruments", tellwidth=false, halign=:left, fontsize=fs)
    Label(f[0,2],"Desicion problem: y - γᵢ > 0", tellwidth=false, fontsize=fs)
    Label(f[0,3],"System Outcome", tellwidth=false, fontsize=fs)
    Label(f[0,4],"Inome Outcome", tellwidth=false, fontsize=fs)
    for row in 1:6
        for col=1:4
            ū=sed(mean=2.0,sigma=.0, distribution=LogNormal,normalize=true)
            w̃=sed(min=0.1,max=0.7, distribution=LogNormal)
            OA=scenario(color=:lightgray,ū=deepcopy(ū),w̃=deepcopy(w̃))
            if row==1
                s=scenario(color=ColorSchemes.tab20[colArray[row]];ū,w̃)
            elseif row==2
                s=scenario(color=ColorSchemes.tab20[colArray[row]], institution=Dynamic_permit_allocation(value=0.25);ū,w̃)
            elseif row==3
                s=scenario(color=ColorSchemes.tab20[colArray[row]], institution=Market(value=0.49);ū  ,w̃)
            elseif row==4
                s=scenario(color=ColorSchemes.tab20[colArray[row]], institution=Protected_area(value=0.32);ū,w̃)
            elseif row==5
                s=scenario(color=ColorSchemes.tab20[colArray[row]], institution=Economic_incentive(value=0.5);ū,w̃)
            elseif row==6
                s=scenario(color=ColorSchemes.tab20[colArray[row]], institution=Economic_incentive(value=0.5);ū,w̃)
            end
            if col==1
                A[row,col]=Axis(f[row,col], width=width/6*2)
                xlims!(A[row,col],(0,width/4))
                ylims!(A[row,col],(height/4,0))
                hidedecorations!(A[row,col])
                hidespines!(A[row,col])
                text!(A[row,col],T[row],word_wrap_width=width/6*2-30,align = (:left, :top))
            elseif col==2
                A[row,col]=Axis(f[row,col], width=width/5)
                ylims!(A[row,col],(height/4,-40))
                hidedecorations!(A[row,col])
                hidespines!(A[row,col])
                if true
                    if isa(L[row],Array)
                            [text!(A[row,col],l,align = (:center, :top),fontsize=20, offset=offset[row,i]) for (i,l) in enumerate(L[row])]
                    else
                        text!(A[row,col],L[row],align = (:center, :top),fontsize=20)
                    end
                else
                    image!(A[row,col],img2')
                end

                
            elseif col==3
                A[row,col]=Axis(f[row,col],aspect=1)


                hidespines!(A[row,col])
                hidedecorations!(A[row,col])
                phaseplot!(A[row,col],OA)
                row>1 ? phaseplot!(A[row,col],s, show_realized=true, show_potential=row==1 ? true : false) : nothing
                
            elseif col==4
                
                A[row,col]=Axis(f[row,col], width=width/6)
                hidespines!(A[row,col])
                hideydecorations!(A[row,col])
                incomes!(A[row,col],s)
            end
           Label(f[row,0],text=Lab[row], rotation=pi/2, tellheight=false,color=ColorSchemes.tab20[colArray[row]], font=:bold)
        end
    end
    #image!(A[3,2],rotr90(img))
    linkaxes!([A[i,4] for i in 1:6]...)
    colgap!(f.layout,5)
    f
end