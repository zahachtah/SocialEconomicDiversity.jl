"""
Module containing visualization functions for SocialEconomicDiversity.

This includes functions for plotting incentive and impact distributions, trajectories,
phase spaces, and income distributions.
"""

using Colors, Statistics, CairoMakie, ColorSchemes
import ..SocialEconomicDiversity: Γ, Φ, change, γ, μ, regulate, ϕ, sim

"""
    Γ_plot!(axis, sol; color=:darkorange, linewidth=3, t=0.0)

Plot the cumulative incentive distribution on the given axis.
"""
function Γ_plot!(axis, sol; color=:darkorange, linewidth=3, t=0.0)
    y = range(0.0, stop=1.0, length=100)
    lines!(axis, y, Γ.(y, Ref(sol.prob.p), x=sol.u[end-1]; t); color, linewidth)
end

"""
    Φ_plot!(axis, sol; color=:darkorange, linewidth=3, t=0.0)

Plot the cumulative impact distribution on the given axis.
"""
function Φ_plot!(axis, sol; color=:darkorange, linewidth=3, t=0.0)
    y = range(0.0, stop=1.0, length=100)
    lines!(axis, y, Φ.(y, Ref(sol.prob.p); t); color, linewidth)
end

"""
    attractor_plot!(axis, sol; color=:darkorange, markersize=15, marker=:circle)

Plot the attractor point on the given axis.
"""
function attractor_plot!(axis, sol; color=:darkorange, markersize=15, marker=:circle)
    N = sol.prob.p.N
    scatter!(axis, [sol[N+1,end-2]], [sum(sol[1:N,end-2]./sol.prob.p.μ(sol.u[end-2],sol.prob.p,sol.t[end-2])./N)]; color, markersize, marker)
end

"""
    trajecory_plot!(axis, sol; color=:darkorange, startcolor=:lightgray, linewidth=2)

Plot the trajectory on the given axis.
"""
function trajecory_plot!(axis, sol; color=:darkorange, startcolor=:lightgray, linewidth=2)
    scenario = sol.prob.p
    lines!(axis, 
           [u[scenario.N+1] for u in sol.u[1:end-2]], 
           [sum(u[1:scenario.N]./scenario.μ(u,scenario,sol.t[i]))/scenario.N for (i,u) in enumerate(sol.u[1:end-2])]; 
           color, linestyle=:dot, colormap=cgrad([startcolor, color], [0.0, 0.5, 1.0]), linewidth)
end

"""
    bg_plot!(axis; show_exploitation=true)

Add background elements to the plot, including limits and exploitation region.
"""
function bg_plot!(axis; show_exploitation=true)
    limits!(axis, 0.0, 1.0, 0.0, 1.0)
    if show_exploitation
        poly!(axis, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.0, 0.5, 0.1))
    end
end

"""
    target_plot!(axis, sol; color=:darkorange, linestyle=:dash, linewidth=3)

Plot the policy target line on the given axis.
"""
function target_plot!(axis, sol; color=:darkorange, linestyle=:dash, linewidth=3)
    scenario = sol.prob.p
    y = range(0.0, stop=1.0, length=100)
    if haskey(scenario, :policy_target)
        Y = scenario.policy_target==:effort ? ones(length(y)) : y
        lines!(axis, y, Φ.(1 .-(1-scenario.regulation)./Y, Ref(scenario)); color, linewidth, linestyle)
    end
end

