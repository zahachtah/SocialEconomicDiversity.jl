

#=
* understand the bump in PA incomes for resource users...
* do better economic incentives. royalties and 

=#



function policy_descriptions()
    D=Dict()
    D["Tradable Use Rights"]=L"are formalized as a cost/revenue that is proportional to wether one extracts resource above or below one's alloted use rights and the current price, $I(u_i)=(R_i-u_i) \phi$. Thus we approximate discrete transaction as a continuous rent as if the transaction is equivalent to paying a continuous rent for a loan or getting the interest for an investment of gained capital (by selling the use right). The price of the use rights is set by the supply (currently unused use rights) vs the demmand (sum of potential desire to increase $\sum \left( \max \left( \dot{u}_i,0 \right) \right)$. The resulting incentives are additive: $\gamma=\tilde{w}+\phi$"
    D["Assigned Use Rights"]=L"are formalized as a cost/revenue that is proportional to wether one extracts resource above or below one's alloted use rights and the current price, $I(u_i)=(R_i-u_i) \phi$. Thus we approximate discrete transaction as a continuous rent as if the transaction is equivalent to paying a continuous rent for a loan or getting the interest for an investment of gained capital (by selling the use right). The price of the use rights is set by the supply (currently unused use rights) vs the demmand (sum of potential desire to increase $\sum \left( \max \left( \dot{u}_i,0 \right) \right)$. The resulting incentives are additive: $\gamma=\tilde{w}+\phi$"
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

