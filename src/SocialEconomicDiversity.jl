module SocialEconomicDiversity

    using Colors, Statistics, Distributions, OrdinaryDiffEq, CairoMakie, FileIO,  Random,  ColorSchemes
    using DiffEqCallbacks: TerminateSteadyState
    import Base: show
    using Base: @kwdef

    export SED,sed, dist!,astext
    export sim
    export scenario, base, high_impact, low_impact, high_incentives
    export γ, μ,ϕ,regulate
    export Γ, Φ
    export γ_assigned_use_rights, regulate_assigned_use_rights
    export γ_tradable_use_rights, ϕ_tradable_use_rights,regulate_tradable_use_rights
    export run
    export Uniform, LogNormal, Normal, Exponential, Dirac
    export phase_plot!


    # ODE		
    function dxdt(dx,x,p,t)
			
			# Extract parameters to make equations prettier
			N=p.N
			# Actor resource use change
			dx[1:N]=p.α*(x[N+1].-p.γ(x,p,t))
			
			# Resource level dynamics
			dx[N+1]=x[N+1]*((1-x[N+1])-sum(x[1:N]))

			# Optional function to add functionality, e.g. markets
			p.ϕ(dx,x,p,t)
		end

		# This ensures constrained values of variables, e.g. 0>uᵢ>ū
		function stage_limiter!(x, integrator, p, t)

			
			# Actor use limits
			
			x[1:p.N].=ifelse.(x[1:p.N].<0.0,0.0,ifelse.(x[1:p.N].>(p.μ(x,p,t)),p.μ(x,p,t),x[1:p.N]))
			
			for j in p.N+1:length(x)
				x[j]=max(0.0,x[j])
			end
		end

    # Solve ODE
    function sim(s; u0=zeros(s.N), y0=1.0,ϕ0=0.0, regulation=0.0, start_from_OA=false)
        
        isempty(s.w̃.data) ?  dist!(s.w̃,s.N) : nothing
        isempty(s.ū.data) ?  dist!(s.ū,s.N) : nothing
        tend=(0.0,1000.0)

        p=s.regulate(s,regulation)

        if s.policy=="Tradable Use Rights"
            initVals=[u0;y0;ϕ0]
        else
            initVals=[u0;y0]
        end

        if start_from_OA
            #q=change(p,policy="Open Access", γ=γ, ϕ=ϕ,  μ=μ,regulate=regulate)
            oa=p.regulate(p,0.0)
            oaprob = ODEProblem(dxdt,initVals,tend,oa);
            oasol=solve(oaprob,SSPRK432(;stage_limiter!),callback= TerminateSteadyState(1e-6,1e-4) )
            initVals[1:oa.N+1]=oasol[1:oa.N+1,end-2]
        end

         prob = ODEProblem(dxdt,initVals,tend,p);
 
    
        sol=solve(prob,SSPRK432(;stage_limiter!),callback= TerminateSteadyState(1e-6,1e-4) )
        return sol
    end

    # Policy implementation
    ## Open access
    	# Inentives are here simply alternative livelihood opportunities
	function γ(x,p,t)
		return p.w̃
	end

	# Impact is simply physical constraints on effort such as time and infrastructure such as gear, information and knowledge
	function μ(x,p,t)
		return p.ū
	end

	# Base model needs no additional manipulation of the derivative
	function ϕ(dx,x,p,t)
		return 0.0
	end

	function regulate(p,regulation)
		return change(p,regulation=regulation)
	end

    function Γ(y,p; x=zeros(p.N+1), t=0.0)
	
        x[p.N+1]=y
        γ=p.γ(x,p,t)
        id = sortperm(γ) # if w_bar's are not in ascending order
        f = sum(γ[id] .< y)/p.N
    end

    # Impact function
function Φ(y,p; t=0.0)
	x=zeros(p.N+1)
	x[end]=y
    γ=p.γ(x,p,t)

    id = sortperm(γ)
	μ=p.μ(x,p,t)
    cu = cumsum(μ[id])
    f = sum(cu .< (1.0 - y))
    if f == 0
        f = (1.0 - y) / μ[id[1]]
    elseif f < p.N
        f = f + ((1 - y) - cu[f]) / μ[id[f + 1]]
    end
    return f/p.N
