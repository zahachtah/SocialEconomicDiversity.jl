### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ d616345e-ada8-421e-9f62-d7811498de06
begin

    using Colors, Statistics, Distributions, OrdinaryDiffEq, CairoMakie, FileIO, Random, ColorSchemes
    using DiffEqCallbacks: TerminateSteadyState
    using Parameters
    import Base: show
    using Base: @kwdef


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

	incomes(sol::ODESolution;dimensional=false) = incomes(sol.u[end], sol.prob.p; dimensional)



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

# =============================================================================
	# SocialEconomicDiversity.jl
	#
	# This module provides a type `SED` for generating socio‐economic distributions
	# that can optionally depend on other variables. Dependencies are now resolved
	# by passing in a context (a NamedTuple containing all SEDs), rather than by a
	# global lookup. In addition, you can specify a custom dependency relationship.
	#
	# For example, you can write:
	#
	#     w̃ = sed(dependent=(ē = 1.0, q = 1.0, r = 1.0, fun = (dep -> (dep.ē * dep.q) / dep.r)), 
	#              min = 0.1, max = 0.2, distribution = LogNormal)
	#
	# and later call `dist!(w̃, N, context)` where `context` is a NamedTuple containing
	# w̃ and the SEDs named `ē`, `q`, and `r`.
	#
	# Written with clarity, type safety, and efficiency in mind.
	# =============================================================================
	
	
	# Explicitly import functions from Statistics to avoid ambiguity.
	#import Statistics: mean, median, std, var
	
	# -----------------------------------------------------------------------------
	# Basic Data Types
	# -----------------------------------------------------------------------------
	import Statistics: mean, median, std, var
	"""
	    Derived(data::Vector{Float64})
	
	A simple wrapper type representing a distribution derived from data.
	"""
	struct Derived <: ContinuousUnivariateDistribution
	    data::Vector{Float64}
	end
	
	"""
	    Data(data::Vector{Float64})
	
	A simple wrapper type representing a distribution constructed directly from data.
	"""
	struct Data <: ContinuousUnivariateDistribution
	    data::Vector{Float64}
	end
	
	# Extend statistical functions to work on Derived and Data.
	mean(d::Union{Derived, Data}) = Statistics.mean(d.data)
	median(d::Union{Derived, Data}) = Statistics.median(d.data)
	std(d::Union{Derived, Data}) = Statistics.std(d.data)
	var(d::Union{Derived, Data}) = Statistics.var(d.data)
	Constant=Dirac
	
	# -----------------------------------------------------------------------------
	# SED Type Definition
	# -----------------------------------------------------------------------------
	
	"""
	    SED{T, N, A<:AbstractArray{T, N}} <: AbstractArray{T, N}
	
	A container for a (stochastic or deterministic) distribution with optional
	dependencies on other variables.
	
	# Fields
	- `data::A`: Array holding the generated values.
	- `min, max, mean, median, sigma, sum`: Optional distribution parameters.
	- `random::Bool`: If `true`, generate data randomly (using `rand`); otherwise by quantiles.
	- `normalize::Bool`: If `true`, normalize the generated data.
	- `dependent::NamedTuple`: Specifies dependencies. In the simplest case each key (other than `fun`)
	   is taken as a coefficient for the corresponding variable. If a key `:fun` is present, its value
	   (which must be a function) is used to compute the dependent contribution.
	- `distribution`: The base distribution type (e.g. `Uniform`, `LogNormal`, etc.).
	- `dependency_function::Function`: A function that combines the independent data with the dependent
	   contribution. (Default: elementwise addition.)
	"""
	@kwdef mutable struct SED{T, N, A<:AbstractArray{T, N}} <: AbstractArray{T, N}
	    data::A = nothing
	    min::Union{Nothing, Float64} = nothing
	    max::Union{Nothing, Float64} = nothing
	    mean::Union{Nothing, Float64} = nothing
	    median::Union{Nothing, Float64} = nothing
	    sigma::Union{Nothing, Float64} = nothing
	    sum::Union{Nothing, Float64} = nothing
	    random::Bool = false
	    normalize::Bool = false
	    dependent::NamedTuple = NamedTuple()   # e.g., (ē = 1.0, q = 1.0, r = 1.0, fun = (dep -> (dep.ē * dep.q) / dep.r))
	    distribution::Any = Uniform              # e.g., Uniform, LogNormal, etc.
	    dependency_function::Function = (indep, dep) -> indep .+ dep
	end
	
	# -----------------------------------------------------------------------------
	# Helper Functions
	# -----------------------------------------------------------------------------
	
	"""
	    change(params::NamedTuple; kwargs...) -> NamedTuple
	
	Return a new NamedTuple with keys and values from `params` updated by `kwargs`.
	"""
	change(params::NamedTuple; kwargs...) = (; params..., kwargs...)
	
	"""
	    lognormal_range(min::Float64; stop::Float64 = 1.0, length::Int = 10) -> Vector{Float64}
	
	Generate `length` values logarithmically spaced between `min` and `stop`.
	If `min` is zero, it is replaced with a small positive value.
	"""
	function lognormal_range(min::Float64; stop::Float64 = 1.0, length::Int = 10)
	    min = (min == 0.0) ? 0.01 : min
	    stop = (min > stop) ? min + 0.01 : stop
	    if length == 1
	        return [(min + stop) / 2]
	    else
	        qs = collect(range(1/length, stop = 1 - 1/length, length = length))
	        lr = quantile.(Normal(0.0, 2.0), qs)
	        lr .-= lr[1]
	        lr ./= lr[end]
	        lr .*= (log(stop) - log(min))
	        lr .+= log(min)
	        return exp.(lr)
	    end
	end
	
	# -----------------------------------------------------------------------------
	# Dependency Resolution
	# -----------------------------------------------------------------------------
	
	"""
	    apply_dependencies!(sed::SED, N::Int, context::NamedTuple) -> sed
	
	Updates `sed.data` by combining its independent data with a dependent contribution.
	The dependent contribution is computed from the dependency specification in `sed.dependent`
	using the provided `context`. The key `:fun` (if present) is reserved for a custom function
	and is not used to scale dependency variables.
	"""
	function apply_dependencies!(sed::SED, N::Int, context::NamedTuple)
	    isempty(sed.dependent) && return sed  # Nothing to do if no dependencies.
	
	    if haskey(sed.dependent, :fun)
	        # Custom dependency mode.
	        # Retrieve the custom function.
	        fun = sed.dependent.fun
	        # Build a NamedTuple of factors that excludes the :fun key.
	        factors = (; (k => v for (k, v) in pairs(sed.dependent) if k != :fun)...)
	        # Build a NamedTuple of dependency values from the context.
	        depvals = (; (k => (haskey(context, k) ? 
	                                (hasproperty(context[k], :data) ? context[k].data : context[k]) :
	                                error("Context does not contain dependency variable $(k)"))
	                         for k in keys(factors))...)
	        # Scale each dependency value by its corresponding factor.
	        scaled_dep = (; (k => factors[k] * depvals[k] for k in keys(depvals))...)
	        # Compute the custom dependency contribution.
	        dep_contrib = fun(scaled_dep)
	        # Combine with the independent data.
	        sed.data = sed.dependency_function(sed.data, dep_contrib)
	    else
	        # Default mode: sum the dependencies.
	        dep_sum = zeros(eltype(sed.data), N)
	        for (name, factor) in pairs(sed.dependent)
	            # Skip the :fun key if it appears.
	            if name == :fun
	                continue
	            end
	            if haskey(context, name)
	                var = context[name]
	                dep_data = hasproperty(var, :data) ? var.data : var
	                contribution = factor isa Function ? factor(dep_data) : factor .* dep_data
	                dep_sum .+= contribution
	            else
	                error("Context does not contain dependency variable $(name)")
	            end
	        end
	        sed.data = sed.dependency_function(sed.data, dep_sum)
	    end
	    return sed
	end
	
	
	"""
	    is_distribution_type(sed::SED, T::DataType) -> Bool
	
	Returns true if `sed.distribution` is either exactly the bare type `T`
	(or a subtype of `T` when stored as a bare type) or is an instance of `T`.
	"""
	function is_distribution_type(sed, dist)
	    return sed.distribution == dist || sed.distribution isa dist
	end
	
	"""
	    has_dependencies(sed::SED) -> Bool
	
	Returns true if the SED has dependencies.
	"""
	function has_dependencies(sed::SED)
	    return !isempty(sed.dependent)
	end
	
	"""
	    is_property_name(s::Symbol, property_name::Symbol) -> Bool
	
	Check if a symbol matches a parameter name, handling special cases
	like w̃ and ū.
	"""
	function is_property_name(s::Symbol, property_name::Symbol)
	    return s == property_name || 
	           (s == :w && property_name == :w̃) ||
	           (s == :u && property_name == :ū)
	end
	
	"""
	    find_sed_by_name(context::NamedTuple, name::Symbol) -> Union{SED, Nothing}
	
	Find an SED by name in the context, handling special cases for w̃ and ū.
	"""
	function find_sed_by_name(context::NamedTuple, name::Symbol)
	    for (k, v) in pairs(context)
	        if v isa SED && is_property_name(name, k)
	            return v
	        end
	    end
	    return nothing
	end
	
	# -----------------------------------------------------------------------------
	# Distribution Generation
	# -----------------------------------------------------------------------------
	
	"""
	    generate_distribution!(sed::SED, N::Int) -> sed
	
	Generate the distribution data for the SED, without applying dependencies.
	"""
	function generate_distribution!(sed::SED, N::Int)
	    rev = false  # Flag for reversed quantiles
	    if is_distribution_type(sed, LogNormal)
	        # LogNormal branch...
	        if sed.min !== nothing && sed.max !== nothing
	            rev = sed.min > sed.max
	            if sed.max != sed.min && N > 1
	                tmp = lognormal_range(minimum((sed.min, sed.max)),
	                                      stop = maximum((sed.min, sed.max)),
	                                      length = N)
	                medianLN = median(tmp)
	                spreadLN = std(log.(tmp))
	                sed.distribution = LogNormal(log(medianLN), spreadLN)
	            else
	                sed.distribution = Constant(N == 1 ? (sed.min + sed.max) / 2 : sed.min)
	            end
	        elseif sed.mean !== nothing && sed.sigma !== nothing
	            rev = sed.sigma < 0
	            sed.distribution = (sed.sigma != 0.0) ?
	                LogNormal(log(sed.mean) - abs(sed.sigma)^2/2, abs(sed.sigma)) :
	                Constant(sed.mean)
	        elseif sed.median !== nothing && sed.sigma !== nothing
	            rev = sed.sigma < 0
	            sed.distribution = (sed.sigma != 0.0) ?
	                LogNormal(log(sed.median), abs(sed.sigma)) :
	                Constant(sed.median)
	        end
	        if sed.random
	            sed.data = rand(sed.distribution, N)
	        else
	            qs = quantile.(Ref(sed.distribution), range(1 / N, stop = 1 - 1 / N, length = N))
	            sed.data = (N > 1) ? (rev ? reverse(qs) : qs) : [quantile(sed.distribution, 0.5)]
	        end
	
	    elseif is_distribution_type(sed, Uniform)
	        # Uniform branch...
	        if sed.min !== nothing && sed.max !== nothing
	            rev = sed.min > sed.max
	            if sed.max != sed.min
	                sed.distribution = Uniform(minimum((sed.min, sed.max)),
	                                           maximum((sed.min, sed.max)))
	            else
	                sed.distribution = Constant(sed.min)
	            end
	        elseif sed.mean !== nothing && sed.sigma !== nothing
	            rev = sed.sigma < 0
	            sed.distribution = (sed.sigma != 0.0) ?
	                Uniform(sed.mean - abs(sed.sigma)/2, sed.mean + abs(sed.sigma)/2) :
	                Constant(sed.mean)
	        elseif sed.median !== nothing && sed.sigma !== nothing
	            rev = sed.sigma < 0
	            sed.distribution = (sed.sigma != 0.0) ?
	                Uniform(sed.median - abs(sed.sigma)/2, sed.median + abs(sed.sigma)/2) :
	                Constant(sed.median)
	        end
	        if sed.random
	            sed.data = rand(sed.distribution, N)
	        else
	            qs = quantile.(Ref(sed.distribution), range(1 / N, stop = 1 - 1 / N, length = N))
	            sed.data = (N == 1) ? [quantile(sed.distribution, 0.5)] : (rev ? reverse(qs) : qs)
	        end
	    elseif is_distribution_type(sed, Dirac)
	        p = sed.mean !== nothing ? sed.mean :
	        sed.distribution = Dirac(p)
	        sed.data = rand(sed.distribution, N)
	    elseif is_distribution_type(sed, Bernoulli)
	        # Bernoulli branch: use sed.mean as the probability parameter.
	        p = sed.mean !== nothing ? sed.mean :
	            error("For Bernoulli, please specify the probability in sed.mean")
	        sed.distribution = Bernoulli(p)
	        if sed.random
	            sed.data = rand(sed.distribution, N)
	        else
	            # For a discrete distribution like Bernoulli, quantiles are defined (0 or 1)
	            qs = quantile.(Ref(sed.distribution), range(1 / N, stop = 1 - 1 / N, length = N))
	            sed.data = qs
	        end
	    # ... other branches for ConstantDistribution, Exponential, Beta, etc.
	
	    else
	        error("Unsupported distribution type: $(sed.distribution)")
	    end
	
	    if sed.normalize
	        sed.data .= sed.data ./ N
	    end
	
	    return sed
	end
	
	"""
	    dist!(sed::SED, N::Int; context=nothing) -> sed
	
	Generate (or update) `sed.data` with `N` points using the specified distribution.
	After generating the independent data, apply dependency calculations using the
	provided `context`.
	"""
	function dist!(sed::SED, N::Int; context=nothing)
	    # Generate the distribution
	    generate_distribution!(sed, N)
	    
	    # Apply dependencies if context is provided
	    if context !== nothing
	        apply_dependencies!(sed, N, context)
	    end
	    
	    return sed
	end
	
	"""
	    dist!(s, param_name::Symbol) -> SED
	
	Generate distributions for the SED parameter specified by name.
	Uses s.N as the length of the distribution.
	"""
	function dist!(s, param_name::Symbol)
	    N = s.N
	    sed = find_sed_by_name(s, param_name)
	    if sed === nothing
	        error("Could not find SED parameter named $(param_name) in the scenario")
	    end
	    return dist!(sed, N; context=s)
	end
	
	"""
	    dist!(s) -> NamedTuple
	
	Generate distributions for all SED parameters in the scenario.
	First processes independent SEDs, then dependent ones.
	Uses s.N as the length of the distributions.
	"""
	function dist!(s)
	    N = s.N
	    
	    # Identify all SED parameters
	    sed_params = []
	    for (k, v) in pairs(s)
	        if v isa SED
	            push!(sed_params, (k, v, has_dependencies(v)))
	        end
	    end
	    
	    # First process independent SEDs
	    for (k, v, has_deps) in sed_params
	        if !has_deps
	            dist!(v, N)
	        end
	    end
	    
	    # Then process dependent SEDs
	    for (k, v, has_deps) in sed_params
	        if has_deps
	            dist!(v, N; context=s)
	        end
	    end
	    
	    return s
	end
	
	"""
	    dist!(context::NamedTuple, N::Int) -> NamedTuple
	
	Applies `dist!(sed, N, context)` to each SED in the provided context and returns
	a new NamedTuple with the updated SEDs.
	"""
	function dist!(context::NamedTuple, N::Int)
	    new_context = map(x -> (x isa SED ? dist!(x, N; context=context) : x), context)
	    return new_context
	end
	
	# -----------------------------------------------------------------------------
	# Making SED Behave Like an Array
	# -----------------------------------------------------------------------------
	
	Base.size(sed::SED) = size(sed.data)
	Base.getindex(sed::SED, idx...) = getindex(sed.data, idx...)
	Base.setindex!(sed::SED, value, idx...) = setindex!(sed.data, value, idx...)
	
	"""
	    similar(sed::SED, ::Type{T}, dims::Dims) -> SED
	
	Creates a new SED instance with an uninitialized data array of type `T` and dimensions
	`dims`, copying all other parameters from the original.
	"""
	function Base.similar(sed::SED{T, N, A}, ::Type{T}, dims::Dims) where {T, N, A<:AbstractArray{T, N}}
	    return SED(
	        data = similar(sed.data, T, dims),
	        min = sed.min,
	        max = sed.max,
	        mean = sed.mean,
	        median = sed.median,
	        sigma = sed.sigma,
	        sum = sed.sum,
	        random = sed.random,
	        normalize = sed.normalize,
	        dependent = sed.dependent,
	        distribution = sed.distribution,
	        dependency_function = sed.dependency_function
	    )
	end
	
	Base.iterate(sed::SED, state...) = iterate(sed.data, state...)
	
	# -----------------------------------------------------------------------------
	# Constructor Function
	# -----------------------------------------------------------------------------
	
	"""
	    sed(; data=nothing, min=nothing, max=nothing, kwargs...) -> SED
	
	Construct a new SED instance. If `data` is provided, its element type and dimensionality
	are used; otherwise, an empty array of type `Float64` is created. Additional keyword arguments
	are passed directly to the SED constructor.
	"""
	function sed(; data = nothing, min = nothing, max = nothing, kwargs...)
	    T = Float64
	    N = 1
	    A = Array{T, N}
	    if data !== nothing
	        T = eltype(data)
	        N = ndims(data)
	        A = typeof(data)
	    else
	        data = Array{T, N}(undef, 0)
	    end
	    return SED{T, N, A}(; data, min, max, kwargs...)
	end

