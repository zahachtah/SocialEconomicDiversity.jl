#using SocialEconomicDiversity, CairoMakie


#Test with historical use rights
s=high_impact()
s1=scenario(s,policy="Open Access")
s2a=scenario(s,policy="Assigned Use Rights", reverse=true)
s2b=scenario(s,policy="Assigned Use Rights", reverse=false)
s3a=scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
s3b=scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
s4a=scenario(s,policy="Protected Area", m=0.3)
s4b=scenario(s,policy="Protected Area", m=0.3)
s5=scenario(s,policy="Economic Incentives", policy_target=:μ, policy_method=:taxation)
s6=scenario(s,policy="Development")

# Switch back to using "regulation" instead of regulation

regulation=0.5
f=Figure(size=(900,600))
a1=Axis(f[1,1],title=s1.policy)
a2=Axis(f[1,2],title=s2.policy)
a3=Axis(f[1,3],title=s3.policy)
a4=Axis(f[2,1],title=s4.policy)
a5=Axis(f[2,2],title=s5.policy)
a6=Axis(f[2,3],title=s6.policy)
phase_plot!(a1,sim(s1;regulation))
phase_plot!(a2,sim(s2a;regulation))
phase_plot!(a2,sim(s2b;regulation), show_exploitation=false, open_access_color=:transparent)
phase_plot!(a3,sim(s3a;regulation), show_target=true)
phase_plot!(a3,sim(s3b;regulation=0.749), show_target=true, show_exploitation=false)

#Understand why regulation=0.0 || start_oa=true makes error for Protected Area!

phase_plot!(a4,sim(s4b;regulation=0.3), show_exploitation=false)
phase_plot!(a4,sim(s4b;regulation=0.5), show_exploitation=false)
phase_plot!(a4,sim(s4b;regulation=0.7), show_exploitation=false)
phase_plot!(a4,sim(s4b;regulation=0.8), show_exploitation=false)
phase_plot!(a4,sim(s4b;regulation=0.9), show_exploitation=false)
phase_plot!(a4,sim(s4b;regulation=0.95), show_exploitation=false)
phase_plot!(a5,sim(s5;regulation))
sol=sim(s6;regulation)
phase_plot!(a6,sol,show_trajectory=true, t=0.0)
#phase_plot!(a6,sol,show_trajectory=true, t=500.0)
phase_plot!(a6,sol,show_trajectory=true, t=1000.0, show_exploitation=false)
f