"""
Policy instrument implementations for the SocialEconomicDiversity module.

This module contains functions that implement different policy instruments:
- Open Access (default)
- Exclusive Use Rights
- Tradable Use Rights
- Protected Area
- Economic Incentives
- Development
"""

using ..SocialEconomicDiversity: change, sed, dxdt, stage_limiter!
using OrdinaryDiffEq
using DiffEqCallbacks: TerminateSteadyState

# ===== Open Access policy functions =====

"""
    γ(x, p, t)

Default incentive function for Open Access. Returns the alternative livelihood opportunities.
"""
function γ(x, p, t)
    return p.w̃
end

"""
    μ(x, p, t)

Default impact function for Open Access. Returns the physical constraints on effort.
"""
function μ(x, p, t)
    return p.ū
end

"""
    ϕ(dx, x, p, t)

Default additional dynamics function for Open Access. Does nothing.
"""
function ϕ(dx, x, p, t)
    return 0.0
end

"""
    regulate(p, regulation)

Default regulation function for Open Access. Only affects the regulation parameter.
"""
function regulate(p, regulation)
    return change(p, regulation=regulation)
end

# ===== Assigned/Exclusive Use Rights =====

"""
    γ_exclusive_use_rights(x, p, t)

Incentive function for Exclusive Use Rights. Adds use rights to alternative livelihood opportunities.
"""
function γ_exclusive_use_rights(x, p, t)
    return p.w̃ .+ p.R
end

"""
    regulate_exclusive_use_rights(scenario, f)

Regulation function for Exclusive Use Rights.
- f: fraction of users allowed to extract resource
- scenario.reverse: if true, picks users from the highest w̃
"""
function regulate_exclusive_use_rights(scenario, f)
    R = zeros(1:scenario.N)
    n = Int64(round((f) * scenario.N)) # Integer fraction f of number of users
    if n != 0
        if haskey(scenario, :reverse)
            scenario.reverse ? R[max(1, end-n):end] .= 1.0 : R[1:n] .= 1.0
        end
    end
    return change(scenario, R=R) # return use rights
end

# ===== Tradable Use Rights =====

"""
    regulate_tradable_use_rights(s, f)

Regulation function for Tradable Use Rights. 
Allocates tradable use rights to users.
"""
function regulate_tradable_use_rights(s, f)
    if haskey(s, :historical_use_rights)
        u0 = zeros(s.N); y0 = 1.0; ϕ0 = 0.0
        oaprob = ODEProblem(dxdt, [u0; y0; ϕ0], (0, 1000), s)
        oasol = solve(oaprob, SSPRK432(; stage_limiter!), callback=TerminateSteadyState(1e-6, 1e-4))
        hur = oasol[1:s.N, end-1] .> 0.0 #oasol[1:N,end-1].>0.0
    end
    R = haskey(s, :historical_use_rights) ? hur .* (1-Float64(f)) ./ sum(hur) : fill(f==0 ? 1.0 : (1-Float64(f))/s.N, s.N)
    q = change(s, R=R, regulation=f)
    
    return q
end

"""
    γ_tradable_use_rights(x, p, t)

Incentive function for Tradable Use Rights. 
Adds market price to the incentive.
"""
function γ_tradable_use_rights(x, p, t)
    return p.w̃ .+ x[end]
end

"""
    ϕ_tradable_use_rights(dx, x, p, t)

Additional dynamics for Tradable Use Rights. 
Implements the market dynamics for trading use rights.
"""
function ϕ_tradable_use_rights(dx, x, p, t)
    # we calculate the sum of all unused Use Rights and assume they are for sale
    # if the market is for quota (yield) then effort is yield/resource_density
    if p.policy_target == :yield
        supply = max.(0.0, sum(p.R .- x[1:p.N] * x[p.N+1])) 
    elseif p.policy_target == :effort
        supply = max.(0.0, sum(p.R .- x[1:p.N]))
    else
        println("please supply policy target (:yield / :effort")
    end

    # To calculate demand we need to find all who want to increase their effort
    id = findall((dx[1:p.N] .> 0.0))

    # Calculate individual demand for increased usage, but assure they do not demand more than their physical limit, ū	    
    ind_demand = min.(p.ū[id] - x[id], dx[id])
    demand = sum(ind_demand)

    # Update the tradable quota price based on the difference between demand and supply
    dx[p.N+2] = p.market_rate * (demand - supply)

    # adjust rate of change of increase in effort to account for limited supply. The condition assures that we never divide by zero demand.
    if demand > supply
        dx[id] .= supply .* ind_demand ./ demand
    end