end


# ╔═╡ 48c10996-812c-4d41-8d23-c46dabefc6aa
md"
## Utilities

$\begin{align}
U^{OA}_i &= \overbrace{u_i y}^{\text{Resource}} \;-\; \overbrace{(\bar{u} -u_i)\,\tilde{w}_i}^{\text{Alt. incomes}}\\\\

U^{EUR}_i &= \overbrace{u_i y}^{\text{Resource}} \;-\; \overbrace{(\bar{u}-u_i)\,\tilde{w}_i}^{\text{Alt. incomes}} \;-\; \overbrace{(\text{if  }u_i - R_i>0 \text{ then: } S u_i \text{ else: }0)}^{\text{Regulation}}\\\\

U^{TUR}_i &= \overbrace{u_i y}^{\text{Resource}} \;-\; \overbrace{(\bar{u}-u_i)\,\tilde{w}_i}^{\text{Alt. incomes}} \;+\; \overbrace{(R_i - u_i)\,\phi}^{\text{Use rights market}}, \phi=\text{price of use rights}\\\\

U^{PA}_i &= \overbrace{u_i y}^{\text{Resource}} \underbrace{(1-f_p)}_{\text{Protected area}} \;-\; \overbrace{(\bar{u}^*-u_i)\,\tilde{w}_i}^{\text{Alt. incomes}} \quad \overbrace{\bar{u}^*=\tfrac{p q}{r} \frac{1}{1+\tfrac{r_{splillover}}{r}}}^{\text{Spillover effect}}\\\\