end

    # Assigned use rights
    function γ_assigned_use_rights(x,p,t)
		return p.w̃.+p.R
    end

    function regulate_assigned_use_rights(scenario,f)
        # f is the fraction users allowed to extract resource
        # scenario.reverse picks users from teh highest w̃
            R=zeros(1:scenario.N)
            n=Int64(round((1-f)*scenario.N))# Integer fraction f of number of users
            if n!=0
                if haskey(scenario,:reverse)
                    scenario.reverse ? R[n:end].=1.0 : R[1:n].=1.0
                end
            end
            return change(scenario,R=R) # return use rights
    end

    # Tradable use rights
    function regulate_tradable_use_rights(s,f)
		
		if haskey(s,:historical_use_rights)
			u0=zeros(s.N); y0=1.0; ϕ0=0.0
			oaprob = ODEProblem(dxdt,[u0;y0;ϕ0],(0,1000),s);
			oasol=solve(oaprob,SSPRK432(;stage_limiter!),callback= TerminateSteadyState(1e-6,1e-4) )
			hur=oasol[1:N,end-1].>0.0 #oasol[1:N,end-1].>0.0
		end
		R=haskey(s,:historical_use_rights) ? hur.*(1-Float64(f))./sum(hur) : fill(f==0 ? 1.0 : (1-Float64(f))/s.N,s.N)
		q=change(s,R=R, regulation=f)

		return q
	end
	
	function γ_tradable_use_rights(x,p,t)
		# Market price ϕ=x[end] is added to the incentive
		return p.w̃.+x[end]
	end

	function ϕ_tradable_use_rights(dx,x,p,t)
		# we calculate the sum of all unused Use Rights and assume they are for sale
		# if the market is for quota (yield) then effort is yield/resource_density
		if p.policy_target == :yield
	        supply =max.(0.0,sum(p.R .- x[1:p.N]* x[p.N+1])) 
        elseif p.policy_target == :effort
	        supply =max.(0.0,sum(p.R .- x[1:p.N]))
        else
            println("please supply policy target (:yield / :effort")
	    end

		# To calculate demand we need to find all who want to increase their effort
	    id = findall((dx[1:p.N] .> 0.0) )
	
	    # Calculate individual demand for increased usage, but assure they do not demand more than their physical limit, ū	    
		ind_demand=min.(p.ū[id]-x[id],dx[id])
	    demand = sum(ind_demand)
	

	
	    # Update the tradable quota price based on the difference between demand and supply
	    dx[p.N+2] = p.market_rate * (demand - supply)

		# adjust rate of change of increase in effort to account for limited supply. The condition assures that we never divide by zero demand.
		if demand > supply
			dx[id] .= supply .* ind_demand ./ demand
		end

		
	end

    #Protected area
    function regulate_protected_area(p,f)
		return change(p,regulation=f)
	end
	
	function γ_protected_area(x,p,t)
		# Market price ϕ=x[end] is added to the incentive
		return p.w̃.*(1-p.regulation).^-1
	end
	
	function yₚ(y::Float64, f_p::Float64,m::Float64; K::Float64=1.0, r::Float64=1.0,xK::Float64=0.0, xr::Float64=0.0)
	    r_p=r*(1+xr)
		K_p=K*(1+xK)
	    # Calculate the scaled mobility factor
	    k = (1.0 - f_p) / f_p * m
	    
	    # Compute the discriminant of the quadratic equation
	    discriminant = (r_p - k)^2 + 4.0 * r_p * k * y / K_p
	    
	    # Ensure the discriminant is non-negative for real solutions
	    if discriminant < 0
	        error("No real solution exists: discriminant is negative.")
	    end
	    
	    # Calculate the steady-state fish density in the protected area
	    y_p = ((r_p - k) + sqrt(discriminant)) * K_p / (2.0 * r_p)
	    
	    return y_p
	end

	function rₛ(y,fₚ,m; K::Float64=1.0, r::Float64=1.0,xK::Float64=0.0, 			xr::Float64=0.0)
		(fₚ/(1-fₚ)*m*(yₚ(y,fₚ,m;r,K,xK,xr).-y))./y
	end

	function μ_protected_area(x,p,t)
		return p.ū.*(1+rₛ(x[p.N+1],p.regulation,p.m))^-1
	end

    # Economic Incentives
	function regulate_economic_incentive(p,f)
		return change(p,regulation=f)
	end
	
	function μ_economic_incentive(x,p,t)
		return p.ū.-p.regulation/p.N
	end

    # Development
    function regulate_development(p,f)
		return change(p,regulation=f)
	end
	
	function μ_development(x,p,t)
		return p.ū.+p.regulation*2/p.N*t/1000
	end

	function γ_development(x,p,t)
		
		return p.w̃.+p.regulation*t/1000
	end

    # scenario management

    function scenario(p; kwargs...)
        temp=(; p...,  policy="Open Access",kwargs...)
        if temp.policy=="Open Access"
            return (;temp...)
        elseif temp.policy=="Assigned Use Rights"
            return (;temp..., γ=γ_assigned_use_rights, regulate=regulate_assigned_use_rights)
        elseif temp.policy=="Tradable Use Rights"
            # check if temp has target and market_rate
            return (;temp..., γ=γ_tradable_use_rights, ϕ=ϕ_tradable_use_rights, regulate=regulate_tradable_use_rights)
        elseif temp.policy=="Protected Area"
            #check if temp has mobility_rate
            return (;temp..., γ=γ_protected_area, μ=μ_protected_area, regulate=regulate_protected_area)
        elseif temp.policy=="Economic Incentives"
            return (;temp..., μ=μ_economic_incentive, regulate=regulate_economic_incentive)
        elseif temp.policy=="Development"
            return (;temp...,γ=γ_development, μ=μ_development, regulate=regulate_development)
        end
    end

    base(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal), ū=sed(mean=1.0, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    high_impact(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal), ū=sed(mean=2.0, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    low_impact(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal), ū=sed(mean=0.5, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")


    high_incentives(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.3,max=0.7, distribution=LogNormal), ū=sed(mean=1.0, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    # Socioeconomic diversity variable implementaiton

    Constant=Dirac

    struct Derived <: ContinuousUnivariateDistribution
        data::Vector{Float64}
    end

    struct Data <: ContinuousUnivariateDistribution
        data::Vector{Float64}
    end

    import Statistics.mean, Statistics.median, Statistics.std, Statistics.var
    function mean(d::Union{Derived,Data})
        return mean(d.data)
    end
    function median(d::Union{Derived,Data})
        return mean(d.data)
    end
    function std(d::Union{Derived,Data})
        return mean(d.data)
    end
    function var(d::Union{Derived,Data})
        return mean(d.data)
    end

    """
        SED{T, N, A<:AbstractArray{T,N}}

    A mutable struct representing a stochastic or deterministic distribution of data.

    # Fields
    - `data::A`: The actual data array of type `A` that stores the distribution's values.
    - `min::Union{Nothing, Float64}`: The minimum value of the distribution. If `nothing`, the minimum is not specified.
    - `max::Union{Nothing, Float64}`: The maximum value of the distribution. If `nothing`, the maximum is not specified.
    - `mean::Union{Nothing, Float64}`: The mean (average) value of the distribution. If `nothing`, the mean is not specified.
    - `median::Union{Nothing, Float64}`: The median value of the distribution. If `nothing`, the median is not specified.
    - `sigma::Union{Nothing, Float64}`: The sigma (standard deviation) of the distribution. If `nothing`, the sigma is not specified.
    - `sum::Union{Nothing, Float64}`: The sum of all values in the distribution. If `nothing`, the sum is not calculated.
    - `random::Bool`: A boolean flag to indicate whether the data should be randomly generated (`true`) or based on quantiles (`false`).
    - `normalize::Bool`: A boolean flag to indicate whether the data should be normalized.
    - `dependent::NamedTuple`: A named tuple to store dependent distributions or variables.
    - `distribution::Any`: The type of distribution, e.g., `Uniform`, `LogNormal`, or `Constant`.

    # Usage
    The `SED` struct is used to represent a distribution with specified characteristics like min, max, mean, etc. It allows for the creation of a data set that follows a specified distribution, which can be either deterministic or stochastic.

    # Example
    ```julia
    sed = SED(min=0.1, max=1.0, distribution=Uniform)
    dist!(sed, 100)
    ```
    This creates an SED instance with a uniform distribution between 0.1 and 1.0, and then generates 100 data points following this distribution.

    Function dist!

    The dist! function is a key part of working with SED. It generates or updates the data in the SED instance based on the specified distribution parameters and the number of data points N.

    Example
    ```julia
    dist!(sed, 50)
    ```
    This updates the sed instance to contain 50 data points following the previously specified distribution.

    When dist! is called, it first checks the type of distribution and then generates the data accordingly. If random is true, the data points are randomly sampled from the distribution. Otherwise, they are deterministically generated based on quantiles. The function also handles normalization if normalize is set to true.
    """
    @kwdef mutable struct SED{T, N, A<:AbstractArray{T,N}} <: AbstractArray{T,N}
        data::A = nothing
        min::Union{Nothing, Float64} = nothing
        max::Union{Nothing, Float64} = nothing
        mean::Union{Nothing, Float64} = nothing
        median::Union{Nothing, Float64} = nothing
        sigma::Union{Nothing, Float64} = nothing
        sum::Union{Nothing, Float64} = nothing
        random::Bool = false
        normalize::Bool = false
        dependent::NamedTuple = NamedTuple()
        distribution::Any = Uniform
    end

    function change(p; kwargs...)
        # Using the syntax (; p..., kwargs...) creates a new named tuple
        # that first includes all pairs from p, and then all pairs from kwargs,
        # which overwrite any matching keys from p.
        return (; p..., kwargs...)
    end

    function show(io::IO, sed::SED{T, N, A}) where {T, N, A<:AbstractArray{T,N}}
        isnothing(sed.min) ? nothing : print(io, "Min:",sed.min," ")
        isnothing(sed.max) ? nothing : print(io, "Max:",sed.max," ")
        isnothing(sed.mean) ? nothing : print(io, "Mean:",sed.mean," ")
        isnothing(sed.median) ? nothing : print(io, "Median:",sed.median," ")
        isnothing(sed.sigma) ? nothing : print(io, "Sigma:",sed.sigma," ")
        isnothing(sed.sum) ? nothing : print(io, "Sum:",sed.sum," ")
        isnothing(sed.distribution) ? nothing  : print(io, "Distribution: ",sed.random ? "random " : "",sed.normalize ? "normalize " : "",sed.distribution)
    end

    function astext(sed::SED{T, N, A}) where {T, N, A<:AbstractArray{T,N}}
        io = IOBuffer()
        
        isnothing(sed.min) ? nothing : print(io, "Min: ", sed.min, " ")
        isnothing(sed.max) ? nothing : print(io, "Max: ", sed.max, " ")
        isnothing(sed.mean) ? nothing : print(io, "Mean: ", sed.mean, " ")
        isnothing(sed.median) ? nothing : print(io, "Median: ", sed.median, " ")
        isnothing(sed.sigma) ? nothing : print(io, "Sigma: ", sed.sigma, " ")
        isnothing(sed.sum) ? nothing : print(io, "Sum: ", sed.sum, " ")
        isnothing(sed.distribution) ? nothing : print(io,  sed.random ? "random " : "",sed.normalize ? "normalize " : "", sed.distribution)

        str = String(take!(io))
        str = replace(str, "Distributions." => "")
        str = replace(str, "{Float64}" => "")

        close(io)
        
        return str
    end


    function dist(s::SED,N::Int64)
        dist!(s,N)
        return s
    end

    # in case you define a variable that is not a SED type
    function dist!(s,N::Int64)
        return s
    end

    # Helper function to generate a lognormal distribution from a min and max
    function lognormal(min; stop=1.0,length=10)
        min==0.0 ? min=0.01 : nothing # Note, I adjust min to not be ==0
        min>stop ? stop=min+0.01 : nothing
        if length==1
        return middle(min,stop)
        else
        #lr=norminvcdf.(collect(range(0.0,stop=1.0,length=length+2))[2:end-1])
        lr=quantile.(Normal(0.0,2.0),collect(range(1/(length),stop=1.0-1/(length),length=length)))
        lr.-=lr[1]
        lr./=lr[end]
        lr.*=(log(stop)-log(min))
        lr.+=log(min)
        return exp.(lr)
        end
    end

    function dist!(s::SED, N::Int64)
        rev=false
        if s.distribution==LogNormal
            if s.min !== nothing && s.max !== nothing
                rev=s.min>s.max
                if s.max!=s.min && N>1
                    temp=lognormal(minimum([s.min,s.max]),stop=maximum([s.min,s.max]),length=N)
                    medianLN=median(temp)
                    spreadLN=std(log.(temp))
                    s.distribution=LogNormal(log(medianLN),spreadLN)
                else
                    s.distribution=Constant(N==1 ? middle(s.min,s.max) : s.min)
                end
            elseif s.mean!== nothing && s.sigma!==nothing 
                rev= s.sigma<0
                s.distribution=s.sigma!=0.0 ? LogNormal(log(s.mean)-abs(s.sigma)^2/2,abs(s.sigma)) : Constant(s.mean)
            elseif s.median!== nothing && s.sigma!==nothing
                rev= s.sigma<0
                s.distribution=s.sigma!=0.0 ? LogNormal(log(s.median),abs(s.sigma)) : Constant(s.median)
            end
            if s.random==true
                s.data=rand(s.distribution,N)
            else
                if N>1
                    s.data=rev ? reverse(quantile.(s.distribution,range(1/N, stop=1-1/N, length=N))) : quantile.(s.distribution,range(1/N, stop=1-1/N, length=N))
                end
            end

        elseif s.distribution==Uniform
            if s.min !== nothing && s.max !== nothing
                rev=s.min>s.max
                if s.max!=s.min
                    s.distribution=Uniform(minimum([s.min,s.max]),maximum([s.min,s.max]))
                else
                    s.distribution=Constant(s.min)
                end
            elseif s.mean!== nothing && s.sigma!==nothing 
                rev= s.sigma<0
                s.distribution=s.sigma!=0.0 ? Uniform(s.mean-abs(s.sigma)/2,s.mean+abs(s.sigma)/2) : Constant(s.mean)
            elseif s.median!== nothing && s.sigma!==nothing
                rev= s.sigma<0
                s.distribution=s.sigma!=0.0 ? Uniform(s.median-abs(s.sigma)/2,s.median+abs(s.sigma)/2) : Constant(s.median)
            end
            if s.random==true
                s.data=rand(s.distribution,N)
            else
                s.data=rev ? reverse(quantile.(s.distribution,N==1 ? [0.5] : range(1/N, stop=1-1/N, length=N))) : quantile.(s.distribution,N==1 ? [0.5] : range(1/N, stop=1-1/N, length=N))
            end
        elseif s.distribution==Constant
            s.distribution=Constant(s.min)
        elseif s.distribution==Exponential
            s.distribution=Exponential(s.mean)
            s.data=s.random==true ? rand(s.distribution,N) : quantile.(s.distribution,N==1 ? [0.5] : range(1/N, stop=1-1/N, length=N))
        elseif s.distribution==Beta
            s.distribution=Beta(s.min,s.max)
            s.data=s.random==true ? rand(s.distribution,N) : quantile.(s.distribution,N==1 ? [0.5] : range(1/N, stop=1-1/N, length=N))
        end
        
        s.normalize ? s.data=s.data./N : nothing
        return s
    end# Define a default constructor for when no arguments are given



    function sed(; data=nothing, min=nothing, max=nothing, kwargs...)
        T = Float64  # Default type if not inferred from `data`
        N = 1        # Default number of dimensions
        A = Array{T, N} # Default array type if not inferred from `data`

        # Infer the type and dimensions from provided data
        if data !== nothing
            T, N = eltype(data), ndims(data)
            A = typeof(data)
        else

            data = A(undef, 0) # Or however you want to handle the case where there is no data

        end
        
        sed = SED{T, N, A}(;data, min, max, kwargs...)
        return sed
    end

    # functions to make SED behave like any array
    Base.size(a::SED) = size(a.data)
    Base.getindex(a::SED, i...) = getindex(a.data, i...)
    Base.setindex!(a::SED, v, i...) = setindex!(a.data, v, i...)
    function Base.similar(a::SED{T, N, A}, ::Type{T}, dims::Dims) where {T, N, A<:AbstractArray{T,N}}
        return SED(
            data = similar(a.data, T, dims),
            min = a.min,
            max = a.max,
            mean = a.mean,
            median = a.median,
            sigma = a.sigma,
            sum = a.sum,
            random = a.random,
            normalize = a.normalize,
            dependent = a.dependent,
            distribution = a.distribution
        )
    end
    Base.iterate(a::SED, state...) = iterate(a.data, state...)

    function pdf(s::SED)
        [pdf(s.distribution,xx) for xx in s]
    end

    function phase_plot!(axis,sol; show_trajectory=false, show_target=false, open_access_color=:lightgray, incentive_line_color=:darkorange, impact_line_color=:darkorange, t=0.0, show_exploitation=true)


        if show_exploitation
            poly!(axis, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.0, 0.5, 0.1))
            #poly!(A, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.5, 0.5, 0.1))
            #poly!(A, Rect(0.5, 0, 0.5, 1), color=HSLA(180, 0.5, 0.5, 0.1))
        end
        ## Fix the market price placement
        
        scenario=sol.prob.p
        N=scenario.N
        limits!(axis,0.0,1.0,0.0,1.0)
    
        y=range(0.0,stop=1.0,length=100)
        γ_array=scenario.γ(sol.u[end],scenario,sol.t[end])
        oa=change(scenario,γ=γ, μ=μ,regulate=regulate, ϕ=ϕ)
        oasol=sim(oa,regulation=0.0)

        if show_target
            if haskey(scenario,:policy_target)
                Y=scenario.policy_target==:effort ? ones(length(y)) : y
                lines!(axis,y,Φ.(1 .-(1-scenario.regulation)./Y,Ref(scenario)), color=:darkorange, linestyle=:dot)
            end
        end
    
        # Cumulative incentive distributions
        lines!(axis,y,Γ.(y,Ref(oa),x=sol.u[end-1]), color=open_access_color, linewidth=3)
        lines!(axis,y,Γ.(y,Ref(scenario),x=sol.u[end-1];t), color=incentive_line_color, linewidth=3)
    
        # Cumulative impact istributions
        lines!(axis,y,Φ.(y,Ref(oa)), color=open_access_color, linewidth=1)
        lines!(axis,y,Φ.(y,Ref(scenario);t), color=impact_line_color,linewidth=1)
    
        if show_trajectory
            # Show trajectory
            lines!(axis,[u[scenario.N+1] for u in sol.u[1:end-1]],[sum(u[1:scenario.N]./scenario.μ(u,scenario,sol.t[i]))/scenario.N for (i,u) in enumerate(sol.u[1:end-1])], color=scenario.policy=="Development" ? sol.t[1:end-1] : :gray, linestyle=:dot, colormap=cgrad([:lightgray, :darkorange], [0.0, 0.5, 1.0]))
        end

        # Show the attractor
        scatter!(axis,[sol[N+1,end-2]],[sum(sol[1:N,end-2]./scenario.μ(sol.u[end-2],scenario,sol.t[end-2])./N)], color=:black, markersize=10)

        scatter!(axis,[oasol[N+1,end-2]],[sum(oasol[1:N,end-2]./oa.μ(oasol.u[end-2],oa,oasol.t[end-2])./N)], color=:black, markersize=15, marker='o')

        if scenario.policy=="Development"
            scatter!(axis,[sol[N+1,1]],[sum(sol[1:N,1]./scenario.μ(sol.u[end-1],scenario,sol.t[1])./N)], color=:white, markersize=15)
        end
    
        # Show the market price of use rights
        scenario.policy=="Tradable Use Rights" ? text!(axis,"ϕ: "*string(round(sol[end,end],digits=2))) : nothing
    end

end