end

# ===== Protected Area Two Populations =====

"""
    ϕ_protected_area_two_pop(dx, x, p, t)

Additional dynamics for Protected Area with Two Populations.
Implements the population dynamics with protected and unprotected areas.
"""
function ϕ_protected_area_two_pop(dx, x, p, t)
    mx = x[p.N+2] - x[p.N+1]
    dx[p.N+2] = (1.0 - x[p.N+2]) - (1.0 - p.regulation) / p.regulation * p.m * mx
    dx[p.N+1] += p.regulation / (1.0 - p.regulation) * p.m * mx
end

"""
    γ_protected_area_two_pop(x, p, t)

Incentive function for Protected Area with Two Populations.
"""
function γ_protected_area_two_pop(x, p, t)
    return p.w̃
end

"""
    μ_protected_area_two_pop(x, p, t)

Impact function for Protected Area with Two Populations.
"""
function μ_protected_area_two_pop(x, p, t)
    return p.ū
end

# ===== Protected Area =====

"""
    regulate_protected_area(p, f)

Regulation function for Protected Area.
"""
function regulate_protected_area(p, f)
    return change(p, regulation=f)
end

"""
    γ_protected_area(x, p, t)

Incentive function for Protected Area.
Scales incentives by the regulated area.
"""
function γ_protected_area(x, p, t)
    return p.w̃ .* (1 - p.regulation).^-1
end

"""
    yₚ(y, f_p, m; K=1.0, r=1.0, xK=0.0, xr=0.0)

Calculate steady-state fish density in the protected area.
"""
function yₚ(y::Float64, f_p::Float64, m::Float64; K::Float64=1.0, r::Float64=1.0, xK::Float64=0.0, xr::Float64=0.0)
    if f_p == 0.0
        return K
    end
    r_p = r * (1 + xr)
    K_p = K * (1 + xK)
    # Calculate the scaled mobility factor
    k = (1.0 - f_p) / f_p * m
    # Compute the discriminant of the quadratic equation
    discriminant = max(0.0, (r_p - k)^2 + 4.0 * r_p * k * y / K_p)
    
    # Ensure the discriminant is non-negative for real solutions
    if discriminant < 0
        error("No real solution exists: discriminant is negative.")
    end 
    
    # Calculate the steady-state fish density in the protected area
    y_p = ((r_p - k) + sqrt(discriminant)) * K_p / (2.0 * r_p)
    
    return y_p
end

"""
    rₛ(y, fₚ, m; K=1.0, r=1.0, xK=0.0, xr=0.0)

Calculate the spillover rate.
"""
function rₛ(y, fₚ, m; K::Float64=1.0, r::Float64=1.0, xK::Float64=0.0, xr::Float64=0.0)
    (fₚ / (1 - fₚ) * m * (yₚ(y, fₚ, m; r, K, xK, xr) .- y)) ./ y
end

"""
    μ_protected_area(x, p, t)

Impact function for Protected Area.
Adjusts impact based on spillover.
"""
function μ_protected_area(x, p, t)
    return p.ū .* (1 + rₛ(x[p.N+1], p.regulation, p.m))^-1
end

# ===== Economic Incentives =====

"""
    regulate_economic_incentive(p, f)

Regulation function for Economic Incentives.
"""
function regulate_economic_incentive(p, f)
    return change(p, regulation=f)
end

"""
    μ_economic_incentive(x, p, t)

Impact function for Economic Incentives.
Adjusts impact based on policy method (taxation or subsidy).
"""
function μ_economic_incentive(x, p, t)
    if :μ in vcat(p.policy_target)
        return p.ū .* (1 - p.regulation * (p.policy_method == :taxation ? -1.0 : 1.0))
    else 
        return p.ū
    end
end