U^{EP}_i &= \overbrace{u_i y }^{\text{Resource}} \;-\; \overbrace{(\bar{u}^* -u_i)\,\tilde{w}_i^*}^{\text{Alt. incomes}} \quad \overbrace{\bar{u}^*=\tfrac{ p(EI) q(EI)}{r(EI)}, \tilde{w}_i^*=\tfrac{w(EI)}{p(EI) q(EI) K(EI)}}^{\text{Economic policy outcomes}}
\end{align}$
"

# ╔═╡ 4f97c07d-1752-455b-b935-a581d4b63b81
md"
## u̇
The dynamics of the system are given by

$\begin{align}\dot{y}& =(1-y)y-\sum_{N=1}u_i^N{}\\\dot{u_i}&=\frac{\partial U_i}{\partial u}\end{align}$ 

or for each policy:

$\begin{align}
\dot{u}^{OA}_i &= y \;-\; \tilde{w}_i\quad \text{s.t.} \quad 0<u_i<\bar{u}_i\\\\

\dot{u}^{EUR}_i &= y \;-\; \tilde{w}_i\;-\; \text{ifelse}(u_i - R_i>0,S,0)\quad \text{s.t.} \quad 0<u_i<\bar{u}_i\\\\
\dot{u}^{TUR}_i &= y \;-\; \tilde{w}_i\;+\;\phi \quad \text{s.t.} \quad 0<u_i<\bar{u}_i\\\\
\dot{u}^{PA}_i &= y (1-f_p)\;-\; \tilde{w}_i \quad \text{s.t.} \quad 0<u_i<\tfrac{p q}{r} \frac{1}{1+\tfrac{r_{splillover}}{r}}\\\\
\dot{u}^{EI}_i &=  y  \;-\; \tilde{w}_i^*\quad \text{s.t.} \quad 0<u_i<\tfrac{ p(EI) q(EI)}{r(EI)}, \tilde{w}_i^*=\tfrac{w(EI)}{p(EI) q(EI) K(EI)}
\end{align}$
"