"""
    phase_plot!(axis, sol; show_trajectory=false, show_target=false, open_access_color=:lightgray, 
                incentive_line_color=:darkorange, impact_line_color=:darkorange, t=0.0, 
                show_exploitation=true, show_oa=true)

Create a phase plot with incentive and impact distributions, attractors, and trajectories.
"""
function phase_plot!(axis, sol; show_trajectory=false, show_target=false, open_access_color=:lightgray, 
                     incentive_line_color=:darkorange, impact_line_color=:darkorange, t=0.0, 
                     show_exploitation=true, show_oa=true, trajectory_color=:gray)
    if show_exploitation
        poly!(axis, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.0, 0.5, 0.1))
    end
    
    scenario = sol.prob.p
    N = scenario.N
    limits!(axis, 0.0, 1.0, 0.0, 1.0)

    y = range(0.0, stop=1.0, length=100)
    γ_array = scenario.γ(sol.u[end], scenario, sol.t[end])
    
    if show_oa
        oa = change(scenario, policy="Open Access", γ=γ, μ=μ, regulate=regulate, ϕ=ϕ)
        oasol = sim(oa)
    end
    
    if show_target
        if haskey(scenario, :policy_target)
            Y = scenario.policy_target==:effort ? ones(length(y)) : y
            lines!(axis, y, Φ.(1 .-(1-scenario.regulation)./Y, Ref(scenario)), color=:darkorange, linestyle=:dot)
        end
    end

    # Cumulative incentive distributions
    show_oa ? lines!(axis, y, Γ.(y, Ref(oa), x=sol.u[end-1]), color=open_access_color, linewidth=3) : nothing
    lines!(axis, y, Γ.(y, Ref(scenario), x=sol.u[end-1]; t), color=incentive_line_color, linewidth=3)

    # Cumulative impact distributions
    show_oa ? lines!(axis, y, Φ.(y, Ref(oa)), color=open_access_color, linewidth=1) : nothing
    lines!(axis, y, Φ.(y, Ref(scenario); t), color=impact_line_color, linewidth=1)

    if show_trajectory
        # Show trajectory
        lines!(axis, 
               [u[scenario.N+1] for u in sol.u[1:end-2]], 
               [sum(u[1:scenario.N]./scenario.μ(u, scenario, sol.t[i]))/scenario.N for (i,u) in enumerate(sol.u[1:end-2])], 
               color=scenario.policy=="Development" ? sol.t[1:end-2] : trajectory_color, 
               linestyle=:dot, 
               colormap=cgrad([:lightgray, :darkorange], [0.0, 0.5, 1.0]))
    end

    # Show the attractor
    scatter!(axis, [sol[N+1,end-2]], [sum(sol[1:N,end-2]./scenario.μ(sol.u[end-2], scenario, sol.t[end-2])./N)], color=:black, markersize=10)

    show_oa ? scatter!(axis, [oasol[N+1,end-2]], [sum(oasol[1:N,end-2]./oa.μ(oasol.u[end-2], oa, oasol.t[end-2])./N)], color=:black, markersize=15, marker='o') : nothing

    if scenario.policy=="Development"
        scatter!(axis, [sol[N+1,1]], [sum(sol[1:N,1]./scenario.μ(sol.u[end-1], scenario, sol.t[1])./N)], color=:white, markersize=15)
    end

    # Show the market price of use rights
    scenario.policy=="Tradable Use Rights" ? text!(axis,0.95*sol.u[end][end-1],0.95*Γ.(sol.u[end][end-1], Ref(scenario), x=sol.u[end-1]), text="ϕ: "*string(round(sol[end,end], digits=2)), align=(:right,:top), space=:relative) : nothing
    #scenario.policy=="Tradable Use Rights" ? arrows!(axis,sol.u[end][end-1]-sol.u[end][end] , Γ(sol.u[end][end-1], scenario, x=sol.u[end-1]) , 0.0, sol.u[end-1]) : nothing
end

"""
    arrow_arc!(ax, origin, radius, start_angle, stop_angle; linewidth=1, color=:black, 
               flip_arrow=false, linestyle=:dot)

Draw an arc with arrows at the endpoints.
"""
function arrow_arc!(ax, origin, radius, start_angle, stop_angle; linewidth=1, color=:black, 
                    flip_arrow=false, linestyle=:dot)
    # Draw the arc
    arc!(ax, origin, radius, start_angle, stop_angle, linewidth=linewidth, color=color; linestyle)

    # Function to calculate a point on the circle
    point_on_circle(θ) = origin .+ radius * Point2f(cos(θ), sin(θ))

    # Calculate the direction of the arrow at the start and end of the arc
    start_dir = Point2f(cos(start_angle + π/2 + (flip_arrow ? pi/2 : 0)), sin(start_angle + π/2 + (flip_arrow ? pi/2 : 0)))
    end_dir = Point2f(cos(stop_angle - π/2 + (flip_arrow ? pi : 0)), sin(stop_angle - π/2 + (flip_arrow ? pi : 0)))
    dx = 0.001
    
    # Add arrow at the start and end of the arc
    arrows!(ax, [point_on_circle(start_angle)[1]], [point_on_circle(start_angle)[2]], 
            [start_dir[1]]*dx, [start_dir[2]]*dx, color=color, linewidth=linewidth)
    arrows!(ax, [point_on_circle(stop_angle)[1]], [point_on_circle(stop_angle)[2]], 
            [end_dir[1]]*dx, [end_dir[2]]*dx, color=color, linewidth=linewidth)
end

