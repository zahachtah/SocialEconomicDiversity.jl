
function policy_descriptions()
    D=Dict()

    D["Open Access"]=L"Under open access only the current distributions of alternative income distributions, $\tilde{w}$ is an incentive to not harvest resources setting the shape of the incentive curve (increasing thick line). The impact distributions, $\bar{u}$, determines the shape of the impact curves (decreasing thin line). Individual actor participation is determined by the balance of resource availability and alternative income opportunities as $\dot{u}=y-\tilde{w}-I(u)$, were institutional impact under open access is $I(u)=0$."

    D["Exclusive Use Rights"]=L"resource access is allocated to selected actors based on criteria such as historical use, or socio-economic status, meaning that only a predetermined fraction (e.g., 30%) of actors are permitted to participate. Depending on whether the exclusion targets those with low or high economic status (depicted in dark blue or light blue, respectively), the system converges to the same equilibrium state, marked by blue circles, but results in markedly different income distributions among the actors. Institutional impact $I_i=\text{if excluded: }1\text{ else: }0$"

    D["Tradable Use Rights"]=L"use rights can be distributed equally (dark orange), or to those that had historical use under open access (light orange). Unused use rights, $\sum{\max(0,R_i-u_i)}$ provide the supply, while demand is $\sum{\max (0,\dot{u}_i)}$, subject to $u_i<\bar{u}_i$. Price of use rigths, $\phi$, then changes as $\dot{\phi}= k (demand-supply)$, were k sets timescale of price changes. We assume that use rights payments can be represented as continuous rents on capital (see SM for details), the Institutional utility term becomes:$I_i(u_i)=(R_i-u_i) * \phi$, resulting in $\dot{u}_i=y-\tilde{w}-\phi$ were a social planner can set the total and distribution of use rights, $\sum{R_i}$."

#=are implemented as a cost and revenue mechanism that activates when an actor's extraction deviates from their allotted quota, i.e. when fishing above ones alloted use right one pays the price to a user not claiming their use right. The price of these rights is dynamically determined by the supply of unused rights relative to the total demand to increase extraction beyond one's alloted use rights, leading to an additive shift in the incentive curve—moving it to the right compared to the open access scenario (shown in gray). Use rights can be equally attributed or based on historical use, e.g. under open access. Institutional impact is equal to use right price, i.e. $I(u)=ϕ$"=#

    D["Protected Area"]=L"assumes users are excluded from harvesting in fraction $f_p$ of the full area. Resources move between the protected and harvested area at rate $m$. Exclusion lowers the total resources available to harvesters by $(1-f_p)$. This scarcity incentivizes the pursuit of alternative income opportunities. Since user access is restricted in the protected area, its density $y_p$ remains higher.Spillover effects $m (y_p-y)$ from the protected zone supplement regeneration in the harvested area, thus mitigating the negative impacts of extraction. Overall, the effectiveness of protected area policy hinges on the resource mobility rate $m$. The system dynamics are given by:    $\dot{y}=y(1-y) -y\sum{u_i}+f_p/(1-f_p)m (y_p-y)$           $\dot{y}_p=y_p(1-y_p) +f_p/(1-f_p)m (y_p-y)$"


    #$\dot{y_p}  =(1-y_p)y_p +(1-f_p)/f_p m (y-y_p)$ 
    D["Economic Incentives"]="Economic incentives use diverse tools to modify both incentive and impact curves by altering the socio-economic context. For example, yield-based royalties or subsidies tilt the incentive curve up or down, while compensation for reduced effort shifts it right. Similarly, investments in pollution mitigation boost regeneration and lessen harvesting impacts—raising the impact curve—whereas loans for improved harvesting technology increase the impact thereby  tilting the curve downward."

    D["Development"]="broadly represents indirect socio-economic improvements—such as better alternative incomes, technological advances, increased knowledge, and more capital. In our simulation, it is modeled directly by shifting the incentive curve to the right (e.g. making harvesting less attractive through improved alternatives) and tilting the impact curve downward (reflecting more efficient, less damaging extraction). Depending on initial conditions (gray circles), the development path may follow a Kuznets pattern: an early decline in ecosystem state due to overextraction, followed by recovery as superior income options gradually reduce the incentive to harvest."

    D["Open Access"]=L"$U_i = u_i y\;-\; (\bar{u}-u_i)\,\tilde{w}_i $"

    D["Exclusive Use Rights"]=L"$U_i = u_i y\;-\; (\bar{u}-u_i)\,\tilde{w}_i \;-\; \max(u_i - R_i,0) S$"

    D["Tradable Use Rights"] = L"$U^_i = u_i y - (\bar{u} - u_i)\,\tilde{w}_i + (R_i - u_i)\,\phi$"

    D["Protected Area"] = L"$U_i = u_i y (1 - f_p) - (\bar{u}^* - u_i)\,\tilde{w}_i \quad \bar{u}^* = \frac{p q}{r} \cdot \frac{1}{1 + \frac{r_{\text{spillover}}}{r}}$"
    
    D["Economic Incentives"] = L"$U_i = u_i y - (\bar{u}^* - u_i)\,\tilde{w}_i^* \quad \bar{u}^* = \frac{p(EI)\,q(EI)}{r(EI)}, \quad \tilde{w}_i^* = \frac{w(EI)}{p(EI)\,q(EI)\,K(EI)}$"
    
    D["Development"] = L"$U_i = u_i y - (\bar{u}^* - u_i)\,\tilde{w}_i^* \quad \bar{u}^* = \frac{p(EI)\,q(EI)}{r(EI)}, \quad \tilde{w}_i^* = \frac{w(EI)}{p(EI)\,q(EI)\,K(EI)}$"
    
    return D