# ╔═╡ 9dad4642-5446-4adc-a6c7-68da82ef43e6
md"
Under full compliance, resouce (R), wage (W) and trade (T) incomes are given as


$\begin{align}
R^{OA}_i  &= y u_i               &\quad W^{OA}_i  &= (\bar{u} - u_i)\tilde{w} \\\\
R^{EUR}_i &= y u_i               &\quad W^{EUR}_i &= (\bar{u} - u_i)\tilde{w} \\\\
R^{TUR}_i &= y u_i               &\quad W^{TUR}_i &= (\bar{u} - u_i)\tilde{w} &\quad T^{TUR}_i &= (R_i - u_i)\phi \\\\
R^{PA}_i  &= y u_i (1 - f_p)     &\quad W^{PA}_i &= (\bar{u}^* - u_i)\tilde{w}\\\\
R^{EI}_i  &= y u_i 			     &\quad W^{EI}_i &= (\bar{u}^* - u_i)\tilde{w}^*
\end{align}$
Remember that EI can change $\bar{u}$ distribution and thus the $u_i$ distribution thus affecting resource distributions
"

# ╔═╡ 1adea274-1046-4801-9b17-a6deb11de483


# ╔═╡ c5e52012-1a6e-4c7b-8077-2856895503bd
md"
## Governance costs?

"

# ╔═╡ 569d5054-d912-4bdb-87f1-6138d0320cf3

function incomes(x, p;  dimensional::Bool=false)
    # --- unpack state and parameters ---
    y = x[p.N+1]
    u = x[1:p.N]
    f = occursin("Protected Area", p.policy) ? p.regulation : 0.0

    # nondimensional revenues
    resource_nd = u .* y .* (1 .- f)
    
	μ = p.μ(x, p, 0.0)
    γ = γ = occursin("Protected Area", p.policy) || occursin("Protected Area", p.policy) ? p.w̃ : p.γ(x, p, 0.0)
    wages_nd = (μ .- u) .* γ
	
    trade_nd    = p.policy == "Tradable Use Rights" ? (p.R .- u) .* x[p.N+2] : zeros(p.N)
	
    total_nd    = resource_nd .+ wages_nd .+ trade_nd

    # gini and ecology always nondimensional
    g = gini(total_nd)
    ecological = y


	scale = dimensional ? p.rpk : 1.0
	resource = resource_nd .* scale
	wages    = wages_nd    .* scale
	trade    = trade_nd    .* scale
	total    = total_nd    .* scale


    return  (; resource, wages, trade, total,
            gini = g,
            ecological)
end

# ╔═╡ 898ab558-f10f-42e6-9b16-9cb2c3e845dd
md"
Protected area means that even if y becomes betteer, actors only have access to $y (1-f_p)$, thus

$\dot{u}=y (1-f_p) - \tilde{w}$

But when I calculate incentives as in the plot I use

$\gamma_i=\tilde{w} \tfrac{1}{(1-f_p)}$

Also, impact adjusted for spillover is calculated as

$\bar{u}_i^*(y) = \frac{pq}{r}\frac{1}{1 + \frac{r_{\text{spill}}(y)}{r}}.$

and is used as such in the derivative to limit $u_i$. so I need to use that to calculate the wage incomes which are 


$ū^*_i(y^*) \tilde{w}_i$

"

# ╔═╡ b76c3f9c-2ad5-497e-a341-6a8294edef24
#=╠═╡
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
  ╠═╡ =#

