module SocialEconomicDiversity

    using Colors, Statistics, Distributions, OrdinaryDiffEq, CairoMakie, FileIO, Random, ColorSchemes
    using DiffEqCallbacks: TerminateSteadyState
    using Parameters
    import Base: show
    using Base: @kwdef
    using Reexport
    @reexport using CairoMakie, FileIO, ColorSchemes

    include("sed.jl")
    export SED, sed, dist!, astext
    export has_dependencies, is_distribution_type, find_sed_by_name
    export sim
    export scenario, base, high_impact, low_impact, high_incentives
    export γ, μ, ϕ, regulate
    export Γ, Φ
    export γ_exclusive_use_rights, regulate_exclusive_use_rights
    export γ_tradable_use_rights, ϕ_tradable_use_rights, regulate_tradable_use_rights
    export γ_economic_incentive, μ_economic_incentive, regulate_economic_incentive
    export Uniform, LogNormal, Normal, Exponential, Dirac
    export incomes, regulation_scan, gini

    # ODE		
    function dxdt(dx, x, p, t)
        # Extract parameters to make equations prettier
        N = p.N
        # Actor resource use change
        dx[1:N] = p.α * (x[N+1] .- p.γ(x, p, t))
        
        # Resource level dynamics
        dx[N+1] = x[N+1] * ((1 - x[N+1]) - sum(x[1:N]))

        # Optional function to add functionality, e.g. markets
        p.ϕ(dx, x, p, t)
    end

    # This ensures constrained values of variables, e.g. 0>uᵢ>ū
    function stage_limiter!(x, integrator, p, t)
        # Actor use limits
        x[1:p.N] .= ifelse.(x[1:p.N] .< 0.0, 0.0, 
                      ifelse.(x[1:p.N] .> (p.μ(x, p, t)), p.μ(x, p, t), x[1:p.N]))
        
        for j in p.N+1:length(x)
            x[j] = max(0.0, x[j])
        end
    end

    # Solve ODE
    function sim(s; u0=zeros(s.N), y0=1.0, ϕ0=0.0, regulation=0.0, start_from_OA=false, t_end=1000.0)
        isempty(s.w̃.data) ? dist!(s.w̃, s.N) : nothing
        isempty(s.ū.data) ? dist!(s.ū, s.N) : nothing
        tspan = (0.0, t_end)
        p = s.regulate(s, regulation)
       
        if s.policy == "Tradable Use Rights"
            initVals = [u0; y0; ϕ0]
        elseif s.policy == "Protected Area Two Pop"
            initVals = [u0; y0; y0]
        else
            initVals = [u0; y0]
        end

        if start_from_OA
            oa = p.regulate(p, 0.0)
            oaprob = ODEProblem(dxdt, initVals, tspan, oa)
            oasol = solve(oaprob, SSPRK432(; stage_limiter!), callback=TerminateSteadyState(1e-6, 1e-4))
            initVals[1:oa.N+1] = oasol[1:oa.N+1, end-2]
        end

        prob = ODEProblem(dxdt, initVals, tspan, p)
        sol = solve(prob, SSPRK432(; stage_limiter!), callback=TerminateSteadyState(1e-6, 1e-4))
        return sol
    end

    function Γ(y, p; x=zeros(p.N+1), t=0.0)
        x[p.N+1] = y
        γ = p.γ(x, p, t)
        id = sortperm(γ) # if w_bar's are not in ascending order
        f = sum(γ[id] .< y) / p.N
    end

    # Impact function
    function Φ(y, p; t=0.0)
        x = zeros(p.N+1)
        x[end] = y
        γ = p.γ(x, p, t)

        id = sortperm(γ)
        μ = p.μ(x, p, t)
        cu = cumsum(μ[id])
        f = sum(cu .< (1.0 - y))
        if f == 0
            f = (1.0 - y) / μ[id[1]]
        elseif f < p.N
            f = f + ((1 - y) - cu[f]) / μ[id[f + 1]]
        end
        return f / p.N
    end

    function incomes(x, p; summarize=false)
        f = occursin("Protected Area", p.policy) ? p.regulation : 0.0
        resource = x[1:p.N] .* x[p.N+1] .* (1 - f)
        wages = (p.ū .- x[1:p.N]) .* p.w̃ # γ(x,p,0.0) μ(x,p,0.0)
        trade = p.policy == "Tradable Use Rights" ? (p.R .- x[1:p.N]) .* x[p.N+2] : fill(0.0, p.N)
        total = resource .+ wages .+ trade
        g = gini(total)
        ecological = x[p.N+1]
        return summarize ? (; resource, wages, trade, total, g, ecological) : 
                           (; resource, wages, trade, total, gini=g, ecological)
    end

    function incomes(s)
        return incomes(s.u[end], s.prob.p)
    end

    function gini(x)
        sum([abs(x[i] - x[j]) for i in 1:length(x), j in 1:length(x)]) / (2 * length(x) * sum(x))
    end

    function regulation_scan(p; m=100, kR=0.0, kT=0.0, kG=0.0, kE=0.0, kI=0.0)
        r = range(0.0, stop=1.0, length=m)
        RR = zeros(m)
        WR = zeros(m)
        TR = zeros(m)
        ToR = zeros(m)
        GI = zeros(m)
        EH = zeros(m)
        RI = zeros(m)
        Gov = zeros(m)
        oau = zeros(p.N)
        x0 = zeros(p.N+2)
        x0[p.N+1] = 1.0
        sols = zeros(m, p.N)
        incdist = zeros(m, p.N)
        
        for (j, i) in enumerate(r)
            sol = sim(p, regulation=i, t_end=1000) # u0=x0[1:p.N], y0=x0[p.N+1], ϕ0=x0[p.N+1]

            if j == 1
                oau = sol[1:p.N, end-1]
            end
            
            inc = incomes(sol.u[end-1], sol.prob.p)
            RR[j] = sum(inc.resource)
            WR[j] = sum(inc.wages)
            TR[j] = sum(inc.trade)
            ToR[j] = sum(inc.total)
            GI[j] = inc.gini
            EH[j] = inc.ecological
            regimpact = abs.(oau .- sol[1:p.N, end-1])
            RI[j] = sum(regimpact)
            Gov[j] = sum(inc.resource .^ kR .+ inc.total .^ kT .+ inc.gini .^ kG .+ 
                          inc.ecological .^ kE .+ regimpact .^ kI)
            sols[j, :] = sol.u[end-1][1:p.N]
            incdist[j, :] = inc.total
        end
        
        oRR = argmax(RR)
        oWR = argmax(WR)
        oTR = argmax(TR)
        oToR = argmax(ToR)
        oGI = argmin(GI)
        oEH = argmax(EH)
        oRI = argmax(EH)
        return (; RR, WR, TR, ToR, GI, EH, RI, Gov, r, oRR, oWR, oTR, oToR, oGI, oEH, oRI, sols, incdist)
    end

    # Include policy instrument functions
    include("policy_instruments.jl")
    
    # Include visualization module
    include("visualizations.jl")
    
    # Re-export visualization functions
    export phase_plot!, bg_plot!, Γ_plot!, Φ_plot!, attractor_plot!, trajecory_plot! 
    export target_plot!, arrow_arc!, arrow_arc_deg!, incomes_plot!

end