end


policy_descriptions()

function oa_plot!(a,s; color=ColorSchemes.tab20[16], trajectory=false)
    sol=sim(s;regulation=0.0)
    bg_plot!(a)
    Γ_plot!(a,sol;color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol;color)
    trajectory ? trajecory_plot!(a,sol;color) : nothing
end

function aur_plot!(a,s; colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18, annotation="")
    
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    p=sol.prob.p
    Γ_plot!(a,sol;color)
    Φ_plot!(a,sol, linewidth=1; color)
    attractor_plot!(a,sol; color)
#=
    id=findall(p.R.==1.0)
    y=range(0.0,stop=1.0,length=p.N)
    z=Γ.(p.w̃[id], Ref(scenario(p,policy="Open Access")))

    lines!(a,p.w̃[id],max.(0.005,z), color=:red, linewidth=2)=#

    id=findall(p.R.==1.0)
    y=range(0.0,stop=1.0,length=p.N)
    z=Γ.(p.w̃[id], Ref(p))

    lines!(a,p.w̃[id],max.(0.005,z), color=:red, linewidth=2)
         
end

function tur_plot!(a,s; colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    oa_plot!(a,s)
    Γ_plot!(a,sol; color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol; color)
    #target_plot!(a,sol, linewidth=2;color)


    #text!(a,0.52,0.11,text="Yield limit=0.25", font=:bold, rotation=-pi/17, fontsize=annotation_font_size;color)
    #text!(a,0.55,0.27,text="Effort limit=0.5", font=:bold, fontsize=annotation_font_size;color)
    attractor_plot!(a,sol;color)
end

function pa_plot!(a,s;colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18, markersize=15)
#=
pa1_sol=sim(s;regulation=0.3)
pa2_sol=sim(s;regulation=0.5)
pa3_sol=sim(s;regulation=0.7)
pa4_sol=sim(s;regulation=0.8)
pa5_sol=sim(s;regulation=0.9)
pa6_sol=sim(s;regulation=0.95)
=#
#oa_plot!(a,s)

color=colorscheme[colorid]
cases=[s]
[Γ_plot!(a,sim(s;regulation);color) for sol in cases]
[Φ_plot!(a,sim(s;regulation); color,linewidth=1) for sol in cases]
attractor_plot!(a,sim(s;regulation), color=colorscheme[colorid]; markersize)
#APA=[sim(s;regulation=r) for r in range(0.0,stop=1.0,length=40)]
#[attractor_plot!(a,sim(s;regulation=r), color=color, markersize=8) for r in range(0.0,stop=1.0,length=40)]
#arrow_arc!(a4, [0.0,0.0], 0.75, pi/2-pi/10, pi/8)

#attractor_plot!(a,sim(s;regulation=0.3), color=color, markersize=8)
#attractor_plot!(a,sim(s;regulation=0.8), color=color, markersize=8)
#text!(a,0.16,0.53,text="fₚ=0.3", color=color, font=:bold, fontsize=annotation_font_size)
#text!(a,0.53,0.56,text="fₚ=0.8", color=color, font=:bold, fontsize=annotation_font_size)
end

function ei_plot!(a,s;colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    Γ_plot!(a,sol; color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol; color)
end


#save("figures/Figure_4.png",f)

#= Do universal basic incomes add to w̃ or do they max(w̃,UBI)? UBI does not "take away" from ū as it is not linked to use of time, meaning that alternative opporunities are added on top of UBI?

1) protected area, does decreased impact change revenues?
2) gear economic incentives, how to link to regulation? go back to the version with effort cost (fuel cost)
fuel subsidy increased revenue has to outweigh the loan cost
3) universal basic incomes, additive to incentives? 

w/pKq

ēq/r