# ╔═╡ 3398ac1b-9530-44e6-b3a7-b93822c71e30
md"
## Exclusive Use Rights (EUR)

A fine is paid when use exceeds assigned exclusive use rigths, $R_i$, proportional to the transgression

$$I_i(u_i)=\begin{cases} S u_i & \text{if  } u_i>R_i \\ 0 & \text{otherwise} \end{cases} \quad \text{thus} \quad \frac{\partial I_i(u_i)}{\partial u_i}=\begin{cases} S & \text{if  } u_i>R_i \\ 0 & \text{otherwise} \end{cases}$$


If we assume that $S>1$ then for all users with no use rights ($R_i=0$) $\dot{u}_i=y-\tilde{w}-\tfrac{\partial I_i(u_i)}{\partial u_i} <0$ and will thus be always in full compliance, i.e. $u_i=0$, since $y<=1$

### Incomes
$$\begin{align}
\text{resource} & =y*u_i \\
\text{wages} & =w̃ (ū-uᵢ) \\
\text{sanctions} & = \max(0,R_i-u_i) S \\
\text{total} & =y*u_i + w̃ (ū-uᵢ) + \max(0,R_i-u_i) S \\
\text{governance} & = \sum{(R_i-u_i) S}-C_{\text{Institution}}
\end{align}$$

"

# ╔═╡ fb7ef10e-01fa-4a5f-9b06-d4668fea6fed
md"
## Tradable Use Rights (TUR)

Unused use rights, $\sum{R_i-u_i}$ provide the **supply**, while **demand** is $\sum{\max (0,\dot{u}_i)}$, subject to $u_i<\bar{u}_i$. Price of use rigths, $\phi$, then changes as $\dot{\phi}= k (demand-supply)$, were k sets timescale of price changes. We assume that use rights payments can be represented as continuous rents on capital (see SM for details), the Institutional utility term becomes:
$I_i(u_i)=(R_i-u_i) * \phi$, resulting in 

$$\dot{u}_i=y-\tilde{w}-\phi$$

were a social planner can set the total and distribution of use rights, $\sum{R_i}$. For example, use rights can be distributed equally (dark orange), or to those that had historical use under open access (light orange).

### Incomes
$$\begin{align}
\text{resource} & =y*u_i \\
\text{wages} & =w̃ (ū-uᵢ) \\
\text{trade} & = (Rᵢ-uᵢ)ϕ \\
\text{total} & =y*u_i + w̃ (ū-uᵢ) + (Rᵢ-uᵢ)ϕ \\
\text{governance} & = -C_{\text{fixed}}
\end{align}$$
"


# ╔═╡ 308e5df5-614e-4c7e-ab25-2a45c0fb32dc
md"
# is price of yield calculated correctly?"

# ╔═╡ ca2a18a8-5109-44e3-97eb-027d02277bad
md"
# Protected Area (PA): Spillover, Impact, and Income Explained

## 1. Two–Population Dynamics

We divide the system into an unprotected patch $x$ and a protected patch $x_p$, with areas $1 - f_p$ and $f_p$ respectively:

$
\begin{align}
\dot{x} & =\overbrace{r \left(1-\frac{x}{K}\right) x}^{\text{regeneration}} - \overbrace{h x}^{\text{harvest}}  + \overbrace{\frac{f_p}{1-f_p}m (x_p-x)}^{\text{mobility}} \\
\dot{x_p} & =\underbrace{r_p \left(1-\frac{x_p}{K_p}\right) x_p}_{\text{regeneration}} +\underbrace{\frac{1-f_p}{f_p}m (x-x_p)}_{\text{mobility}}
\end{align}
$

The terms with $m$ represent spillover between the patches.



"

# ╔═╡ d37a1931-1250-48ad-85f5-3d74004fcc4f
md"
# The issue!!

**The crux is to deal with (1-regulation) for y rather than for w̃. I think the issue is that I want (1-regulation) for the phase plot, but can't use it for the income calculations!**

I think I need to rethink the λ and γ functions!
"

# ╔═╡ de59b7d4-c55d-47af-a754-f70e699c955c


# ╔═╡ 09c6eaf8-af4a-4348-8eca-31f89b3ddada
md"
## Understanding policies

Incentives are the main driver of the system. Incomes are a central goal for any actor and we can define the non-dimensional total revenue, or utility, as 

$$\text{utility}_i=\overbrace{f y u_i}^{\text{resource}} + \overbrace{(\bar{u}_i-u_i) \tilde{w}_i}^{\text{wages}} + \overbrace{I_i(u_i)}^{\text{institutions}}$$

1) revenues calculations in dimensions or dimensionless?
2) sometimes I(u) is a price, e.g. tradable quotas. Sometimes it is sanctioing which can be monetary, but does not have to be. 
2) Sometimes we change $$\tilde{w}$$, e.g. by economic incentives which results in changed total incomes, but sometimes we only \"simulate\" the effect on  $$\tilde{w}$$, not $$\tilde{w}$$ itself, e.g. protected areas. But we simulate a change in r, not $$\tilde{w}$$
3) 

Thus incentives to NOT harvest can be many, foremost alternative livelihood opportunities and institutions, such as norms and rules. Thus the general decision problem is 

$$\dot{u}_i=y-\tilde{w}_i-\frac{\partial I_i(u_i)}{\partial u_i}$$

were 

$$\text{incentives}_i=\gamma_i=\tilde{w}_i+\frac{\partial I_i(u_i)}{\partial u_i}$$



were f is the fraction of the total area available. remember that y is scaled with K that has dimension biomass/area, or, if we have defined the system as a given area, just biomass. Note that $I_i$ can be non-monetary, e.g. social sanctioning.

To convert to dimensional revenues one simply multiplies by the \"system scaling\" factor, $r p K$ (include how we deal with cost of harvesting and can do away with it without loss of generality).

for economic incentives one generally tries to affect the distribution of the dimensional variables. these then translate into changes in e.g. $\tilde{w}$ or $\bar{u}$. This would for example lift total revneues by increasing $\tilde{w}$ or reduce participation by increasing impact, $\bar{u}$

If we assume revenues to be the goal (utility) then we can take the derivative with respect to the control variable, u, do find the optimal decision equation
"