function aur_plot!(a,s; colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    oa_plot!(a,s)
    Γ_plot!(a,sol;color)
    Φ_plot!(a,sol, linewidth=1; color)
    attractor_plot!(a,sol; color)
    arrows!(a,[0.05],[0.25],[0.0],[0.72], linewidth=1; color)
    arrows!(a,[0.05],[1.0],[0.0],-[0.72], linewidth=1;color)
    text!(a,0.07,0.85,text="high w̃ excluded",  font=:bold, fontsize=annotation_font_size;color)

    arrows!(a,[0.14],[0.0],[0.0],[0.72], linewidth=1;color)
    arrows!(a,[0.14],[0.75],[0.0],-[0.72], linewidth=1;color)
    text!(a,0.16,0.5,text="low w̃ excluded", font=:bold, fontsize=annotation_font_size;color)
    attractor_plot!(a,sol; color)                     
end

function tur_plot!(a,s; colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    oa_plot!(a,s)
    Γ_plot!(a,sol; color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol; color)
    target_plot!(a,sol, linewidth=2;color)

    arrows!(a,[0.1], [0.5], [0.4], [0.0]; color)
    text!(a,0.12,0.52,text="Price ϕ=0.45", font=:bold, fontsize=annotation_font_size;color)
    text!(a,0.52,0.11,text="Yield limit=0.25", font=:bold, rotation=-pi/17, fontsize=annotation_font_size;color)
    text!(a,0.55,0.27,text="Effort limit=0.5", font=:bold, fontsize=annotation_font_size;color)
    attractor_plot!(a,sol;color)
end

function pa_plot!(a,s;colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
#=
pa1_sol=sim(s;regulation=0.3)
pa2_sol=sim(s;regulation=0.5)
pa3_sol=sim(s;regulation=0.7)
pa4_sol=sim(s;regulation=0.8)
pa5_sol=sim(s;regulation=0.9)
pa6_sol=sim(s;regulation=0.95)
=#
oa_plot!(a,s)

color=colorscheme[colorid]
cases=[s]
[Γ_plot!(a,sim(s;regulation);color) for sol in cases]
[Φ_plot!(a,sim(s;regulation); color,linewidth=1) for sol in cases]
APA=[sim(s;regulation=r) for r in range(0.0,stop=1.0,length=40)]
[attractor_plot!(a,sim(s;regulation=r), color=color, markersize=8) for r in range(0.0,stop=1.0,length=40)]
#arrow_arc!(a4, [0.0,0.0], 0.75, pi/2-pi/10, pi/8)
arrow_arc_deg!(a, [0.0,0.0], 0.85, 14, 37, color=color, linewidth=1, linestyle=:solid)
text!(a,0.26,0.82,text="Exclusion", color=color, font=:bold, rotation=-pi/8, fontsize=annotation_font_size)
arrow_arc_deg!(a, [0.7,0.16], 0.35, -59, -34, color=color, linewidth=1, linestyle=:solid)
text!(a,0.45,0.22,text="Spillover", color=color, font=:bold, rotation=pi/4, fontsize=annotation_font_size)
attractor_plot!(a,sim(s;regulation=0.3), color=color, markersize=8)
attractor_plot!(a,sim(s;regulation=0.8), color=color, markersize=8)
text!(a,0.16,0.53,text="fₚ=0.3", color=color, font=:bold, fontsize=annotation_font_size)
text!(a,0.53,0.56,text="fₚ=0.8", color=color, font=:bold, fontsize=annotation_font_size)
end

function ei_plot!(a,s;colorid=1, colorscheme=ColorSchemes.tab20, regulation=0.75, annotation_font_size=18)
    color=colorscheme[colorid]
    sol=sim(s;regulation)
    oa_plot!(a,s)
    Γ_plot!(a,sol; color)
    Φ_plot!(a,sol, linewidth=1;color)
    attractor_plot!(a,sol; color)
end



function oldFig4()# using SocialEconomicDiversity, CairoMakie
set_theme!(theme_light())
labelsize=25
annotation_font_size=18
annotation_font_color=:black
#Test with historical use rights
s=high_impact(N=100)
s1=scenario(s,policy="Open Access")
s2a=scenario(s,policy="Assigned Use Rights", reverse=true)
s2b=scenario(s,policy="Assigned Use Rights", reverse=false)
s3a=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
s3b=scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
s4a=scenario(s,policy="Protected Area", m=0.3)
s4b=scenario(s,policy="Protected Area", m=0.3)
s5=scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
s6a=scenario(s,policy="Development")
s6b=scenario(SocialEconomicDiversity.change(s,ū=sed(mean=0.5,sigma=0.0, normalize=true)),policy="Development")

# Switch back to using "regulation" instead of regulation

regulation=0.5
f=Figure(size=(1200+300,1800))
a1=Axis(f[1,3])#,title=s1.policy)
a2=Axis(f[2,3])#,title=s2a.policy)
a3=Axis(f[3,3])#,title=s3a.policy)
a4=Axis(f[4,3])#,title=s4a.policy)
a5=Axis(f[5,3])#,title=s5.policy)
a6=Axis(f[6,3])#,title=s6.policy)
d6=Axis(f[6,4])#,title=s6.policy)
[hidedecorations!(a) for a in [a1,a2,a3,a4,a5]]

#Open access
oa_color=ColorSchemes.tab20[16]
sol=sim(s1;regulation=0.0)

bg_plot!(a1)
Γ_plot!(a1,sol, color=oa_color)
Φ_plot!(a1,sol, color=oa_color, linewidth=1)
attractor_plot!(a1,sol, color=oa_color)
trajecory_plot!(a1,sol, color=oa_color)

#assigned use rights
aur1_color=ColorSchemes.tab20[1]
aur2_color=ColorSchemes.tab20[2]
sol2a=sim(s2a;regulation=0.75)
sol2b=sim(s2b;regulation=0.75)
bg_plot!(a2)
Γ_plot!(a2,sol, color=oa_color)
Γ_plot!(a2,sol2a, color=aur1_color)
Γ_plot!(a2,sol2b, color=aur2_color)
Φ_plot!(a2,sol2a, color=oa_color, linewidth=1)
attractor_plot!(a2,sol2a, color=aur1_color)
attractor_plot!(a2,sol2b, color=aur2_color)
arrows!(a2,[0.05],[0.25],[0.0],[0.72],color=aur1_color, linewidth=1)
arrows!(a2,[0.05],[1.0],[0.0],-[0.72],color=aur1_color, linewidth=1)
text!(a2,0.07,0.85,text="high w̃ excluded", color=aur1_color, font=:bold, fontsize=annotation_font_size)

arrows!(a2,[0.14],[0.0],[0.0],[0.72],color=aur2_color, linewidth=1)
arrows!(a2,[0.14],[0.75],[0.0],-[0.72],color=aur2_color, linewidth=1)
text!(a2,0.16,0.5,text="low w̃ excluded", color=aur2_color, font=:bold, fontsize=annotation_font_size)
attractor_plot!(a2,sol, color=oa_color)

#tradable use rights
tur1_color=ColorSchemes.tab20[3]
tur2_color=ColorSchemes.tab20[4]
sol3a=sim(s3a;regulation=0.51)
sol3b=sim(s3b;regulation=0.75)
bg_plot!(a3)
Γ_plot!(a3,sol, color=oa_color)
Γ_plot!(a3,sol3a, color=tur1_color)
Γ_plot!(a3,sol3b, color=tur2_color)
Φ_plot!(a3,sol3a, color=oa_color, linewidth=1)
attractor_plot!(a3,sol3a, color=tur1_color)
attractor_plot!(a3,sol3b, color=tur2_color)
target_plot!(a3,sol3a,color=tur1_color, linewidth=2)
target_plot!(a3,sol3b,color=tur2_color, linewidth=2)
arrows!(a3,[0.1], [0.5], [0.4], [0.0], color=tur1_color)
text!(a3,0.12,0.52,text="Price ϕ=0.45", color=tur1_color, font=:bold, fontsize=annotation_font_size)
text!(a3,0.52,0.11,text="Yield limit=0.25", color=tur2_color, font=:bold, rotation=-pi/17, fontsize=annotation_font_size)
text!(a3,0.55,0.27,text="Effort limit=0.5", color=tur1_color, font=:bold, fontsize=annotation_font_size)
attractor_plot!(a3,sol, color=oa_color)


#Understand why regulation=0.0 || start_oa=true makes error for Protected Area!
pa1_color=ColorSchemes.tab20[5]
pa2_color=ColorSchemes.tab20[6]
pa1_sol=sim(s4b;regulation=0.3)
pa2_sol=sim(s4b;regulation=0.5)
pa3_sol=sim(s4b;regulation=0.7)
pa4_sol=sim(s4b;regulation=0.8)
pa5_sol=sim(s4b;regulation=0.9)
pa6_sol=sim(s4b;regulation=0.95)
bg_plot!(a4)
Φ_plot!(a4,sol, color=oa_color, linewidth=1)
Γ_plot!(a4,sol, color=oa_color)
cases=[pa4_sol]
[Γ_plot!(a4,sol, color=pa1_color) for sol in cases]
[Φ_plot!(a4,sol, color=pa1_color, linewidth=1) for sol in cases]
APA=[sim(s4b;regulation=r) for r in range(0.0,stop=1.0,length=40)]
[attractor_plot!(a4,sim(s4b;regulation=r), color=pa2_color, markersize=8) for r in range(0.0,stop=1.0,length=40)]
#arrow_arc!(a4, [0.0,0.0], 0.75, pi/2-pi/10, pi/8)
arrow_arc_deg!(a4, [0.0,0.0], 0.85, 14, 37, color=pa1_color, linewidth=1, linestyle=:solid)
text!(a4,0.26,0.82,text="Exclusion", color=pa1_color, font=:bold, rotation=-pi/8, fontsize=annotation_font_size)
arrow_arc_deg!(a4, [0.7,0.16], 0.35, -59, -34, color=pa1_color, linewidth=1, linestyle=:solid)
text!(a4,0.45,0.22,text="Spillover", color=pa1_color, font=:bold, rotation=pi/4, fontsize=annotation_font_size)
attractor_plot!(a4,sim(s4b;regulation=0.3), color=pa1_color, markersize=8)
attractor_plot!(a4,sim(s4b;regulation=0.8), color=pa1_color, markersize=8)
text!(a4,0.16,0.53,text="fₚ=0.3", color=pa1_color, font=:bold, fontsize=annotation_font_size)
text!(a4,0.53,0.56,text="fₚ=0.8", color=pa1_color, font=:bold, fontsize=annotation_font_size)
attractor_plot!(a4,sol, color=oa_color)

# Economic incentives
ei1_color=ColorSchemes.tab20[7]
ei2_color=ColorSchemes.tab20[8]
phase_plot!(a5,sim(s5;regulation))

#development
d1_color=ColorSchemes.tab20[9]
d2_color=ColorSchemes.tab20[10]
sol6a=sim(s6a;regulation)
sol6b=sim(s6b;regulation)
Γ_plot!(a6,sol, color=oa_color)
Φ_plot!(a6,sol6a, color=d1_color, linewidth=1)
Φ_plot!(a6,sol6b, color=d2_color, linewidth=1)
Γ_plot!(a6,sol6a, color=d1_color)
attractor_plot!(a6,sim(s6a;regulation=0.0), color=oa_color, markersize=8)
attractor_plot!(a6,sim(s6a;regulation=1.0), color=oa_color, markersize=8)
attractor_plot!(a6,sim(s6b;regulation=1.0), color=oa_color, markersize=8)
trajecory_plot!(a6,sol6a, color=d1_color)
trajecory_plot!(a6,sol6b, color=d2_color)
#phase_plot!(a6,sol6a,show_trajectory=true, t=0.0)
#phase_plot!(a6,sol,show_trajectory=true, t=500.0)
#phase_plot!(a6,sol6a,show_trajectory=true, t=1000.0, show_exploitation=false)
#phase_plot!(a6,sol6b,show_trajectory=true, t=1000.0, show_exploitation=false)

a12=Axis(f[1,2],aspect=DataAspect(),width=320)
hidespines!(a12)
hidedecorations!(a12)
img=load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/Latex/OpenAccess.tex.png"))
image!(a12, rotr90(img))

a32=Axis(f[3,2],aspect=DataAspect(),width=320)
hidespines!(a32)
hidedecorations!(a32)
img=load(assetpath(homedir()*"/.julia/dev/SocialEconomicDiversity/Latex/TradableUseRights_short.tex.png"))
image!(a32, rotr90(img))


a11=Axis(f[1,1], width=450,limits=(0,1,0,1))
hidespines!(a11)
hidedecorations!(a11)
text!(a11,0.0,0.9,text=rich("Open access", color=:darkgray, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a11,0.0,0.9,text="In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor.  In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor.  In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

a21=Axis(f[2,1], width=450,limits=(0,1,0,1))
hidespines!(a21)
hidedecorations!(a21)
text!(a21,0.0,0.9,text=rich("Assigned use rights", color=aur1_color, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a21,0.0,0.9,text="In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor.  In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor.  In the absence of any policy incentives, actors base their use of resource on the incentives provided by the alternative opportunity cost such as wage labor", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))


a31=Axis(f[3,1], width=450,limits=(0,1,0,1))
hidespines!(a31)
hidedecorations!(a31)
text!(a31,0.0,0.9,text=rich("Tradable use rights", color=tur1_color, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a31,0.0,0.9,text="Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))



a41=Axis(f[4,1], width=450,limits=(0,1,0,1))
hidespines!(a41)
hidedecorations!(a41)
t="text"
text!(a41,0.0,0.9,text=rich("Protected areas", color=pa1_color, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a41,0.0,0.9,text=L"Some %$(t) and some math: $\frac{2\alpha+1}{y}$, Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

a51=Axis(f[5,1], width=450,limits=(0,1,0,1))
hidespines!(a51)
hidedecorations!(a51)
text!(a51,0.0,0.9,text=rich("Economic incentives", color=ei1_color, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a51,0.0,0.9,text="Taxes & subsidies can be implemented to adjust the incentives of user by affecting the price of the resource or the cost of extraction. Subsidies move the inentives left while taxes move them right. Indirectly, economic incentives such as loans for gear can result in an increase in impact curve downward or by applying a fee for certain gears can move the impact curve up.", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

a61=Axis(f[6,1], width=450,limits=(0,1,0,1))
hidespines!(a61)
hidedecorations!(a61)
text!(a61,0.0,0.9,text=rich("Development trajectories", color=ColorSchemes.tab20[9], font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(a61,0.0,0.9,text="Alternative income opportunitites and harvest efficiencies increase as development proceeds over time. As a result, both incentive and impact curves change. For a high impact starting point this means a steady increase in resource levels as the effect of incentives outweighs the effect of higher impacts. For a low impact starting point, we find a Kuznets type behavior with initial reduction in resource levels and subsequent recovery.", word_wrap_width=440, fontsize=18, font="georgia", space=:relative, align=(:left, :top))



Label(f[0,1], "Policy instruments:", fontsize=labelsize, tellwidth=false,color=:black, font=:bold, halign=:left)
Label(f[0,2], "Formalization", fontsize=labelsize, tellwidth=false,color=:black, font=:bold)
Label(f[0,3], "Visualization", fontsize=labelsize, tellwidth=false,color=:black, font=:bold)
Label(f[0,4], "Distributional outcomes", fontsize=labelsize, tellwidth=false,color=:black, font=:bold)

a14=Axis(f[1,4])
a24=Axis(f[2,4])
a34=Axis(f[3,4])
a44=Axis(f[4,4])
a54=Axis(f[5,4])
a64=Axis(f[6,4])

incomes_plot!(a14, sol, color=ColorSchemes.tab20[16])
incomes_plot!(a24, sol2a, color=aur1_color)
incomes_plot!(a34, sol3a, color=tur1_color)
incomes_plot!(a44, pa1_sol, color=pa1_color)
incomes_plot!(a54, sim(s5;regulation), color=ei1_color)
incomes_plot!(a64,sim(s6a;regulation), color=ColorSchemes.tab20[9])

linkyaxes!([a14,a24,a34,a44,a54,a64]...)

println(sum(incomes(sol3a.u[end-1],sol3a.prob.p).trade))
f
end
#ftemp
oldFig4()
#save("figures/Figure_4.png",f)

#= Do universal basic incomes add to w̃ or do they max(w̃,UBI)? UBI does not "take away" from ū as it is not linked to use of time, meaning that alternative opporunities are added on top of UBI?

1) protected area, does decreased impact change revenues?
2) gear economic incentives, how to link to regulation? go back to the version with effort cost (fuel cost)
fuel subsidy increased revenue has to outweigh the loan cost
3) universal basic incomes, additive to incentives? 

w/pKq

ēq/r


=#



function newFig4(; labelsize=25,annotation_font_size=18,s=high_impact(N=100))
    s1=scenario(s,policy="Open Access")
    s2a=scenario(s,policy="Assigned Use Rights", reverse=true)
    s2b=scenario(s,policy="Assigned Use Rights", reverse=false)
    s3a=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
    s3b=scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
    s4a=scenario(s,policy="Protected Area", m=0.3)
    s4b=scenario(s,policy="Protected Area", m=0.3)
    s5a=scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:subsidy)
    s5b=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
    s5c=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:subsidy)
    s5d=scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:additive)
    s6a=scenario(s,policy="Development")
    s6b=scenario(SocialEconomicDiversity.change(s,ū=sed(mean=0.5,sigma=0.0, normalize=true)),policy="Development")
    base_size=300
    f=Figure(size=(4*base_size,6*base_size))
    a_oa=Axis(f[1:2,2])#,title=s1.policy)
    a_aur=Axis(f[3:4,2])#,title=s2a.policy)
    a_tur=Axis(f[5:6,2])#,title=s3a.policy)
    a_pa=Axis(f[7:8,2])#,title=s4a.policy)
    a_ei=Axis(f[9:10,2])#,title=s5.policy)
    a_d=Axis(f[11:12,2])#,title=s6.policy)
    [hidedecorations!(a) for a in [a_oa,a_aur,a_tur,a_pa,a_ei, a_d]]
    b_oa_1=Axis(f[2,3])#,title=s1.policy)
    b_aur_1=Axis(f[3,3])#,title=s2a.policy)
    b_aur_2=Axis(f[4,3])#,title=s2a.policy)
    b_tur=Axis(f[5:6,3])#,title=s3a.policy)
    b_pa=Axis(f[7:8,3])#,title=s4a.policy)
    b_ei=Axis(f[9:10,3])#,title=s5.policy)
    b_d=Axis(f[11:12,3])#,title=s6.policy)
    [hidedecorations!(a) for a in [b_oa_1,b_aur_1,b_aur_2,b_tur,b_pa,b_ei, b_d]]
    t_oa=Axis(f[1:2,1])#,title=s1.policy)
    t_aur=Axis(f[3:4,1])#,title=s2a.policy)
    t_tur=Axis(f[5:6,1])#,title=s3a.policy)
    t_pa=Axis(f[7:8,1])#,title=s4a.policy)
    t_ei=Axis(f[9:10,1])#,title=s5.policy)
    t_d=Axis(f[11:12,1])#,title=s6.policy)
    [hidedecorations!(a) for a in [t_oa,t_aur,t_tur,t_pa,t_ei, t_d]]
    colsize!(f.layout, 1, Relative(1/2))

    oa_plot!(a_oa,s1)
    aur_plot!(a_aur,s2a)
    tur_plot!(a_tur,s3a, regulation=0.51, colorid=3)
    tur_plot!(a_tur,s3b, regulation=0.75, colorid=4)

    pa_plot!(a_pa,s4a, colorid=5)

    ei_plot!(a_ei,s5a, colorid=7)
    ei_plot!(a_ei,s5b, colorid=7)
    ei_plot!(a_ei,s5c, colorid=7)
    ei_plot!(a_ei,s5d, regulation=0.3, colorid=7)
    arrow_arc_deg!(a_ei, [1.0,0.0], 0.65, -62, -29, color=ColorSchemes.tab20[7], linewidth=1, linestyle=:solid)
    text!(a_ei,0.55,0.3,text="Impact", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/4, fontsize=annotation_font_size)

    arrow_arc_deg!(a_ei, [0.0,0.0], 0.75, 4, 15, color=ColorSchemes.tab20[7], linewidth=1, linestyle=:solid)
    text!(a_ei,0.22,0.75,text="Taxes", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/3.7, fontsize=annotation_font_size)
    text!(a_ei,0.1,0.75,text="Subsidy", color=ColorSchemes.tab20[7], font=:bold, rotation=pi/2.7, fontsize=annotation_font_size)

    arrows!(a_ei,[0.07], [0.2], [0.25], [0.0], color=ColorSchemes.tab20[7])
    text!(a_ei,0.09,0.1,text="Effort", color=ColorSchemes.tab20[7], font=:bold, fontsize=annotation_font_size)

    incomes_plot!(b_oa_1, sim(s1,regulation=0.0),color=:lightgray)
    incomes_plot!(b_tur, sim(s3a,regulation=0.51))
    incomes_plot!(b_aur_1, sim(s2a,regulation=0.4), color=ColorSchemes.tab20[1])
    incomes_plot!(b_aur_2, sim(s2b,regulation=0.4), color=ColorSchemes.tab20[1])
    incomes_plot!(b_pa, sim(s4a,regulation=0.4), color=ColorSchemes.tab20[5])
    incomes_plot!(b_ei, sim(s5a,regulation=0.4), color=ColorSchemes.tab20[7])

    t="text"
    D=policy_descriptions()

    text!(t_aur,0.0,0.9,text=rich("Assigned use rights", color=ColorSchemes.tab20[1], font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    text!(t_aur,0.0,0.9,text=D["Assigned Use Rights"], word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))


    text!(t_tur,0.0,0.9,text=rich("Tradable use rights", color=ColorSchemes.tab20[3], font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    text!(t_tur,0.0,0.9,text=D["Tradable Use Rights"], word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

text!(t_pa,0.0,0.9,text=rich("Protected areas", color=ColorSchemes.tab20[5], font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(t_pa,0.0,0.9,text=L"Some %$(t) and some math: $\frac{2\alpha+1}{y}$, Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.", word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

text!(t_ei,0.0,0.9,text=rich("Economic incentives outcomes", color=ColorSchemes.tab20[7], font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(t_ei,0.0,0.9,text=L"Some %$(t) and some math: $\frac{2\alpha+1}{y}$, Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.", word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))
 

f
end

newFig4()

A=[589.4865906573609
366.67070792957264
216.93785327052396
302.5288323234998
234.06632251738944
122.35414922047433
174.53042518970602
183.60906788443307
92.55742220190153
130.8073682782511
159.0738616375296
90.48629470863057
83.27168378413818
116.99064100094421
68.02358827519843
63.75443490667514
91.3796199956171
38.64465037462717
84.06213859031816
108.94150415543484
70.28384852073327
49.3851109496771
85.31557355301408
49.73169634172356
64.26215460780381
84.66370878987328
63.30789180274938
57.77962433615445
73.82659723052456
58.84536726660069
55.109650795941434
60.03804783639951
48.62267369196728
55.106918059707006
55.4619280387479
41.08732517568975
60.35677118719205
47.82938679537384
54.91584227841971
52.08571754290816
48.20820626459376
47.173377105292936
43.561556253842625
44.3022723888005
44.11251724736009
31.394874190198603
66.61601995122496
51.44221798234953
61.19799519146081
56.445987372952544
57.51240725513332
44.67409403085755
69.57766141007532
62.46898423810543
44.87003758076772
44.36948199257567
51.242244650382666
41.19640684133477
61.01249610921051
55.602489003550474
46.221493596804294
42.48261488644373
53.30628796769631
43.64176556805315
56.49357231654731
53.03235021976818
41.62628766098176
38.06116808695323
51.560300282132076
43.20619969166664
50.884044795731974
47.68554564566209
42.02736828902211
38.2996359841663
46.38066772903712
38.24937349744786
48.99938428501235
43.678256827137034
42.386190882366755
39.86008241625324
39.47316282171603
35.69798512026968
38.88549094225851
32.19693887680479
45.57269925571166
37.30909118123676
46.97343090468348
45.30677504632995
32.94208337674557
28.49984540761868
46.64950909065058
40.498829375528146
36.815759303762704
35.63015548559852
35.0160042345216
28.507376897415764
47.12343055641343
42.026388228786644
34.92999175954086
34.11751049520554
33.856862357091224
28.31857857329691
43.42039851325967
37.838183908490564
36.60825325396827
33.53963739700123
37.705865013791716
30.020150065883787
47.14313450219063
44.45550777230652
28.39493948000591
32.77047520014946
31.014204113596875
15.370111503020496
66.54110169594468
70.64187863853698
28.310204454146877
66.4528347590067
74.04716550172863
30.884966883696077
63.214409792649334
52.6156415031679
42.43977442313867
57.68507260905981
20.116338671632214
68.09813536520883
45.06505270349682
68.01316386108992
71.58507996201621
54.684190446433725
46.81002636995099
55.013072021621916
22.5635171713815
31.892315106347155
50.435413647589264
21.905916810838367
84.56514975597332
82.2551643346911
40.156176374628494
59.90270171823273
60.362610699045625
38.67664104736705
61.474416871319754
62.59973275757094
28.902751253816668
40.194034362897526
24.935246836219754
47.81585355426154
23.449447779062393
78.84047557315026
75.016205886603
29.44885856994508
49.89508322939635
42.98917696286429
32.505070719840106
41.34381818723144
19.123968889943132
24.773881125824406
50.07951799582764
21.32643996234265
91.1323207617758
99.55663981704996
24.78982720437222
118.63960394371831
155.34510271817118
103.15629396193204
45.306380340896375
85.9677617947928
54.49260444148895
64.43293402835921
75.49804957354907
43.793135821038994
56.08170642505023
49.36406370650597
51.67642022196505
46.91956938695528
46.92230413273327
34.29012207415384
53.76386396692114
41.0976678568849
51.29805412890414
47.85376833880052
38.89381374957535
37.6601244384546
41.50632668497204
32.11286484529235
55.27993426267392
54.17954794815309
25.52838440250508
22.192398903494688
55.32156167511882
46.98644021518861
37.85957476234307
42.080238692161906
28.95323447375355
21.045051713345433
48.05791979220349
35.476754814680305
47.623178725225074
48.656536645375745
26.13654834778687
29.88266204755214
30.762151615165216
24.72113753442552
38.974452705064216
28.60396082670706
44.248663685746266
36.41412156628885
38.52230835536896
40.987948483200924
23.775066660580574
15.411824679415146
59.70463305480814
54.677798513021806
25.482898001452096
62.67490365964694
25.606612232510606
103.55965051670682
113.28447775320141
52.63696660135582
84.33002358312004
89.59915425613485
79.5109087123645
57.17606205465551
75.62840832453823
88.3967257017757
19.752572103112165
90.37837359500531
92.12142018180563
58.192460692424696
62.98638731466247
72.13612899757726
42.32529512714431
77.8775480871616
80.98610067969136
38.73257474933458
59.1500489036499
49.11952617597055
35.950048150477194
52.87606280070676
21.775424024623486
31.081229471051497
54.33376603204445
25.074261605467026
87.21417376947821
80.01564792518052
48.60516197937604
55.9077716182786
55.44294658871703
32.41818955930951
72.35383431144592
48.7369556055105
76.5060512224878
80.51275615910417
29.501293346825246
54.69935285224623
41.263841234151904
48.059346884359705
46.893134356445515
35.159401951820875
35.95490788761987
40.4477919575876
26.795302810312783
57.158657530766256
44.21351013477055
51.053303618064085
47.563427650173125
44.87384409962812
41.5347892895883
40.19489894424616
40.398417931643024
32.01641055563689
47.93805979587974
36.92056361315113
46.532239014113365
42.83268847539234
35.562835836477056
47.63046295053424
24.003473695958956
83.86458710173432
86.47909709306734
16.089788060090267
75.30673680449553
76.83952691823946
29.213529171405135
76.45029485261051
93.14936941892661
37.92260913925068
83.95653980329153
118.61404826689758
81.3091923129159
34.38581143451784
73.26839250488479
66.31146222970742
20.396461280690207
39.99450063734873
21.835332158150077
21.615817574381786
40.251318164797155
10.66781765217687
70.99574943119747
65.17891646844296
35.65152018168461
49.5077299839501
36.60630822414124
50.18250716068666
48.533499642251236
27.406877844932666
39.63848826017965
18.94384094209214
48.22238812340231
18.569119695287387
55.875142027512105
20.8343502851613
91.44230125233105
96.77580166567449
22.230803512829063
109.77062718384195
135.73276427188762
80.52653383541333
62.99936512490202
94.27090610739747
66.58978688930478
57.363019743349156
63.258717011592246
58.53031326106623
51.08366726402046
57.65325390471441
44.167689549619226
55.1561272406655
53.54734737148603
38.81867748533959
43.350696491164605
31.27659994744332
39.35544536179037
27.610293973104504
30.420650499789545
36.18985102113009
21.51180337087698
42.48233299633972
16.842250092730715
77.86057938222346
74.86719578217573
16.91816038649152
39.839193192342194
18.345182263909987
57.02032234622551
46.8654173802501
38.19302248379028
40.493391349166174
31.16638918764024
35.89543354957809
23.89410581088208
32.90732289988593
26.084504858267568
27.56718425504587
28.90989005213726
15.021901898130885
34.23965209006014
18.978835073773993
49.13885557050033
29.18001232952368
66.85472097552382
72.64942054139998
25.305347315666115
69.16118915723962
77.79629834787448
20.202254542996634
102.64361898225363
138.12406901548107
97.8606600665044
25.473323717876713
85.94692534501574
98.53780503630315
38.97503704056398
89.16574928193413
128.8990147854902
92.86856860008133
28.752481885660806
81.5110714583228
91.42817410689221
31.22780150835637
97.6931308178868
137.65639823598468
101.29581414518856
29.516258815528722
88.95859584153378
111.46870362360208
65.72841589414591
51.91343362221549
82.50898023656603
41.79827510765492
65.63720550339461
90.09377751512329
48.66749582248679
55.88819641388336
75.60984410717222
38.09821882686062
68.76777606130436
77.71881947020218
20.004059353739553
92.94641708644751
112.56158445950346
57.68738426049656
64.3767402579211
]