"""
    γ_economic_incentive(x, p, t)

Incentive function for Economic Incentives.
Adjusts incentives based on policy method and targeting.
"""
function γ_economic_incentive(x, p, t)
    if :γ in vcat(p.policy_target)
        if p.policy_method == :additive
            return p.w̃ .+ p.regulation
        else
            return p.w̃ .* (1 - p.regulation * (p.policy_method == :taxation ? -1.0 : 1.0))
        end
    else
        return p.w̃
    end
end

# ===== Development =====

"""
    regulate_development(p, f)

Regulation function for Development policy.
"""
function regulate_development(p, f)
    return change(p, regulation=f)
end

"""
    μ_development(x, p, t)

Impact function for Development policy.
Increases impact over time.
"""
function μ_development(x, p, t)
    return p.ū .+ p.regulation * 2 / p.N * t / 1000 * p.μ_value
end

"""
    γ_development(x, p, t)

Incentive function for Development policy.
Increases incentives over time.
"""
function γ_development(x, p, t)
    return p.w̃ .+ p.regulation * t / 1000 * p.γ_value
end

# ===== Scenario management =====

"""
    scenario(p; kwargs...)

Create a scenario with a specific policy.
Returns a NamedTuple with the appropriate policy functions.
"""
function scenario(p; kwargs...)
    temp = (; p..., policy="Open Access", kwargs...)
    if temp.policy == "Open Access"
        return (; temp...)
    elseif temp.policy == "Exclusive Use Rights"
        return (; temp..., γ=γ_exclusive_use_rights, regulate=regulate_exclusive_use_rights)
    elseif temp.policy == "Tradable Use Rights"
        # check if temp has target and market_rate
        return (; temp..., γ=γ_tradable_use_rights, ϕ=ϕ_tradable_use_rights, regulate=regulate_tradable_use_rights)
    elseif temp.policy == "Protected Area"
        #check if temp has mobility_rate
        return (; temp..., γ=γ_protected_area, μ=μ_protected_area, regulate=regulate_protected_area)
    elseif temp.policy == "Protected Area Two Pop"
        #check if temp has mobility_rate
        return (; temp..., γ=γ_protected_area, μ=μ_protected_area_two_pop, 
                regulate=regulate_protected_area, ϕ=ϕ_protected_area_two_pop)
    elseif temp.policy == "Economic Incentives"
        return (; temp..., μ=μ_economic_incentive, regulate=regulate_economic_incentive, γ=γ_economic_incentive)
    elseif temp.policy == "Development"
        return (; temp..., γ=γ_development, μ=μ_development, regulate=regulate_development, 
                μ_value=0.5, γ_value=0.5)
    end
end

"""
    base(; N=100, sigma=0.0, random=false)

Create a base scenario with Open Access policy.
"""
function base(; N=100, sigma=0.0, random=false)
    (; N, α=0.1, 
       w̃=sed(min=0.01, max=1.0, distribution=LogNormal, random=random), 
       ū=sed(mean=1.0, sigma=sigma, normalize=true, random=random), 
       R=ones(N), γ, ϕ, μ, regulate, policy="Open Access")
end

"""
    high_impact(; N=100, sigma=0.0)

Create a scenario with high impact (ū has mean=2.0).
"""
function high_impact(; N=100, sigma=0.0)
    (; N, α=0.1, 
       w̃=sed(min=0.01, max=1.0, distribution=LogNormal), 
       ū=sed(mean=2.0, sigma=sigma, normalize=true), 
       R=ones(N), γ, ϕ, μ, regulate, policy="Open Access")
end

"""
    low_impact(; N=100, sigma=0.0)

Create a scenario with low impact (ū has mean=0.5).
"""
function low_impact(; N=100, sigma=0.0)
    (; N, α=0.1, 
       w̃=sed(min=0.01, max=0.6, distribution=LogNormal), 
       ū=sed(mean=0.5, sigma=sigma, normalize=true), 
       R=ones(N), γ, ϕ, μ, regulate, policy="Open Access")
end

"""
    high_incentives(; N=100, sigma=0.0)

Create a scenario with high incentives (w̃ has min=0.3, max=0.7).
"""
function high_incentives(; N=100, sigma=0.0)
    (; N, α=0.1, 
       w̃=sed(min=0.3, max=0.7, distribution=LogNormal), 
       ū=sed(mean=1.0, sigma=sigma, normalize=true), 
       R=ones(N), γ, ϕ, μ, regulate, policy="Open Access")
end