# ╔═╡ dc784cd8-6be0-4d08-8a76-494fdb9ab239
md"
# Protected Area (PA): Spillover, Impact, and Income Explained

## 1. Two–Population Dynamics

We divide the system into an unprotected patch $x$ and a protected patch $x_p$, with areas $1 - f_p$ and $f_p$ respectively:

$
\begin{align}
\dot{x} & =\overbrace{r \left(1-\frac{x}{K}\right) x}^{\text{regeneration}} - \overbrace{h x}^{\text{harvest}}  + \overbrace{\frac{f_p}{1-f_p}m (x_p-x)}^{\text{mobility}} \\
\dot{x_p} & =\underbrace{r_p \left(1-\frac{x_p}{K_p}\right) x_p}_{\text{regeneration}} +\underbrace{\frac{1-f_p}{f_p}m (x-x_p)}_{\text{mobility}}
\end{align}
$

The terms with $m$ represent spillover between the patches.

## Effective Growth Rate

In a fast-mixing limit, the mobility terms create an effective growth rate in the unprotected area:


$$
r^*(y) = r + r_{\text{spill}}(y),
$$

where

$$
r_{\text{spill}}(y) = \frac{f_p}{1 - f_p} m \cdot \frac{y_p(y) - y}{y}.
$$

This adjustment affects the dynamics but **not** the scaling back to real units.



### Adjusted Impact Cap

The original nondimensional impact cap (a proxy for max effort) is:

$$
\bar{u}_i = \frac{q\,\bar{e}_i}{r}
$$

With spillover, the cap is reduced to:

$$
\bar{u}_i^*(y) = \frac{\bar{u}_i}{1 + \frac{r_{\text{spill}}(y)}{r}}.
$$

This captures that spillover limits how much pressure each actor can exert.


---



### 4. Wage Rate Remains Fixed

The nondimensional wage rate is:

$$
\tilde{w} = \frac{w}{p\,q\,K}
$$

This is **not** affected by spillover, because $w$, $p$, $q$, and $K$ are constant unless a policy explicitly changes them. So:

$$
\tilde{w}^* = \tilde{w}
$$

even when $f_p > 0$.

---



### 5. Nondimensional Incomes

At equilibrium, actors either fish at their cap $u_i = \bar{u}_i^*$, or not at all.

For harvesters:

$$
\begin{aligned}
\text{Resource}_i^{\text{nd}} &= (1 - f_p)\, y^*\, \bar{u}_i^* \\
\text{Wages}_i^{\text{nd}} &= 0 \\
\text{Total}_i^{\text{nd}} &= (1 - f_p)\, y^*\, \bar{u}_i^*
\end{aligned}
$$


For non-harvesters:

$$
\text{Wages}_i^{\text{nd}} = \tilde{w} \cdot \bar{u}_i^*
$$

and total income equals this wage.

---



### 6. Dimensional Incomes and the Jacobian

To recover dimensional incomes (e.g. money per time), we multiply by:

$$
r\,p\,K
$$

This scaling factor arises from the non-dimensionalization:

- $y = \frac{x}{K}$
- $u = \frac{q\,e}{r}$
- $\tau = r\,t$

So dimensional incomes are:

$$
\begin{aligned}
\text{Resource}_i^{\text{dim}} &= r\,p\,K \cdot (1 - f_p)\, y^*\, u_i \\\\
\text{Wages}_i^{\text{dim}} &= r\,p\,K \cdot (\bar{u}_i^* - u_i) \cdot \tilde{w}
\end{aligned}
$$

**Important**: We **never** replace $r$ by $r^*$ in the Jacobian. The policy effect is already captured in $y^*$ and $\bar{u}_i^*$. Using $r^*$ again would double-count the spillover effect.

---


### 7. Interpretation

- **Spillover increases $y^*$** → more resource income for those who fish.
- **Spillover decreases $\bar{u}_i^*$** → fewer wage hours for harvesters.
- **Non-harvesters** earn $\tilde{w} \cdot \bar{u}_i^*$, slightly less than in open access.

This is why, in your plots:

- The bars for non-fishers stop exactly at $\tilde{w} \cdot \bar{u}_i^*$.
- The dashed line for max wages must also reflect this policy-adjusted cap.


$$\tilde{w}\bar{u} \frac{1}{1-f_p} \frac{1}{1+\frac{r_{spillover}(y,f_p,m)}{r}}$$
"

# ╔═╡ 677a6f32-5341-4061-9507-7c468f4c0b71
md"
## Economic Incentives (EI)

A problem of economic policies is to understand how the cost or income for the policy translates into changes in socioeconomic or resource factors.

The outcomes of economic incentives level, $\rho$, on dimensional variables can be stated as, for example, $q\rightarrow q*(1+\rho)$, resulting in $\tilde{w} \rightarrow \tfrac{w}{p K q*(1+\rho)} = \tilde{w} \tfrac{1}{1+\rho}$ or for $w\rightarrow w*(1+\rho)$, resulting in $\tilde{w} \rightarrow \tfrac{w*(1+\rho)}{p K q} = \tilde{w} (1+\rho)$ 

## resource and total cost?

