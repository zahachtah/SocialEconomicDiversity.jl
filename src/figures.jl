

function Figure4()
    T=[
        "Open access",
        "Assigned use rights are commonly employed in smaller communities where resource access is controlled collectively or by leadership (ref). Ideally, these rights are allocated based on need, prioritizing individuals with limited alternative income opportunities. However, in practice, they may often be assigned to those with higher socio-economic status, who already have better opportunities or greater capacity to invest in efficient extraction methods. This disparity can exacerbate income inequalities and reduce overall social equity.",
    "Tradable use rights are a market-based approach where rights to harvest a specific amount of a resource are allocated and can be bought, sold, or traded among individuals or groups. This system is often touted  for flexibility and efficiency in resource utilization while promoting sustainable management (refs) (Tietenberg 2005). Tradable use rights can be based on yield (e.g., quotas) or effort (e.g., number of traps).",
    "Protected areas (PA) are often proposed to curb resource overexploitation, but their effectiveness and equity impacts vary by context. We approximate the effectof PA by reducing Impact by adding the term m(yₚ, y), capturing spillover effects and increased fecundity (e.g., from larger individuals). The accessible resource declines by the protected fraction, Aₚ, which in turn increases the Incentive to leave resource use by (1−Aₚ)⁻¹. This loss of direct resource access may be offset by alternative income sources, such as tourism, which depend on the ecological state of the protected area, wᵀᵢ(yₚ). The distribution of wᵀᵢ reflects potential inequalities in tourism and economic benefits.",
    "Economic incentives, such as taxes, subsidies, or royalties, influence resource use by altering core model variables like price or efficiency, leading to changes in incentives and impacts. Accurately assessing the public costs and benefits of these incentives is critical. For example, a fishery royalty could reduce the need for other forms of taxation, distributing benefits more equitably across society. Conversely, subsidies must be carefully evaluated against the public costs they impose to ensure a net positive societal impact.",
    "Kuznets dynamics of economic development"]
    L=[ [L"\gamma_i=w_i",L"w_i= \text{alternative opportunities}"],
        [L"\gamma_i=w_i+c_i",L"c_i=\text{discentive for violation}"],
        [L"\gamma_i=w_i+\phi",L"\dot{\phi}=\text{demand}-\text{supply}", L"\phi= \text{market price of use rights}"],
        [L"\gamma_i= \frac{w_i+w_i^T(y_p)}{1-A_p} ",L"  \bar{u}_i=\frac{q_i \bar{e}_i}{r+m(y_p,y)}",L"w_i^T(y_p)=\text{tourism benefits}",L"m(y_p,y)=\text{spillover effect}"],
        [L"\gamma_i=w(E)_i","and/or",L"\bar{u}=\frac{\bar{e} q_i(E)}{r}"],
        [L"\gamma_i=w_i(E(t))",L"\bar{u}=\frac{\bar{e} q_i(E(t))}{r}"]
    ]
    Lab=[
        "Open Access","Assigned Use Rights","Trrdable Use Rights", "Protected Areas", "Economic Incentives", "Kuznets Dynamics"
    ]
    img = load(assetpath(homedir()*"/SciML/protected.png"))
    offset = Dict()
    offset[1,1]=Vec2f(0, 0)
    offset[1,2]=Vec2f(0, -40)
    offset[2,1]=Vec2f(0, 0)
    offset[2,2]=Vec2f(0, -40)
    offset[3,1]=Vec2f(0, 0)
    offset[3,2]=Vec2f(0, -40)
    offset[3,3]=Vec2f(0, -80)
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
                A[row,col]=Axis(f[row,col], width=width/6)
                ylims!(A[row,col],(height/4,-40))
                hidedecorations!(A[row,col])
                hidespines!(A[row,col])
               if isa(L[row],Array)
                    [text!(A[row,col],l,align = (:center, :top),fontsize=20, offset=offset[row,i]) for (i,l) in enumerate(L[row])]
               else
                text!(A[row,col],L[row],align = (:center, :top),fontsize=20)
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
    f
end