=#
function exclusive_use_right_plot()
    f=Figure(size=(400,400))
    a=Axis(f[1,1])
    s=scenario(high_impact(),policy="Exclusive Use Rights", reverse=true)
    s2=scenario(high_impact(),policy="Exclusive Use Rights", reverse=false)
     colorid=1; colorscheme=ColorSchemes.tab20; regulation=0.5; annotation_font_size=18
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    sol2=sim(s2;regulation)
    oa_plot!(a,s)
    Γ_plot!(a,sol;color)
    Γ_plot!(a,sol2;color)
    Φ_plot!(a,sol, linewidth=1; color)
    attractor_plot!(a,sol; color)
    arrows!(a,[0.05],[0.25],[0.0],[0.72], linewidth=1; color)
    arrows!(a,[0.05],[1.0],[0.0],-[0.72], linewidth=1;color)
    text!(a,0.07,0.85,text="high w̃ excluded",  font=:bold, fontsize=annotation_font_size;color)

    arrows!(a,[0.14],[0.0],[0.0],[0.72], linewidth=1;color)
    arrows!(a,[0.14],[0.75],[0.0],-[0.72], linewidth=1;color)
    text!(a,0.16,0.5,text="low w̃ excluded", font=:bold, fontsize=annotation_font_size;color)
    attractor_plot!(a,sol; color)  
    hidedecorations!(a)
    hidespines!(a)  
    f
end
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Exlusive_Use_Rights.png",exclusive_use_right_plot())

function tradable_use_rights_plot()
    s=high_impact()
    f=Figure(size=(400,400))
    a=Axis(f[1,1])
    colorid=3
     colorscheme=ColorSchemes.tab20
      regulation=0.75
       annotation_font_size=18
    color=colorscheme[colorid]
    s3a=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    s3b=scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
    sol=sim(s3a; regulation=0.5)
    sol2=sim(s3b; regulation=0.75)
    oa_plot!(a,sol.prob.p)
    Γ_plot!(a,sol; color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol; color)
    target_plot!(a,sol, linewidth=2;color)
    target_plot!(a,sol2, linewidth=2;color)

    arrows!(a,[0.1], [0.5], [0.4], [0.0]; color)
    text!(a,0.12,0.52,text="Price ϕ=0.45", font=:bold, fontsize=annotation_font_size;color)
    #text!(a,0.52,0.11,text="Yield limit=0.25", font=:bold, rotation=-pi/17, fontsize=annotation_font_size;color)
    text!(a,0.55,0.27,text="Effort limit=0.5", font=:bold, fontsize=annotation_font_size;color)
    attractor_plot!(a,sol;color)
    hidedecorations!(a)
    hidespines!(a)  
    f
end
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Tradable_Use_Rights.png",tradable_use_rights_plot())

function development_plot(;s=base())
    f=Figure(size=(400,400))
    a_d=Axis(f[1,1])
    annotation_font_size=18
    s6a=scenario(s,policy="Development")
    s6b=scenario(SocialEconomicDiversity.change(s,ū=sed(mean=0.5,sigma=0.0, normalize=true)),policy="Development")
    d1_color=ColorSchemes.tab20[9]
    d2_color=ColorSchemes.tab20[10]
    sol6aOA=sim(s6a;regulation=0.0)
    sol6bOA=sim(s6b;regulation=0.0)
    u0=sol6aOA.u[end][1:sol6aOA.prob.p.N]
    y0=sol6aOA.u[end][sol6aOA.prob.p.N+1]
    sol6a=sim(s6a;regulation=0.9,u0, y0)
    u0=sol6bOA.u[end][1:sol6bOA.prob.p.N]
    y0=sol6bOA.u[end][sol6bOA.prob.p.N+1]
    sol6b=sim(s6b;regulation=0.9,u0, y0)
    oa_plot!(a_d,high_impact())
    Φ_plot!(a_d,sol6a, color=d1_color, linewidth=1)
    Φ_plot!(a_d,sol6b, color=d2_color, linewidth=1)
    Φ_plot!(a_d,sol6a, color=d1_color, linewidth=1, t=1000.0)
    Φ_plot!(a_d,sol6b, color=d2_color, linewidth=1, t=1000.0)
    Γ_plot!(a_d,sol6a, color=d1_color, t=1000.0)
    attractor_plot!(a_d,sim(s6a;regulation=0.0), color=:darkgray, markersize=20)
    attractor_plot!(a_d,sim(s6b;regulation=0.0), color=:darkgray, markersize=20)
    attractor_plot!(a_d,sim(s6a;regulation=0.9), color=ColorSchemes.tab20[9], markersize=20)
    attractor_plot!(a_d,sim(s6b;regulation=0.9), color=ColorSchemes.tab20[10], markersize=20)
    trajecory_plot!(a_d,sol6a, color=d1_color, linewidth=4)
    trajecory_plot!(a_d,sol6b, color=d2_color, linewidth=4)
    arrows!(a_d,[0.6], [0.7], [-0.25], [0.0], color=ColorSchemes.tab20[7])
    text!(a_d,0.6, 0.75,text="Kuznets\ndevelopment\nwith low\ninitial\nimpact", align=(:left,:top),color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)
    text!(a_d,0.55, 0.3,text="Development\nwith high \ninitial impact", align=(:left,:top),color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)
    hidedecorations!(a_d)
    hidespines!(a_d)  
    f
end
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/development.png",development_plot())