if we add a royalty, $p_{royalty}$ then this equates to lower price ($p^*=p-p_{royalty}$, i.e. resource revenue goes down (and thus w̃ up). simulataneously society gets $\sum p_{royalty} \cdot u_i \cdot y$

## affecting gear is more difficult.
"


# ╔═╡ f112d50b-d9ca-48ef-841f-fe0b420971ba
md"

## Development (DE)
"

# ╔═╡ d369d46f-7c93-46cd-926e-36c0a1e7ab13
# ╠═╡ disabled = true
#=╠═╡
begin
	s=scenario(high_impact(N=100), policy="Protected Area", m=0.1, regulation=0.74)

end
  ╠═╡ =#

# ╔═╡ b77bdaa8-4054-47ff-95fa-adae6f7e36bf
#=╠═╡
ss=deepcopy(s)
  ╠═╡ =#

# ╔═╡ 73bf06a1-9e0c-49da-af50-31fba13c283f
#=╠═╡
ssol=sim(ss, regulation=0.74)
  ╠═╡ =#

# ╔═╡ f5bbec84-e323-43bf-9bb4-b1baec83d413
#=╠═╡
ssol[end,:]
  ╠═╡ =#

# ╔═╡ 92eb46f7-2c3b-4242-b02e-ff5f0e9a4ff0
#=╠═╡
sol[end,:]
  ╠═╡ =#

# ╔═╡ 8c5f8c7c-e56d-4a98-9981-0fa36bd27227
#=╠═╡
s
  ╠═╡ =#

# ╔═╡ 4d7e72d7-490d-47be-8ee6-11af3dec9954
#=╠═╡
vcat(zeros(s.N),1.0)
  ╠═╡ =#

# ╔═╡ c0d3ffea-96bb-413d-bff1-7f4c03558d0e
#=╠═╡
s
  ╠═╡ =#

# ╔═╡ 4441ecc9-ef09-4402-b9c5-42073a10791d
#=╠═╡
begin
	f=Figure(size=(800,400))
	a=Axis(f[1,1])
	b=Axis(f[1,2])
	hidedecorations!(a)
	hidespines!(a)
		sol=sim(s, regulation=0.84)
	
	sol[end,:]
	phase_plot!(a,sol, impact_line_color=:crimson, incentive_line_color=:crimson)
	incomes_plot!(b,sol, color=:crimson)
	f
end
  ╠═╡ =#

# ╔═╡ 2978d2c6-257d-4ab6-86bd-cf2575be5f58


# ╔═╡ 6406c67c-0cd6-4a8f-9598-a72b0429b034
#=╠═╡
IN=incomes(sol)
  ╠═╡ =#

# ╔═╡ 03401a9b-44e4-4335-812c-91652ab3b284
#=╠═╡
s.ū
  ╠═╡ =#

# ╔═╡ b21103c0-6be8-4826-b431-25a906e6a8bf
#=╠═╡
R=regulation_scan(s)
  ╠═╡ =#

# ╔═╡ a8a5c312-5cc2-47e4-a49a-5d40a0ada055


# ╔═╡ c4c4528b-db37-43e9-bc82-90f21d1450ce
begin
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
    dx[p.N+2] = (1.0 - x[p.N+2])*dx[p.N+2] - (1.0 - p.regulation) / p.regulation * p.m * mx
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
    y_u = x[p.N+1]    # unprotected density
    y_p = x[p.N+2]    # protected   density
    # per‑capita spillover rate into the unprotected area:
    r_s_local = ((1.0-p.regulation)/p.regulation)*p.m*(y_p - y_u) / y_u
    return p.ū .* (1 .+ r_s_local).^(-1) # still need to adust μ because of spillover effect!
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
end

# ╔═╡ 53d40e4a-c217-48cc-98c2-e34cae7730f0
spa=scenario(high_impact(),policy="Protected Area", m=0.3)

# ╔═╡ e0ce0b92-0e7f-4cfe-a794-804b4b0bb014
simpa=sim(spa,regulation=0.9);

# ╔═╡ 267f2e60-ee7c-440d-8077-4868459e62e7
incpa=incomes(simpa)

# ╔═╡ 20e7c7df-fd33-4d98-a115-ac936256e07f
scatter(incpa.wages)

# ╔═╡ 58db4f43-5c68-4d7d-a88b-f4c423e9ef94
begin
	"""
Module containing visualization functions for SocialEconomicDiversity.

This includes functions for plotting incentive and impact distributions, trajectories,
phase spaces, and income distributions.
"""


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
                     show_exploitation=true, show_oa=true)
    if show_exploitation
        poly!(axis, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.0, 0.5, 0.1))
    end
    
    scenario = sol.prob.p
    N = scenario.N
    limits!(axis, 0.0, 1.0, 0.0, 1.0)

    y = range(0.0, stop=1.0, length=100)
    γ_array = scenario.γ(sol.u[end], scenario, sol.t[end])
    
    if show_oa
        oa = change(scenario, γ=γ, μ=μ, regulate=regulate, ϕ=ϕ)
        oasol = sim(oa, regulation=0.0)
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
               [u[scenario.N+1] for u in sol.u[1:end-1]], 
               [sum(u[1:scenario.N]./scenario.μ(u, scenario, sol.t[i]))/scenario.N for (i,u) in enumerate(sol.u[1:end-1])], 
               color=scenario.policy=="Development" ? sol.t[1:end-1] : :gray, 
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
    scenario.policy=="Tradable Use Rights" ? text!(axis, "ϕ: "*string(round(sol[end,end], digits=2))) : nothing
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
                       linewidth=1, color=:black, flip_arrow=false, linestyle=:dot, startarrow=false)
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
    arc!(ax, origin, radius, rad_start, rad_stop, linewidth=linewidth, color=color; linestyle=linestyle)

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
        linewidth=linewidth
    )
end

"""
    incomes_plot!(aa, sol; order=false, color=:darkorange)

Plot the distribution of incomes.
"""
function incomes_plot!(ax, sol; order=false, color=:darkorange, dimensional::Bool=false)
    p = sol.prob.p
    inc = incomes(sol.u[end-1], p; dimensional=dimensional)

    # unpack for readability
    res   = inc.resource
    wage  = inc.wages
    trd   = inc.trade
    total = inc.total

    # ordering
    idx = order ? sortperm(total) : eachindex(total)

    # bottom bars: resource + wages
    barplot!(ax, (res[idx] .+ wage[idx]), color=color, alpha=1.0, offset=trd[idx])
    # top bars: trade revenues
    barplot!(ax, trd[idx], color=color)
    barplot!(ax, trd[idx], color=HSLA(0,0,0,0.2))
    # dotted line: max nondimensional effort*price curve

   dim=dimensional ? p.rpk : 1.0
    μ = p.μ(sol.u[end], p, 0.0)
γ = p.γ(sol.u[end], p, 0.0)
line_data = μ .* γ .* dim
	line_data = wage
    lines!(ax, line_data, linewidth=2, color=:black, linestyle=:dot)

    return nothing
end
end

