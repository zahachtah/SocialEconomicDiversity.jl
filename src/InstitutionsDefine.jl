#=
TRY HAVING INCOMES ABOVE AND BELOW AND PHASEPLOTS IN THE MIDDLE????

=#
oldFig4()

function newFig4(; labelsize=25,annotation_font_size=18,s=high_impact(N=100))
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
    base_size=300
    f=Figure(size=(4*base_size,6*base_size))
    a_oa=Axis(f[1:2,2])#,title=s1.policy)
    a_aur=Axis(f[3:4,2])#,title=s2a.policy)
    a_tur=Axis(f[5:6,2])#,title=s3a.policy)
    a_pa=Axis(f[7:8,2])#,title=s4a.policy)
    a_ei=Axis(f[9:10,2])#,title=s5.policy)
    a_d=Axis(f[11:12,2])#,title=s6.policy)
    [hidedecorations!(a) for a in [a_oa,a_aur,a_tur,a_pa,a_ei, a_d]]
    b_oa=Axis(f[1:2,3])#,title=s1.policy)
    b_aur_1=Axis(f[3,3])#,title=s2a.policy)
    b_aur_2=Axis(f[4,3])#,title=s2a.policy)
    b_tur=Axis(f[5:6,3])#,title=s3a.policy)
    b_pa=Axis(f[7:8,3])#,title=s4a.policy)
    b_ei=Axis(f[9:10,3])#,title=s5.policy)
    b_d=Axis(f[11:12,3])#,title=s6.policy)
    [hidedecorations!(a) for a in [b_oa,b_aur_1,b_aur_2,b_tur,b_pa,b_ei, b_d]]
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
    pa_plot!(a_pa,s4a)

    incomes_plot!(b_tur, sim(s3a,regulation=0.51))
    incomes_plot!(b_aur_1, sim(s2a,regulation=0.4))
    incomes_plot!(b_aur_2, sim(s2b,regulation=0.4))
    incomes_plot!(b_pa, sim(s4a,regulation=0.4))

    t="text"
    D=policy_descriptions()
    text!(t_tur,0.0,0.9,text=rich("Tradable use rights", color=:forestgreen, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
    text!(t_tur,0.0,0.9,text=D["Tradable Use Rights"], word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))

text!(t_pa,0.0,0.9,text=rich("Protected areas", color=:forestgreen, font=:bold, fontsize=25), word_wrap_width=440, fontsize=18, font="georgia", space=:relative)
text!(t_pa,0.0,0.9,text=L"Some %$(t) and some math: $\frac{2\alpha+1}{y}$, Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.", word_wrap_width= base_size*2*0.9, fontsize=18, font="georgia", space=:relative, align=(:left, :top))
    f
end

newFig4()


function policy_descriptions()
    D=Dict()
    D["Tradable Use Rights"]=L"are formalized as a cost/revenue that is proportional to wether one extracts resource above or below one's alloted use rights and the current price, $I(u_i)=(R_i-u_i) \phi$. Thus we approximate discrete transaction as a continuous rent as if the transaction is equivalent to paying a continuous rent for a loan or getting the interest for an investment of gained capital (by selling the use right). The price of the use rights is set by the supply (currently unused use rights) vs the demmand (sum of potential desire to increase $\sum \left( \max \left( \dot{u}_i,0 \right) \right)$. The resulting incentives are additive: $\gamma=\tilde{w}+\phi$"
    return D
end

Tradable use rights are modeled to capture the dynamics of resource allocation and usage. The equations describe how individual utility depends on direct usage, costs from deviations in allocation, and market-based rights values. Resource utilization changes based on yield and costs, with limits set by predefined caps. The value of tradable rights adjusts dynamically with market demand and supply, influencing the overall costs of usage. These equations provide a framework for understanding how tradable rights integrate market forces into resource management, promoting efficiency and sustainability.

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

newFig4()

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