function economic_incentives_plot(;s=base())
    annotation_font_size=18
    f=Figure(size=(400,400))
    a_ei=Axis(f[1,1])
    s5a=scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:subsidy)
    s5b=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
    s5c=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:subsidy)
    s5d=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:additive)
    ei_plot!(a_ei,s5a, colorid=7)
    ei_plot!(a_ei,s5b, colorid=7)
    ei_plot!(a_ei,s5c, colorid=7)
    ei_plot!(a_ei,s5d, regulation=0.3, colorid=7)
    arrow_arc_deg!(a_ei, [1.0,0.0], 0.65, -29,-62, color=ColorSchemes.tab20[7], linewidth=1, linestyle=:solid)
    text!(a_ei,0.55,0.3,text="Impact", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/4, fontsize=annotation_font_size)

    arrow_arc_deg!(a_ei, [0.0,0.0], 0.75, 4, 15, color=ColorSchemes.tab20[7], linewidth=1, linestyle=:solid)
    text!(a_ei,0.22,0.75,text="Taxes", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/3.7, fontsize=annotation_font_size)
    text!(a_ei,0.1,0.75,text="Subsidy", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/2.7, fontsize=annotation_font_size)

    arrows!(a_ei,[0.07], [0.2], [0.25], [0.0], color=ColorSchemes.tab20[7])
    text!(a_ei,0.09,0.1,text="Effort", color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)
    hidedecorations!(a_ei)
    hidespines!(a_ei)  
    f
end
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/economic_incentives.png",economic_incentives_plot())
function testfig()
    f=Figure()
    a=Axis(f[1,1])
    text!(a,0.1,0.5,text=L"\begin{align}s = & \frac{w+r}{s+e} \\ s = & \frac{w+r}{s+e} \end{align}")
    f
end