# ╔═╡ e68d29f4-178f-4789-9e64-5de17faf1f17
begin
	s_OA=scenario(high_impact(),policy="Protected Area",m=0.3, rpk=10.0)
	regulation=0.7
	solOA=sim(s_OA;regulation)
	r_OA=incomes(solOA)
	r_OA_dim=incomes(solOA, dimensional=true)
	f_OA=Figure()
	a_OA=Axis(f_OA[1,1])
	a_OA_dim=Axis(f_OA[1,2])
	lines!(a_OA,r_OA.resource)
	lines!(a_OA,r_OA.wages)
	
	phase_plot!(a_OA_dim,solOA)
	scatter!(a_OA_dim,[solOA.u[end][end]*(1-regulation)],[sum(solOA.u[end][1:100]./s_OA.μ(solOA.u[end],solOA.prob.p,0))/100])
	f_OA
end

# ╔═╡ 18006082-c14e-4e14-9a1b-ec2e9d46e666
sum(solOA.u[end][1:100]./s_OA.ū)

# ╔═╡ 2c1dc01a-32df-4c35-9563-20cac708fcef
begin
	    s5a=scenario(high_impact(),policy="Economic Incentives", policy_target=:μ, policy_method=:subsidy)
    s5b=scenario(high_impact(),policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
	
	regulationEI=0.7
	solEI=sim(s5b,regulation=regulationEI)
	r_EI=incomes(solEI)
	
	f_EI=Figure()
	a_EI=Axis(f_EI[1,1])
	a_EI_dim=Axis(f_EI[1,2])
	lines!(a_EI,r_EI.resource)
	lines!(a_EI,r_EI.wages)
	
	phase_plot!(a_EI_dim,solEI)

	
	f_EI
end

# ╔═╡ 5ca70131-ad82-4e1f-afad-671e7e3f359d
begin
	stur1=scenario(high_impact(),policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
	stur2=scenario(high_impact(),policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
	soltur1=sim(stur1,regulation=0.5)
	soltur2=sim(stur2,regulation=0.75)
	ftur=Figure()
	Atur1=Axis(ftur[1,1])
	Atur2=Axis(ftur[1,2])
	Atur3=Axis(ftur[2,1])
	Atur4=Axis(ftur[2,2])
	phase_plot!(Atur1,soltur1)
	phase_plot!(Atur2,soltur2)
	rtur1=regulation_scan(stur1)
	rtur2=regulation_scan(stur2)
	lines!(Atur4,rtur1.r,rtur1.TR)
	lines!(Atur4,rtur2.r,rtur2.TR)
		lines!(Atur3,rtur1.r,rtur1.RR)
	lines!(Atur3,rtur2.r,rtur2.RR)
	ftur
end

# ╔═╡ f01c9f64-579e-4400-be6c-af4578a48d30
begin
	fpa=Figure()
	apa=Axis(fpa[1,1])
	incomes_plot!(apa,simpa)
	fpa
end

# ╔═╡ Cell order:
# ╠═48c10996-812c-4d41-8d23-c46dabefc6aa
# ╟─4f97c07d-1752-455b-b935-a581d4b63b81
# ╟─9dad4642-5446-4adc-a6c7-68da82ef43e6
# ╠═1adea274-1046-4801-9b17-a6deb11de483
# ╠═c5e52012-1a6e-4c7b-8077-2856895503bd
# ╟─569d5054-d912-4bdb-87f1-6138d0320cf3
# ╟─898ab558-f10f-42e6-9b16-9cb2c3e845dd
# ╠═e68d29f4-178f-4789-9e64-5de17faf1f17
# ╠═2c1dc01a-32df-4c35-9563-20cac708fcef
# ╠═b76c3f9c-2ad5-497e-a341-6a8294edef24
# ╠═18006082-c14e-4e14-9a1b-ec2e9d46e666
# ╠═3398ac1b-9530-44e6-b3a7-b93822c71e30
# ╠═fb7ef10e-01fa-4a5f-9b06-d4668fea6fed
# ╠═308e5df5-614e-4c7e-ab25-2a45c0fb32dc
# ╠═5ca70131-ad82-4e1f-afad-671e7e3f359d
# ╟─ca2a18a8-5109-44e3-97eb-027d02277bad
# ╠═53d40e4a-c217-48cc-98c2-e34cae7730f0
# ╠═e0ce0b92-0e7f-4cfe-a794-804b4b0bb014
# ╠═d37a1931-1250-48ad-85f5-3d74004fcc4f
# ╠═de59b7d4-c55d-47af-a754-f70e699c955c
# ╠═267f2e60-ee7c-440d-8077-4868459e62e7
# ╠═20e7c7df-fd33-4d98-a115-ac936256e07f
# ╠═f01c9f64-579e-4400-be6c-af4578a48d30
# ╟─09c6eaf8-af4a-4348-8eca-31f89b3ddada
# ╠═dc784cd8-6be0-4d08-8a76-494fdb9ab239
# ╠═677a6f32-5341-4061-9507-7c468f4c0b71
# ╠═f112d50b-d9ca-48ef-841f-fe0b420971ba
# ╠═d369d46f-7c93-46cd-926e-36c0a1e7ab13
# ╠═b77bdaa8-4054-47ff-95fa-adae6f7e36bf
# ╠═73bf06a1-9e0c-49da-af50-31fba13c283f
# ╠═f5bbec84-e323-43bf-9bb4-b1baec83d413
# ╠═92eb46f7-2c3b-4242-b02e-ff5f0e9a4ff0
# ╠═8c5f8c7c-e56d-4a98-9981-0fa36bd27227
# ╠═4d7e72d7-490d-47be-8ee6-11af3dec9954
# ╠═c0d3ffea-96bb-413d-bff1-7f4c03558d0e
# ╠═4441ecc9-ef09-4402-b9c5-42073a10791d
# ╠═2978d2c6-257d-4ab6-86bd-cf2575be5f58
# ╠═6406c67c-0cd6-4a8f-9598-a72b0429b034
# ╠═03401a9b-44e4-4335-812c-91652ab3b284
# ╠═b21103c0-6be8-4826-b431-25a906e6a8bf
# ╠═58db4f43-5c68-4d7d-a88b-f4c423e9ef94
# ╠═d616345e-ada8-421e-9f62-d7811498de06
# ╠═a8a5c312-5cc2-47e4-a49a-5d40a0ada055
# ╠═c4c4528b-db37-43e9-bc82-90f21d1450ce
