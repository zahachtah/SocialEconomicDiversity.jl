function figure3()
    no_change=:gray
    base_w̃=0.3


    f=Figure(size=(800,600))
    w̃_sigma_plot=Axis(f[1,1])
    w̃_median_plot=Axis(f[2,1])
    ū_mean_plot=Axis(f[1,2])
    ū_cor_plot=Axis(f[2,2])
    α_plot=Axis(f[1,3])
    inc_plot=Axis(f[2,3])

    [hidespines!(a) for a in [w̃_sigma_plot,w̃_median_plot,ū_mean_plot,ū_cor_plot,α_plot,inc_plot]]
    [hidedecorations!(a) for a in [w̃_sigma_plot,w̃_median_plot,ū_mean_plot,ū_cor_plot,α_plot,inc_plot]]


    ss=high_impact()
    s=scenario(ss,w̃=sed(median=0.3, sigma=0.8, distribution=LogNormal))
    [phase_plot!(a,sim(s)) for a in [α_plot]]
    
    phase_plot!(w̃_sigma_plot,sim(scenario(ss,w̃=sed(median=0.3, sigma=0.8, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_sigma_plot,sim(scenario(ss,w̃=sed(median=0.3, sigma=0.3, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_sigma_plot,sim(scenario(ss,w̃=sed(median=0.3, sigma=0.0, distribution=LogNormal))), impact_line_color=no_change)
    Γ_plot!(w̃_sigma_plot,sim(s))

    phase_plot!(w̃_median_plot,sim(scenario(ss,w̃=sed(median=0.1, sigma=0.8, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_median_plot,sim(scenario(ss,w̃=sed(median=0.3, sigma=0.8, distribution=LogNormal))), impact_line_color=no_change)
    phase_plot!(w̃_median_plot,sim(scenario(ss,w̃=sed(median=0.5, sigma=0.8, distribution=LogNormal))), impact_line_color=no_change)
    Γ_plot!(w̃_median_plot,sim(s))
    
    phase_plot!(ū_mean_plot,sim(ss), incentive_line_color=no_change)
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=0.5,sigma=0.0, normalize=true))))
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=1.0,sigma=0.0, normalize=true))))
    Φ_plot!(ū_mean_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))))

    phase_plot!(ū_cor_plot,sim(ss), incentive_line_color=no_change)
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=4.0, normalize=true))))
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=0.0, normalize=true))))
    Φ_plot!(ū_cor_plot,sim(scenario(s,ū=sed(mean=2.0,sigma=-4.0, normalize=true))))

    phase_plot!(α_plot,sim(ss), impact_line_color=no_change, show_trajectory=true)
    phase_plot!(α_plot,sim(scenario(ss, α=0.01)), impact_line_color=no_change, show_trajectory=true)

    #incomes_plot!(inc_plot,sim(s))
    heatmap!(inc_plot,sim(s)[1:100,:]', colormap=(ColorSchemes.linear_wcmr_100_45_c42_n256))

   
    Label(f[0,1], text="Incentives, w̃", tellwidth=false)
    Label(f[0,2], text="Impact, ū", tellwidth=false)
    Label(f[0,3], text="Dynamics, α", tellwidth=false)
    f

end

figure3()