function newFig4(; labelsize=25,annotation_font_size=18,s=base(N=1000))
    println(s.ū)
    s1=scenario(s,policy="Open Access")
    s2a=scenario(s,policy="Exclusive Use Rights", reverse=true)
    s2b=scenario(s,policy="Exclusive Use Rights", reverse=false)
    s3a=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    ts=sim(s3a,regulation=0.0)
    R=ts.u[end][1:s3a.N].>0.0
    s3b=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05, historical_use_rights=true)
    s4a=scenario(s,policy="Protected Area", m=0.2)
    s4b=scenario(s,policy="Protected Area", m=0.5)
    s5a=scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
    s5b=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
    s5c=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:subsidy)
    s5d=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:additive)
    s6a=scenario(s,policy="Development")
    s6b=scenario(s,w̃=sed(min=0.01,max=0.9,distribution=LogNormal), ū=sed(mean=0.5,sigma=0.0, normalize=true),policy="Development",μ_value=1)
    base_size=300
    f=Figure(size=(4*base_size,7*base_size))
    a_oa=Axis(f[1:2,2])#,title=s1.policy)
    a_aur=Axis(f[3:4,2])#,title=s2a.policy)
    a_tur=Axis(f[5:6,2])#,title=s3a.policy)
    a_pa=Axis(f[7:8,2])#,title=s4a.policy)
    a_ei=Axis(f[9:10,2])#,title=s5.policy)
    a_d=Axis(f[11:12,2])#,title=s6.policy)
    [hidedecorations!(a) for a in [a_oa,a_aur,a_tur,a_pa,a_ei, a_d]]
    [hidespines!(a) for a in [a_oa,a_aur,a_tur,a_pa,a_ei, a_d]]
    b_oa_1=Axis(f[2,3])#,title=s1.policy)
    b_aur_1=Axis(f[3,3])#,title=s2a.policy)
    b_aur_2=Axis(f[4,3])#,title=s2a.policy)
    b_tur_1=Axis(f[5,3])#,title=s3a.policy)
    b_tur_2=Axis(f[6,3])#,title=s3a.policy)
    #ylims!(b_tur,(-0.02,0.012))
    b_pa1=Axis(f[7,3])#,title=s4a.policy)
    b_pa2=Axis(f[8,3])#,title=s4a.policy)
    b_ei_1=Axis(f[9,3])#,title=s5.policy)
    b_ei_2=Axis(f[10,3])
    b_d=Axis(f[11:12,3], xlabel="development time →" )#,title=s6.policy)
    [hidedecorations!(a) for a in [b_oa_1,b_aur_1,b_aur_2,b_tur_1,b_tur_2,b_pa1,b_pa2,b_ei_1,b_ei_2]]
    [hidespines!(a) for a in [b_oa_1,b_aur_1,b_aur_2,b_tur_1,b_tur_2,b_pa1,b_pa2,b_ei_1,b_ei_2, b_d]]
    t_oa=Axis(f[1:2,1])#,title=s1.policy)
    t_aur=Axis(f[3:4,1])#,title=s2a.policy)
    t_tur=Axis(f[5:6,1])#,title=s3a.policy)
    t_pa=Axis(f[7:8,1])#,title=s4a.policy)
    t_ei=Axis(f[9:10,1])#,title=s5.policy)
    t_d=Axis(f[11:12,1])#,title=s6.policy)
    [hidedecorations!(a) for a in [t_oa,t_aur,t_tur,t_pa,t_ei, t_d]]
    [hidespines!(a) for a in [t_oa,t_aur,t_tur,t_pa,t_ei, t_d]]
    colsize!(f.layout, 2, Relative(0.3))
    colsize!(f.layout, 3, Relative(1/4))

    oa_plot!(a_oa,s1)

    oa_plot!(a_aur,s2a)
    aur_plot!(a_aur,s2a,regulation=0.5)
    aur_plot!(a_aur,s2b,regulation=0.5,colorid=2)
    text!(a_aur,0.35,0.0,text="Low w̃\nexclusion", space=:relative,fontsize=annotation_font_size)
    text!(a_aur,0.1,0.51,text="High w̃\nexclusion", space=:relative,fontsize=annotation_font_size)

    text!(a_aur,0.51,0.52,text="50% participation\nlimit", space=:relative,fontsize=annotation_font_size*1.1)

    tur_plot!(a_tur,s3a, regulation=0.51, colorid=3)
    tur_plot!(a_tur,s3b, regulation=0.5, colorid=4)
    arrows!(a_tur,[0.3], [0.5], [0.18], [0.0], linewidth=4, arrowsize=15, color=ColorSchemes.tab20[3])
    text!(a_tur,0.12,0.52,text="Price\nϕ=0.2", font=:bold, fontsize=annotation_font_size, color=ColorSchemes.tab20[3])

    text!(a_tur,0.55,0.45,text="0.5 total\neffort quota", space=:relative,fontsize=annotation_font_size*1.1)

    pa_reg1=0.3
    pa_reg2=0.1
    oa_plot!(a_pa,s1)
    pa_plot!(a_pa,s4a, colorid=5, regulation=pa_reg1)
    pa_plot!(a_pa,s4b, colorid=6, regulation=pa_reg2)
    arrow_arc_deg!(a_pa, [0.0,0.0], 0.85, 29, 37, color=ColorSchemes.tab20[5], linewidth=2, linestyle=:solid)
    text!(a_pa,0.58,0.60,text="Exclusion\neffect", color=ColorSchemes.tab20[5], font=:bold,  fontsize=annotation_font_size)
    arrow_arc_deg!(a_pa, [0.7,0.16], 0.9, -38, -33, color=ColorSchemes.tab20[5], linewidth=2, linestyle=:solid)
    text!(a_pa,0.25,0.85,text="Spillover\n  effect", color=ColorSchemes.tab20[5], font=:bold,  fontsize=annotation_font_size)

    oa_plot!(a_ei,s1)
    #ei_plot!(a_ei,s5a, colorid=7)
    Φ_plot!(a_ei,sim(s5a,regulation=0.9), color=ColorSchemes.tab20[7], linewidth=1)
    ei_plot!(a_ei,s5b, colorid=7, regulation=0.5)
    ei_plot!(a_ei,s5c, colorid=7,regulation=0.4)
    #ei_plot!(a_ei,s5d, regulation=0.3, colorid=7)
    arrow_arc_deg!(a_ei, [1.0,0.0], 0.45, -45,-60, color=ColorSchemes.tab20[7], linewidth=2, linestyle=:solid, flip_arrow=true)
    text!(a_ei,0.55,0.13,text="ē ↑", color=ColorSchemes.tab20[7], font=:bold,  fontsize=annotation_font_size)

    arrow_arc_deg!(a_ei, [0.0,0.0], 0.8, 20, 40, color=ColorSchemes.tab20[7], linewidth=2, linestyle=:solid)
    arrow_arc_deg!(a_ei, [0.0,0.0], 0.8, 40,20,  color=ColorSchemes.tab20[7], linewidth=2, linestyle=:solid, flip_arrow=true)
    text!(a_ei,0.52,0.5,text=" p ↓", color=ColorSchemes.tab20[7], font=:bold,  fontsize=annotation_font_size)
    text!(a_ei,0.33,0.72,text="Subsidy or\n    Taxes", color=:gray, font=:bold,  fontsize=annotation_font_size)

    #arrows!(a_ei,[0.07], [0.2], [0.25], [0.0], color=ColorSchemes.tab20[7])
    #text!(a_ei,0.09,0.1,text="Effort", color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)

    d1_color=ColorSchemes.tab20[9]
    d2_color=ColorSchemes.tab20[9]
    sol6aOA=sim(s6a;regulation=0.0)
    sol6bOA=sim(s6b;regulation=0.0)
    u0=sol6aOA.u[end][1:sol6aOA.prob.p.N]
    y0=sol6aOA.u[end][sol6aOA.prob.p.N+1]
    sol6a=sim(s6a;regulation=0.9,u0, y0)
    u0=sol6bOA.u[end][1:sol6bOA.prob.p.N]
    y0=sol6bOA.u[end][sol6bOA.prob.p.N+1]
    sol6b=sim(s6b;regulation=0.9,u0, y0)
    oa_plot!(a_d,s6b)
   # Φ_plot!(a_d,sol6a, color=d1_color, linewidth=1)
    Φ_plot!(a_d,sol6b, color=d2_color, linewidth=1)
   # Φ_plot!(a_d,sol6a, color=d1_color, linewidth=1, t=1000.0)
    Φ_plot!(a_d,sol6b, color=d2_color, linewidth=1, t=1000.0)
    Γ_plot!(a_d,sol6b, color=d1_color, t=1000.0)
   # attractor_plot!(a_d,sim(s6a;regulation=0.0), color=:darkgray, markersize=20)
    attractor_plot!(a_d,sim(s6b;regulation=0.0), color=:darkgray, markersize=20)
    #attractor_plot!(a_d,sim(s6a;regulation=0.9), color=ColorSchemes.tab20[9], markersize=20)
    attractor_plot!(a_d,sim(s6b;regulation=0.9), color=ColorSchemes.tab20[9], markersize=20)
    #trajecory_plot!(a_d,sol6a, color=d1_color, linewidth=4)
    trajecory_plot!(a_d,sol6b, color=d2_color, linewidth=4)
    #arrows!(a_d,[0.15], [0.78], [0.18], [-0.08], color=d2_color, linewidth=2)
    #text!(a_d,0.0, 0.99,text="Environmental\nKuznets\ntrajectory", align=(:left,:top),color=d2_color, font=:bold, fontsize=annotation_font_size)
   # text!(a_d,0.55, 0.3,text="Development\nwith high \ninitial impact", align=(:left,:top),color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)
    arrow_arc_deg!(a_d, [1.0,0.0], 0.55, -29,-52, color=d2_color, linewidth=2, linestyle=:solid, flip_arrow=true)
    text!(a_d,0.62,0.5,text="Technological\ndevelopment\nū(t)", color=d2_color, font=:bold, fontsize=annotation_font_size, glowcolor = (:white, 1.0), glowwidth=5.0)
    text!(a_d,0.38,0.68, text="trajectory →", rotation=-pi/4-0.4, color=d2_color, fontsize=annotation_font_size)
    arrows!(a_d,[0.07], [0.2], [0.4], [0.0], color=d2_color, linewidth=2)
    text!(a_d,0.02,0.05,text="Socio-economic\ndevelopment w̃(t)", color=d2_color, font=:bold, fontsize=annotation_font_size)

    
    incomes_plot!(b_oa_1, sim(s1,regulation=0.0),color=:lightgray)
    text!(b_oa_1,0.0,0.8,text=incometext(incomes(sim(s1,regulation=0.0))), space=:relative,fontsize=annotation_font_size)
    text!(b_oa_1,0.1,0.5, text="Resource revenue\nsurplus", space=:relative)
    arrows!(b_oa_1,[0.1], [0.45], [0.0], [-0.16], color=:black, space=:relative)

    text!(b_oa_1,0.6,0.6, text="Alternative\nincomes only", space=:relative)
    arrows!(b_oa_1,[0.7], [0.75], [0], [-0.2], color=:black, space=:relative)
  

    incomes_plot!(b_aur_1, sim(s2a,regulation=0.5), color=ColorSchemes.tab20[1])
    incomes_plot!(b_aur_2, sim(s2b,regulation=0.47), color=ColorSchemes.tab20[2])
    text!(b_aur_1,0.53,0.45,text="High w̃\nexclusion", space=:relative,fontsize=annotation_font_size)
    text!(b_aur_2,0.1,0.3,text="Low w̃\nexclusion", space=:relative,fontsize=annotation_font_size)
    text!(b_aur_1,0.0,0.8,text=incometext(incomes(sim(s2a,regulation=0.5))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[1])
    text!(b_aur_2,0.0,0.8,text=incometext(incomes(sim(s2b,regulation=0.47))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[2])

    incomes_plot!(b_tur_1, sim(s3a,regulation=0.5), color=ColorSchemes.tab20[3])
    incomes_plot!(b_tur_2, sim(s3b,regulation=0.5), color=ColorSchemes.tab20[4])
    text!(b_tur_1,0.0,0.5,text="Equal Use right distribution", space=:relative,fontsize=annotation_font_size)
    text!(b_tur_2,0.0,0.5,text="Historical (OA)\nuse right distribution", space=:relative,fontsize=annotation_font_size)
    text!(b_tur_1,0.52,0.0,text="Trade", space=:relative,fontsize=annotation_font_size, color=:black)
    arrows!(b_tur_1,[0.25], [0.1], [0.6], [0.0], linewidth=3, color=:black, space=:relative)
    arrow_arc_deg!(b_tur_1, [0.7,0.15], 0.1, 180,90,  color=:black, linewidth=1, linestyle=:solid, flip_arrow=true, space=:relative)
    #arrow_arc_deg!(b_tur_1, [0.25,0.15], 0.9, 180,170,  color=:black, linewidth=1, linestyle=:solid, flip_arrow=true, space=:relative)
   
    text!(b_tur_1,0.0,0.8,text=incometext(incomes(sim(s3a,regulation=0.5))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[3])
    text!(b_tur_2,0.0,0.8,text=incometext(incomes(sim(s3b,regulation=0.5))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[4])


    incomes_plot!(b_pa1, sim(s4a,regulation=pa_reg1), color=ColorSchemes.tab20[5])
    incomes_plot!(b_pa2, sim(s4b,regulation=pa_reg2), color=ColorSchemes.tab20[6])
    text!(b_pa1,0.05,0.45,text="Low mobility ($(s4a.m))\n$(round(pa_reg1*100, digits=0))% protected", space=:relative,fontsize=annotation_font_size)
    text!(b_pa2,0.05,0.45,text="High mobility ($(s4b.m))\n$(round(pa_reg2*100, digits=0))% protected", space=:relative,fontsize=annotation_font_size)
    text!(b_pa1,0.0,0.8,text=incometext(incomes(sim(s4a,regulation=pa_reg1))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[5])
    text!(b_pa2,0.0,0.8,text=incometext(incomes(sim(s4b,regulation=pa_reg2))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[6])
  
    incomes_plot!(b_ei_1, sim(s5a,regulation=0.4), color=ColorSchemes.tab20[7])
    incomes_plot!(b_ei_2, sim(s5b,regulation=0.4), color=ColorSchemes.tab20[8])
    text!(b_ei_1,0.0,0.8,text=incometext(incomes(sim(s5a,regulation=0.4))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[7])
    text!(b_ei_2,0.0,0.8,text=incometext(incomes(sim(s5b,regulation=0.4))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[8])

    #linkyaxes!([b_oa_1,b_tur_1,b_tur_2,b_aur_1,b_aur_2,b_pa1,b_pa2,b_ei_1,b_ei_2]...)



  

    text!(b_tur_1,10,0.008, text="Equal use rights")
    text!(b_tur_2,10,0.008, text="Historical use rights")

    text!(b_ei_1,10,0.007, text="Taxes")
    text!(b_ei_2,10,0.007, text="Impact")

    Ri=[sum(incomes(u,sol6b.prob.p).resource) for u in sol6b.u]  
    Ti=[sum(incomes(u,sol6b.prob.p).total) for u in sol6b.u]  
    Gi=[incomes(u,sol6b.prob.p).gini for u in sol6b.u] 
    Ei=[u[end] for u in sol6b.u]   

        #t=Int(round(tt*length(sol6b.t)))
        #inc=incomes(sol6b.u[t],sol6b.prob.p)
        #scatter!(b_d,(1:length(inc.total)).-i*50,inc.total.+(i-1)*maximum(inc.total))
        #text!(b_d,-i*50,+(i-1)*maximum(inc.total),text=incometext(incomes(sim(s6b,regulation=tt))), space=:relative,fontsize=annotation_font_size, color=ColorSchemes.tab20[9])
        lines!(b_d,sol6b.t[1:(end-2)],Ri[1:(end-2)], label="Resource income", linewidth=3,color=:crimson)
        lines!(b_d,sol6b.t[1:(end-2)],Ti[1:(end-2)], label="Total income", linewidth=3,color=:darkorange)
        lines!(b_d,sol6b.t[1:(end-2)],Gi[1:(end-2)], label="Gini", linewidth=3,color=:purple)
        lines!(b_d,sol6b.t[1:(end-2)],Ei[1:(end-2)], label="Resource level", linewidth=3,color=:forestgreen)
        text!(b_d,150, 0.45,text="Environmental\nKuznets trajectory", fontsize=annotation_font_size)
    arrows!(b_d,[320],[0.45],[0],[-0.1])
        axislegend(b_d,position=:rb, framevisible=false)
    #text!(b_d,0.4,0.5,text="Work in \nProgress",fontsize=24, font=:bold, space=:relative)

    t="text"
    D=policy_descriptions()

    description_font_size=22
    textcolor=:black
    wrapwidth=2*base_size
    fontsize=30
    img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/Latex/OpenAccess.tex.png"))
    text!(t_oa,0.0,0.75,text=rich("Open\n\nAccess", color=ColorSchemes.tab20[13], font=:bold ;fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Open Fig.png"))
    image!(t_oa,rotr90(img))
    #text!(t_oa,0.0,0.9,text=D["Open Access"], word_wrap_width=wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)

    text!(t_aur,0.0,0.9,text=rich("Exclusive use rights", color=ColorSchemes.tab20[1], font=:bold; fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Regulation Fig.png"))
    image!(t_aur,rotr90(img))
    #text!(t_aur,0.0,0.9,text=D["Exclusive Use Rights"], word_wrap_width=wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)


    text!(t_tur,0.0,0.9,text=rich("Tradable use rights", color=ColorSchemes.tab20[3], font=:bold; fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Tradable Fig.png"))
    image!(t_tur,rotr90(img))
    #text!(t_tur,0.0,0.9,text=D["Tradable Use Rights"], word_wrap_width=wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)

text!(t_pa,0.0,0.9,text=rich("Protected areas", color=ColorSchemes.tab20[5], font=:bold; fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Protected Fig.png"))
image!(t_pa,rotr90(img))
#text!(t_pa,0.0,0.9,text=D["Protected Area"], word_wrap_width=wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)

img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Economic Fig.png"))
image!(t_ei,rotr90(img))
text!(t_ei,0.0,0.9,text=rich("Economic policy outcomes", color=ColorSchemes.tab20[7], font=:bold; fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)

#text!(t_ei,0.0,0.9,text=D["Economic Incentives"], word_wrap_width=wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)
 
text!(t_d,0.0,0.9,text=rich("Development", color=ColorSchemes.tab20[9], font=:bold; fontsize), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
img = load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/Development Fig.png"))
image!(t_d,rotr90(img))
#text!(t_d,0.0,0.9,text=D["Development"], word_wrap_width= wrapwidth, fontsize=description_font_size, font="georgia", space=:relative, align=(:left, :top), color=textcolor)
 Label(f[0,1],text="Policy Instrument", tellwidth=false, fontsize=25, font=:bold)
 Label(f[0,2],text="System\nOutcomes", tellwidth=false, fontsize=25, font=:bold)
 Label(f[0,3],text="Distributional\nEffects", tellwidth=false, fontsize=25, font=:bold)

f
end
f4=newFig4()
save(homedir()*"/.julia/dev/SocialEconomicDiversity/figures/figure4.png",f4)

incometext(incomes)="R:"*string(round(sum(incomes.resource),digits=2))*"  T:"*string(round(sum(incomes.total),digits=2))*"  G:"*string(round(incomes.gini,digits=2))



function compPA(s,s2)
    f=Figure(size=(400,600))
    a=Axis(f[1,1])
    phase_plot!(a,s, show_oa=false)
    phase_plot!(a,s2, show_oa=false)
    b=Axis(f[2,1])
    [attractor_plot!(b,sim(s2.prob.p,regulation=r), color=:crimson, markersize=4) for r in range(1/100,stop=1-1/100,length=100)]
    [attractor_plot!(b,sim(s.prob.p,regulation=r), color=:steelblue, markersize=4) for r in range(1/100,stop=1-1/100,length=100)]
    f
end


function testPA(;regulation=0.2)
    a=scenario(s,policy="Protected Area", m=0.3)
    b=scenario(s,policy="Protected Area Two Pop", m=0.3)
    r=range(0.0, stop=1.0,length=100)
    sa=sim(a;regulation)
    sb=sim(b;regulation)
    f=Figure()
    ax=Axis(f[1,1])
   # lines!(ax,sa.t,sa[end,:])
    #lines!(ax,sb.t,sb[end-1,:])
    ##lines!(ax,sa.t,sum(sa[1:a.N,:], dims=1)[:])
    #lines!(ax,sb.t,sum(sb[1:a.N,:],dims=1)[:])
    PA=[sim(a;regulation)[end,end] for regulation in r]
    PA2P=[sim(b;regulation)[end-1,end] for regulation in r]
    lines!(ax,r,PA)
    lines!(ax,r,PA2P)
    f
end



function getfeatures(q)
    pol=unique([g.policy for g in GR3])
    return[median(q.w̃), median(q.ū), std(q.w̃), std(q.ū), cor(q.w̃,q.ū),q.relative_score,q.relative_RR,q.relative_ToR, q.relative_GI,findall(q.policy.==pol)[1]]
end

function makeMatrix(G)
   N=[]
   j=1
    for i in 1:length(G)
        f=getfeatures(G[i])
        if !isnan(sum(f))
            push!(N,f)
        end
    end
    M=zeros(10,length(N))
    for i in 1:length(N)
        M[:,i]=N[i]
    end
    return M
end

M=makeMatrix(GR3)
embedding=umap(M[1:9,:],2)

f=Figure(size=(1000,1000))
T=["median(w̃)","median(ū)","cor(w̃,ū)","std(w̃)","std(ū)","Policies","Resource","Total","Gini"]
A=[]
k=1
for i in 1:3
    for j in 1:3
        push!(A,Axis(f[j,i], title=T[k]))
        hidedecorations!(A[k])
        k+=1
    end
end
ms=4

scatter!(A[1],embedding[1,:], embedding[2,:], color=M[1,:], markersize=ms)
scatter!(A[2],embedding[1,:], embedding[2,:], color=M[2,:], markersize=ms)
scatter!(A[3],embedding[1,:], embedding[2,:], color=M[5,:], markersize=ms)

scatter!(A[4],embedding[1,:], embedding[2,:], color=M[3,:], markersize=ms)
scatter!(A[5],embedding[1,:], embedding[2,:], color=M[4,:], markersize=ms)
scatter!(A[6],embedding[1,:], embedding[2,:], color=M[10,:], markersize=ms)

scatter!(A[7],embedding[1,:], embedding[2,:], color=M[7,:], markersize=ms)
scatter!(A[8],embedding[1,:], embedding[2,:], color=M[8,:], markersize=ms)
scatter!(A[9],embedding[1,:], embedding[2,:], color=M[9,:], markersize=ms)


f