"""
    arrow_arc_deg!(ax, origin, radius, start_angle_deg, stop_angle_deg; linewidth=1, color=:black, 
                   flip_arrow=false, linestyle=:dot, startarrow=false)

Draw an arc with arrows at the endpoints, using degrees instead of radians.
"""
function arrow_arc_deg!(ax, origin, radius, start_angle_deg, stop_angle_deg; 
                       linewidth=1, color=:black, flip_arrow=false, linestyle=:dot, startarrow=false, space=:relative)
    # Helper to convert from degrees to radians
    deg2rad(θ_deg) = θ_deg * π / 180

    # Because we want 0° = up (i.e., the positive y-axis),
    # we rotate by 90°, so:
    #
    #   rad(θ_deg) = (90° - θ_deg) in radians
    #
    # This ensures that θ_deg = 0 => π/2 in radians => up.
    rad_start = deg2rad(90 - start_angle_deg)
    rad_stop  = deg2rad(90 - stop_angle_deg)

    # 1) Draw the arc in the new angles:
    arc!(ax, origin, radius, rad_start, rad_stop, linewidth=linewidth, color=color; linestyle=linestyle,space)

    # 2) Function to calculate a point on the circle at a given *degree* measure:
    point_on_circle_deg(θ_deg) = origin .+ radius * Point2f(
        cos(deg2rad(90 - θ_deg)),
        sin(deg2rad(90 - θ_deg))
    )

    # 3) Arrow directions at start and end.
    start_dir = Point2f(
        cos(rad_start + π/2 + (flip_arrow ? π/2 : 0)),
        sin(rad_start + π/2 + (flip_arrow ? π/2 : 0))
    )
    end_dir = Point2f(
        cos(rad_stop - π/2 + (flip_arrow ? π : 0)),
        sin(rad_stop - π/2 + (flip_arrow ? π : 0))
    )

    # A small offset so the arrows do not vanish
    dx = 0.001

    startarrow ? arrows!(
        ax,
        [point_on_circle_deg(start_angle_deg)[1]],
        [point_on_circle_deg(start_angle_deg)[2]],
        [start_dir[1]] .* dx,
        [start_dir[2]] .* dx,
        color=color,
        linewidth=linewidth
    ) : nothing

    arrows!(
        ax,
        [point_on_circle_deg(stop_angle_deg)[1]],
        [point_on_circle_deg(stop_angle_deg)[2]],
        [end_dir[1]] .* dx,
        [end_dir[2]] .* dx,
        color=color,
        linewidth=linewidth,
        space=space
    )
end

"""
    incomes_plot!(aa, sol; order=false, color=:darkorange)

Plot the distribution of incomes.
"""


# -- plotting, with dimensional toggle --
function incomes_plot!(ax, sol; order=false, color=:darkorange, dimensional::Bool=false, resource_incomes=true, xlabel_as_w̃=false, base=0.0)
    p = sol.prob.p
    inc = incomes(sol)

    # unpack for readability
    res   = inc.resource
    wage  = inc.wages
    trd   = inc.trade.+base
    total = inc.total

    # ordering
    idx = order ? sortperm(total) : eachindex(total)
    xvals= xlabel_as_w̃ ? p.w̃ : 1:length(total)

    # bottom bars: resource + wages
    barplot!(ax, xvals,(res[idx] .+ wage[idx]), color=color, alpha=1.0, offset=trd[idx])
    # top bars: trade revenues
    barplot!(ax, xvals,trd[idx], color=color)
    barplot!(ax, xvals,trd[idx], color=HSLA(0,0,0,0.2))
    # dotted line: max nondimensional effort*price curve

   dim=dimensional ? p.rpk : 1.0
   μ = p.μ(sol.u[end], p, 0.0)
   γ =  occursin("Protected Area", p.policy) || occursin("Exclusive Use Rights", p.policy) ? p.w̃ : p.γ(sol.u[end], p, 0.0)
   line_data = μ .* γ .* dim
   line_data = inc.wages_0.*dim
    lines!(ax, xvals,line_data, linewidth=1, color=:white, linestyle=:solid)
    ylims!(ax,minimum(trd),maximum(total))

    if resource_incomes
        id=findall(res[idx].>0.0)
        #=y=vcat(trd[id[1]],res[id].+trd[id],trd[reverse(id)])
        x=vcat(id[1],id,reverse(id))
        lines!(ax,x,y, color=:black)=#
        scatter!(ax,xvals[id],total[idx[id]], color=:black, markersize=3)
        #scatter!(ax,id,trd[id], color=:black, markersize=4)

    end

    return nothing
end