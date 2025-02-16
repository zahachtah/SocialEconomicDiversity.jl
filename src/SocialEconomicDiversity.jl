module SocialEconomicDiversity

    using Colors, Statistics, Distributions, OrdinaryDiffEq, CairoMakie, FileIO,  Random,  ColorSchemes
    using DiffEqCallbacks: TerminateSteadyState
    using Parameters
    import Base: show
    using Base: @kwdef

    include("sed.jl")
    export SED,sed, dist!,astext
    export sim
    export scenario, base, high_impact, low_impact, high_incentives
    export γ, μ,ϕ,regulate
    export Γ, Φ
    export γ_assigned_use_rights, regulate_assigned_use_rights
    export γ_tradable_use_rights, ϕ_tradable_use_rights,regulate_tradable_use_rights
    export γ_economic_incentive, μ_economic_incentive, regulate_economic_incentive
    export Uniform, LogNormal, Normal, Exponential, Dirac
    export phase_plot!, bg_plot!, Γ_plot!, Φ_plot!, attractor_plot!, trajecory_plot!, target_plot!, arrow_arc!, arrow_arc_deg!, incomes_plot!
    export incomes, regulation_scan, gini

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
    function sim(s; u0=zeros(s.N), y0=1.0,ϕ0=0.0, regulation=0.0, start_from_OA=false,t_end=1000.0)
        isempty(s.w̃.data) ?  dist!(s.w̃,s.N) : nothing
        isempty(s.ū.data) ?  dist!(s.ū,s.N) : nothing
        tspan=(0.0,t_end)
        p=s.regulate(s,regulation)
       
        if s.policy=="Tradable Use Rights"
            initVals=[u0;y0;ϕ0]
        else
            initVals=[u0;y0]
        end

        if start_from_OA
            #q=change(p,policy="Open Access", γ=γ, ϕ=ϕ,  μ=μ,regulate=regulate)
            oa=p.regulate(p,0.0)
            oaprob = ODEProblem(dxdt,initVals,tspan,oa);
            oasol=solve(oaprob,SSPRK432(;stage_limiter!),callback= TerminateSteadyState(1e-6,1e-4) )
            initVals[1:oa.N+1]=oasol[1:oa.N+1,end-2]
        end

         prob = ODEProblem(dxdt,initVals,tspan,p);
 
    
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
            n=Int64(round((f)*scenario.N))# Integer fraction f of number of users
            if n!=0
                if haskey(scenario,:reverse)
                    scenario.reverse ? R[max(1,end-n):end].=1.0 : R[1:n].=1.0
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
	    if f_p==0.0
            return K
        end
        r_p=r*(1+xr)
		K_p=K*(1+xK)
	    # Calculate the scaled mobility factor
	    k = (1.0 - f_p) / f_p * m
	    # Compute the discriminant of the quadratic equation
	    discriminant = max(0.0,(r_p - k)^2 + 4.0 * r_p * k * y / K_p)
	    
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
        if :μ in vcat(p.policy_target)
		    return p.ū.*(1-p.regulation * (p.policy_method==:taxation ? -1.0 : 1.0))
        else 
            return p.ū
        end
	end

    function γ_economic_incentive(x,p,t)
        if :γ in vcat(p.policy_target)
            if p.policy_method==:additive
                return p.w̃.+p.regulation
            else
                return p.w̃.*(1-p.regulation*(p.policy_method==:taxation ? -1.0 : 1.0))
            end
        else
            return p.w̃
        end
	end

    #=

        =#

    # Development
    function regulate_development(p,f)
		return change(p,regulation=f)
	end
	
	function μ_development(x,p,t)
		return p.ū.+p.regulation*2/p.N*t/1000*p.μ_value
	end

	function γ_development(x,p,t)
		
		return p.w̃.+p.regulation*t/1000*p.γ_value
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
            return (;temp..., μ=μ_economic_incentive, regulate=regulate_economic_incentive, γ=γ_economic_incentive)
        elseif temp.policy=="Development"
            return (;temp...,γ=γ_development, μ=μ_development, regulate=regulate_development, μ_value=0.5, γ_value=0.5)
        end
    end

    base(; N=100, sigma=0.0, random=false)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal, random=random), ū=sed(mean=1.0, sigma=sigma, normalize=true, random=random), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    high_impact(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal), ū=sed(mean=2.0, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    low_impact(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.01,max=0.6, distribution=LogNormal), ū=sed(mean=0.5, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")


    high_incentives(; N=100, sigma=0.0)=(;N, α=0.1, w̃=sed(min=0.3,max=0.7, distribution=LogNormal), ū=sed(mean=1.0, sigma=sigma, normalize=true), R=ones(N), γ, ϕ, μ,regulate, policy="Open Access")

    function incomes(x,p; summarize=false)
        resource=x[1:p.N].*x[p.N+1]
        wages=(p.ū.-x[1:p.N]).*p.w̃ #μ(x,p,0.0) ?
        trade= p.policy=="Tradable Use Rights" ? (p.R.-x[1:p.N]).*x[p.N+2] : fill(0.0,p.N)
        #println((sum(p.R),x[p.N+2]))
        total=resource.+wages.+trade
        g=gini(total)
        ecological=x[p.N+1]
        return summarize ? (;resource,wages,trade,total,g,ecological) : (;resource,wages,trade,total,gini=g,ecological)
    end

    function gini(x)
        sum([abs(x[i]-x[j]) for i in 1:length(x), j in 1:length(x)])/(2*length(x)*sum(x))
    end

    function regulation_scan(p;m=100)
        
        r=range(0.0,stop=1.0,length=m)
        RR=zeros(m)
        WR=zeros(m)
        TR=zeros(m)
        ToR=zeros(m)
        GI=zeros(m)
        EH=zeros(m)
        RI=zeros(m)
        oau=zeros(p.N)
        x0=zeros(p.N+2)
        x0[p.N+1]=1.0
        sols=zeros(m,p.N)
        for (j,i) in enumerate(r)
            #P=p.regulate(p,i)
            sol=sim(p, regulation=i,t_end=1000)#, u0=x0[1:p.N],y0=x0[p.N+1], ϕ0=x0[p.N+1]

            if j==1
                oau=sol[1:p.N,end-1]
            end
            
            inc=incomes(sol.u[end-1],sol.prob.p)
            #println((sum(s.prob.p.R),sum(inc.total)))
            RR[j]=sum(inc.resource)
            WR[j]=sum(inc.wages)
            TR[j]=sum(inc.trade)
            ToR[j]=sum(inc.total)
            GI[j]=inc.gini
            EH[j]=inc.ecological
            RI[j]=sum(abs.(oau.-sol[1:p.N,end-1]))
            sols[j,:]=sol.u[end-1][1:p.N]
        end
        oRR=argmax(RR)
        oWR=argmax(WR)
        oTR=argmax(TR)
        oToR=argmax(ToR)
        oGI=argmin(GI)
        oEH=argmax(EH)
        oRI=argmax(EH)
        return (;RR,WR,TR,ToR,GI,EH,RI,r,oRR,oWR,oTR,oToR,oGI,oEH,oRI,sols)
    end
#=
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
    =#

    function Γ_plot!(axis,sol;color=:darkorange, linewidth=3, t=0.0)
        y=range(0.0,stop=1.0,length=100)
        lines!(axis,y,Γ.(y,Ref(sol.prob.p),x=sol.u[end-1]; t); color, linewidth)
    end

    function Φ_plot!(axis,sol;color=:darkorange, linewidth=3, t=0.0)
        y=range(0.0,stop=1.0,length=100)
        lines!(axis,y,Φ.(y,Ref(sol.prob.p); t); color, linewidth)
    end

    function attractor_plot!(axis,sol;color=:darkorange, markersize=15, marker=:circle)
        N=sol.prob.p.N
        scatter!(axis,[sol[N+1,end-2]],[sum(sol[1:N,end-2]./sol.prob.p.μ(sol.u[end-2],sol.prob.p,sol.t[end-2])./N)]; color, markersize,marker)
    end

    function trajecory_plot!(axis,sol; color=:darkorange, startcolor=:lightgray, linewidth=2)
        scenario=sol.prob.p
        lines!(axis,[u[scenario.N+1] for u in sol.u[1:end-2]],[sum(u[1:scenario.N]./scenario.μ(u,scenario,sol.t[i]))/scenario.N for (i,u) in enumerate(sol.u[1:end-2])]; color, linestyle=:dot, colormap=cgrad([startcolor, color], [0.0, 0.5, 1.0]),linewidth)
    
    end

    function bg_plot!(axis;show_exploitation=true)
        limits!(axis,0.0,1.0,0.0,1.0)
        if show_exploitation
            poly!(axis, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.0, 0.5, 0.1))
            #poly!(A, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.5, 0.5, 0.1))
            #poly!(A, Rect(0.5, 0, 0.5, 1), color=HSLA(180, 0.5, 0.5, 0.1))
        end
    end

    function target_plot!(axis,sol;color=:darkorange, linestyle=:dash, linewidth=3)
        scenario=sol.prob.p
        y=range(0.0,stop=1.0,length=100)
            if haskey(scenario,:policy_target)
                Y=scenario.policy_target==:effort ? ones(length(y)) : y
                lines!(axis,y,Φ.(1 .-(1-scenario.regulation)./Y,Ref(scenario)); color,linewidth, linestyle)
            end

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

    function arrow_arc!(ax, origin, radius, start_angle, stop_angle; linewidth=1, color=:black,flip_arrow=false,linestyle=:dot)
        # Draw the arc
        arc!(ax, origin, radius, start_angle, stop_angle, linewidth=linewidth, color=color;linestyle)
    
        # Function to calculate a point on the circle
        point_on_circle(θ) = origin .+ radius * Point2f(cos(θ), sin(θ))
    
        # Calculate the direction of the arrow at the start and end of the arc
        start_dir = Point2f(cos(start_angle + π/2 + (flip_arrow ? pi/2 : 0)), sin(start_angle + π/2+ (flip_arrow ? pi/2 : 0)))
        end_dir = Point2f(cos(stop_angle - π/2 + (flip_arrow ? pi : 0)), sin(stop_angle - π/2+ (flip_arrow ? pi : 0)))
        dx=0.001
        # Add arrow at the start and end of the arc
        # Adjust the multiplier for start_dir and end_dir to control the arrow orientation
        arrows!(ax, [point_on_circle(start_angle)[1]],[point_on_circle(start_angle)[2]], [start_dir[1]]*dx,[start_dir[2]]*dx, color=color, linewidth=linewidth)
        arrows!(ax, [point_on_circle(stop_angle)[1]],[point_on_circle(stop_angle)[2]], [end_dir[1]]*dx,[end_dir[2]]*dx, color=color, linewidth=linewidth)
    end


    function arrow_arc_deg!(
        ax,
        origin,
        radius,
        start_angle_deg,
        stop_angle_deg;
        linewidth=1,
        color=:black,
        flip_arrow=false,
        linestyle=:dot,
        startarrow=false
    )
    
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
        arc!(
            ax,
            origin,
            radius,
            rad_start,
            rad_stop,
            linewidth=linewidth,
            color=color;
            linestyle=linestyle
        )
    
        # 2) Function to calculate a point on the circle at a given *degree* measure:
        point_on_circle_deg(θ_deg) = origin .+ radius * Point2f(
            cos(deg2rad(90 - θ_deg)),
            sin(deg2rad(90 - θ_deg))
        )
    
        # 3) Arrow directions at start and end.
        #
        #   - We add ± π/2 so that the direction is tangent to the circle.
        #   - The flip_arrow boolean is preserved as in your code, toggling extra phase shifts.
        #
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
            linewidth=linewidth
        )
    end

    function incomes_plot!(aa,sol; order=false, color=:darkorange)
        p=sol.prob.p
        oa=sim(p,regulation=0.0)

        oa_resource_revenue=oa[1:p.N,end-1].*oa[p.N+1,end-1]
        oa_alt_revenues=p.w̃.*(p.μ(oa[:,end-1],p,0.0) .-oa[1:p.N,end-1])

        resource_revenue=sol[1:p.N,end-1].*sol[p.N+1,end-1]
        alt_revenues=p.w̃.*(p.μ(sol[:,end-1],p,0.0) .-sol[1:p.N,end-1])
        trade_revenues=p.policy=="Tradable Use Rights" ? (p.R.-sol[1:p.N,end-1])*sol[end,end-1] : fill(0.0,p.N) 
        income=resource_revenue+alt_revenues+trade_revenues
        inc=resource_revenue+alt_revenues

        oa_inc=incomes(oa.u[end-1],oa.prob.p)
        r_inc=incomes(sol.u[end-1],sol.prob.p)

        resource_revenue=r_inc.resource
        alt_revenues=r_inc.wages
        trade_revenues=r_inc.trade
        income=r_inc.total
        inc=resource_revenue+alt_revenues
        id=order ? sortperm(income) : collect(1:p.N)
        barplot!(aa,inc[id], color=order ? p.w̃[id] : color, alpha=1.0, offset=trade_revenues[id])
        barplot!(aa,trade_revenues[id], color=order ? p.w̃[id] : color)
        barplot!(aa,trade_revenues[id], color=HSLA(0,0,0,0.2))
        barplot!(aa,trade_revenues[id], color=HSLA(0,0,0,0.2))
        fir=findall(resource_revenue[id].>0.0)
        fia=findall(alt_revenues[id].>0.0)
        oafir=findall(oa_resource_revenue[id].>0.0)
        oafia=findall(oa_alt_revenues[id].==0.0)
        #scatter!(aa,collect(1:p.N)[fia],alt_revenues[id][fia].+trade_revenues[id][fia], color=:crimson, markersize=10, marker=:hline)
        #scatter!(aa,collect(1:p.N)[oafir],oa_resource_revenue[id][oafir], color=:darkgray, markersize=5)
        #scatter!(aa,collect(1:p.N)[oafia],oa_alt_revenues[id][oafia], color=:lightgray, markersize=5)
        #lines!(aa,1:p.N,fill(0.0,p.N), color=:white)
    
    end

end




