using Colors, Statistics, Distributions, OrdinaryDiffEq, CairoMakie, Random, ColorSchemes
using DiffEqCallbacks: TerminateSteadyState
import Base: show
using Base: @kwdef
 
# ODE	setup	
begin 

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

end

# Γ Φ incomes and gini definitions
begin 

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


    # -- income calculation, with dimensional toggle --
    function incomes(x, p; summarize=false, dimensional::Bool=false)
        # --- unpack state and parameters ---
        y = x[p.N+1]
        u = x[1:p.N]
        f = occursin("Protected Area", p.policy) ? p.regulation : 0.0

        # nondimensional revenues
        resource_nd = u .* y .* (1 .- f)
        μ = p.μ(x, p, 0.0)
        γ = occursin("Protected Area", p.policy) || occursin("Exclusive Use Rights", p.policy) || occursin("Tradable Use Rights", p.policy) ? p.w̃ : p.γ(x, p, 0.0) #we used the scaling in the gammafunciton for PA, which works for incentives but screws up incomes....
        wages_nd = (μ .- u) .* γ
        wages_0_nd=μ .* γ
        # wages_nd    = (p.ū .- u) .* p.w̃ #occursin("Protected Area", p.policy) ? (p.μ(x,p,1.0) .- u) .* p.γ(x,p,1.0) : (p.ū .- u) .* p.w̃
        #trade_nd    = p.policy == "Tradable Use Rights" ? (p.R .- u) .* x[p.N+2] : zeros(p.N)

        if p.policy == "Tradable Use Rights"
            if p.policy_target == :yield
            trade_nd = (p.R .- (u .* y)) .* x[p.N+2]
            else   # effort-based
            trade_nd = (p.R .- u)       .* x[p.N+2]
            end
        else
            trade_nd = zeros(p.N)
        end

        total_nd    = resource_nd .+ wages_nd .+ trade_nd

        # gini and ecology always nondimensional
        g = gini(total_nd)
        ecological = y

        if dimensional
            # apply dimensional scaling factor once
            # you must have p.rpk = r * p * K stored in your scenario
            scale = p.rpk
            resource = resource_nd .* scale
            wages    = wages_nd    .* scale
            wages_0    = wages_o_nd    .* scale
            trade    = trade_nd    .* scale
            total    = total_nd    .* scale
        else
            resource, wages, trade, total, wages_0 = resource_nd, wages_nd, trade_nd, total_nd, wages_0_nd
        end

        out = (; resource, wages, trade, total,
                gini = g,
                ecological, wages_0)
        return summarize ? merge(out, (; g=g, ecological=ecological)) : out
    end

    # convenience overload for full solution
    incomes(sol::ODESolution) = incomes(sol.u[end], sol.prob.p)

    function gini(x)
        sum([abs(x[i] - x[j]) for i in 1:length(x), j in 1:length(x)]) / (2 * length(x) * sum(x))
    end

end

# SED the distributional feature
begin 
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
            if !haskey(s,:w̃) && haskey(s,:w) && haskey(s,:q) && haskey(s,:ē) && haskey(s,:p) && haskey(s,:r) && haskey(s,:K)
                s=(s...,w̃=sed(dependent=(q=1.0, w=0.5, p=1,ē=1,r=1,K=1, fun=(dep -> dep.w ./( dep.q.*dep.p.*dep.K)))))
            else
                println("missing one of w,q,ē,p,K,r")
            end

            if !haskey(s,:ū) && haskey(s,:w) && haskey(s,:q) && haskey(s,:ē) && haskey(s,:p) && haskey(s,:r) && haskey(s,:K)
                s=(s...,ū=sed(dependent=(q=1.0, w=0.5, ē=1,  p=1,r=1,K=1, fun=(dep -> dep.ē .* dep.q ./ dep.r))))
            else
                println("missing one of w,q,ē,p,K,r")
            end
		    
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

# Visualisation functions
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
        scenario.policy=="Tradable Use Rights" ? text!(axis,0.95*sol.u[end][end-1],0.95*Γ.(sol.u[end][end-1], Ref(scenario), x=sol.u[end-1]), text="ϕ: "*string(round(sol[end,end], digits=2)), align=(:right,:top), space=:relative) : nothing
        #scenario.policy=="Tradable Use Rights" ? arrows!(axis,sol.u[end][end-1]-sol.u[end][end] , Γ(sol.u[end][end-1], scenario, x=sol.u[end-1]) , 0.0, sol.u[end-1]) : nothing
    end

    function phase_plot(sol)
        f=Figure()
        a=Axis(f[1,1])
        phase_plot!(a,sol)
        f
    end

    function plot(sol)
        f=Figure()
        a=Axis(f[1,1])
        b=Axis(f[1,2])
        phase_plot!(a,sol)
        incomes_plot!(b,sol)
        f
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
            linewidth=linewidth
        )
    end

    # -- plotting, with dimensional toggle --
    function incomes_plot!(ax, sol; order=false, color=:darkorange, dimensional::Bool=false, resource_incomes=true)
        p = sol.prob.p
        inc = incomes(sol)

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
    γ =  occursin("Protected Area", p.policy) || occursin("Exclusive Use Rights", p.policy) ? p.w̃ : p.γ(sol.u[end], p, 0.0)
    line_data = μ .* γ .* dim
    line_data = inc.wages_0.*dim
        lines!(ax, line_data, linewidth=1, color=:white, linestyle=:solid)
        

        if resource_incomes
            id=findall(res[idx].>0.0)
            #=y=vcat(trd[id[1]],res[id].+trd[id],trd[reverse(id)])
            x=vcat(id[1],id,reverse(id))
            lines!(ax,x,y, color=:black)=#
            scatter!(ax,id,total[idx[id]], color=:black, markersize=3)
            #scatter!(ax,id,trd[id], color=:black, markersize=4)

        end

        return nothing
    end


    function plot_policies(w,q; order=false, goal=:oRR)
        w̃= sed(data=w./q)
        ū= sed(data=q)
        # base() provides a default setup
        # scenario(s,args) takes a scenario s, and adds or changes any params, arg.
        TUR=scenario(base();w̃,ū, policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05, title="effort")
        TUR_regscan=regulation_scan(TUR)
        sTUR=sim(TUR,regulation=TUR_regscan.r[TUR_regscan[goal]])
        # Tradable quotas needs a market_rate parameter

        TURy=scenario(base();w̃,ū, policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05, title="yield")
        TURy_regscan=regulation_scan(TURy)
        sTURy=sim(TURy,regulation=TURy_regscan.r[TURy_regscan[goal]])

        EURf=scenario(base();w̃,ū, policy="Exclusive Use Rights", reverse=false, title="low w̃ excluded")
        EURf_regscan=regulation_scan(EURf)
        sEURf=sim(EURf,regulation=EURf_regscan.r[EURf_regscan[goal]])
        # Exclusive use rigths: exclusions of low w̃  set reverse=false (one could exclude by other criteria also e.g. ū ...)

        EUR=scenario(base();w̃,ū, policy="Exclusive Use Rights", reverse=true, title="high w̃ excluded")
        EUR_regscan=regulation_scan(EUR)
        sEUR=sim(EUR,regulation=EUR_regscan.r[EUR_regscan[goal]])

        PA=scenario(base();w̃,ū, policy="Protected Area", m=0.3, title="")
        PA_regscan=regulation_scan(PA)
        
        sPA=sim(PA,regulation=PA_regscan.r[PA_regscan[goal]])
        f=Figure(size=(800,800))
        OA=scenario(base();w̃,ū,title="")
        sols=vcat(sim(OA),sEUR,sTUR,sPA,sEURf,sTURy)
        function incometext(sol)
            income=incomes(sol)
            "R:"*string(round(sum(income.resource),digits=2))*"  T:"*string(round(sum(income.total),digits=2))*"  G:"*string(round(income.gini,digits=2))*" @"*string(round(haskey(sol.prob.p,:regulation) ? sol.prob.p.regulation : 0.0,digits=2))
        end
    B=[]
        for i in 1:length(sols)
        
            j=  i>3 ?   2 : 0
            k= i> 3 ? 3 : 0
            
            a=Axis(f[1+i-k,1+j], title=sols[i].prob.p.policy*"\n"*sols[i].prob.p.title)
            b=Axis(f[1+i-k,2+j])
            push!(B,b)
            hidespines!(a)
            hidespines!(b)
            hidedecorations!(a)
            hidedecorations!(b)
            phase_plot!(a,sols[i])
            if sols[i].prob.p.policy=="Exclusive Use Rights"
                id=findall(sols[i].prob.p.R.==1.0)
                y=range(0.0,stop=1.0,length=sols[i].prob.p.N)
                z=Γ.(sols[i].prob.p.w̃[id], Ref(sols[i].prob.p))
            
                lines!(a,sols[i].prob.p.w̃[id],max.(0.005,z), color=:red, linewidth=2, label=sols[i].prob.p.title)
                #axislegend(a)
            elseif sols[i].prob.p.policy=="Tradable Use Rights"

            end
            incomes_plot!(b,sols[i]; order)
            text!(b,0.0,0.9,text=incometext(sols[i]), space=:relative, fontsize=12)
        end
        C=Axis(f[1,1])
        scatter!(C,w, label="w")
        scatter!(C,q, label="q")
        axislegend(C, framevisible=false)
        D=Axis(f[1,2], xlabel="w̃", ylabel="ū ")
        scatter!(D,OA.w̃,OA.ū)
        E=Axis(f[1,3])
        incomes_plot!(E,sim(OA))
        F=Axis(f[1,4])
        incomes_plot!(F,sim(OA), order=true)
        [hidespines!(a) for a in [C,D,E,F]]
        linkaxes!(B...)
        f
    end
incomes

    function regscan(; u=false,inc=false,s=high_impact())
        
        policies=[
        scenario(s,policy="Exclusive Use Rights", reverse=true)
        scenario(s,policy="Exclusive Use Rights", reverse=false)
        scenario(s,policy="Tradable Use Rights", policy_target=:effort, market_rate=0.05)
        scenario(s,policy="Tradable Use Rights", policy_target=:yield, market_rate=0.05)
        scenario(s,policy="Protected Area", m=0.3)
        scenario(s,policy="Protected Area", m=0.5)
        #scenario(s,policy="Economic Incentives", policy_target=:γ, policy_method=:taxation)
        ]
        Labels=Dict(
            :RR=>"Resource\nRevenues\nR",
            :ToR=>"Total\nRevenues\nT",
            :GI=>"Gini\nG ",
            :EH=>"Ecological\nStatus\nE",
            :RI=>"Impact\non\nbehaviour\nsum(|u^UO_i-u_i|)",
            :Gov=>"Combined\nGovernance\ngoal\nR^0.5*T^1*G^-0.2*E^0",
            :WR=>"Alternative\nincomes"
        )
        policylabels=[
            "Use Rights\nHIGH w̃\nexcluded",
            "Use Rights\nLOW w̃\nexcluded",
            "Tradable \nUse Rights\nEFFORT",
            "Tradable \nUse Rights\nYIELD",
            "Protected Area\n\nmobility=0.3",
            "Protected Area\n\nmobility=0.5",
            "Economic incentive\n\nRoyalties"
        ]
        policyxlabels=[
            "fraction excluded",
            "fraction excluded",
            "1 - effort quota",
            "1 - yield quota",
            "fraction protected",
            "fraction protected",
            "econ policy"
        ]
        RS=[regulation_scan(scenario,kR=0.5, kT=1.0,kG=-0.2,kE=0.0) for scenario in policies]
        f=Figure(size=(1000,1000))
    
        outcomes=[:RR,:ToR,:GI,:EH,:RI,:Gov]
        #Label(f[0,1:length(RS)], text="Policy outcomes", fontsize=25, font=:bold)
        A=Dict()
        B=Dict()
        C=Dict()
        LL=0 
        for (i,rs) in enumerate(RS)
            for (jj,o) in enumerate(outcomes)
                j=jj+1
                if i==1
                    Label(f[j,0], text=Labels[o], tellheight=false)
                end
                
                osym=Symbol("o"*string(o))
                xv= round(rs.r[rs[osym]], digits=2)
                xtv=[0,xv,1]
                xts=["0",string(xv),"1"]
                yv= round(rs[o][rs[osym]], digits=2)
                ytv=[0,yv,1]
                yts=["",string(yv),""]
                if xtv[1]==xtv[2]
                    xtv=xtv[2:3]; xts=xts[2:3]
                elseif xtv[2]==xtv[3]
                    xtv=xtv[1:2]; xts=xts[1:2]
                end
                if ytv[1]==ytv[2]
                    ytv=ytv[2:3]; yts=yts[2:3]
                elseif ytv[2]==ytv[3]
                    ytv=ytv[1:2]; yts=yts[1:2]
                end
                xtv=[xv]
                xts=[string(xv)]
                ytv=[yv]
                yts=[string(yv)]

                A[i,j]=Axis(f[j,i], 
                xticks =(xtv,xts),
                xticklabelsize=12,
                xticklabelcolor=ColorSchemes.tab20[i],
                yticks =(ytv,yts),
                yticklabelsize=12,
                yticklabelrotation=pi/2,
                yticklabelcolor=ColorSchemes.tab20[i],
                xgridcolor=ColorSchemes.tab20[i],
                ygridcolor=ColorSchemes.tab20[i],
                backgroundcolor="#f1f1f1",
                yaxisposition=:right,
                xaxisposition=:top)
                hidespines!(A[i,j])

                if i==1 || jj==length(outcomes)
                    B[i,j]=Axis(f[j,i],
                    xlabel=policyxlabels[i],
                    yaxisposition=:left,
                    xaxisposition=:bottom,
                    backgroundcolor="#f1f1f1",
                    yticklabelsize=12,
                    xticklabelsize=12,
                    xgridvisible=false,
                    ygridvisible=false,
                    xticklabelsvisible= jj==length(outcomes),
                    xlabelvisible= jj==length(outcomes),
                    yticklabelsvisible= i==1)
                    lines!(B[i,j],rs.r,rs[o], color=:transparent, linewidth=0)
                    hidespines!(B[i,j])
                    if o==:RR 
                        B[i,j].yticks=[0.0,0.1,0.2,0.25]
                    end
                    #jj==length(outcomes) ? hidexdecorations!(B[i,j], ticklabels=false) : hidexdecorations!(B[i,j])
                    #jj==length(outcomes)  ?   hideydecorations!(B[i,j],ticklabels=false ) : nothing
                end

                
                #j==length(outcomes) ? hidexdecorations!(A[i,j], label=false, ticklabels=false, grid=true) : hidexdecorations!(A[i,j])
                #i==1 ? hideydecorations!(A[i,j], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,j], grid=false)
                #hidespines!(A[i,j])
                lines!(A[i,j],rs.r,rs[o], color=ColorSchemes.tab20[i], linewidth=3)
                
                
                #vlines!(A[i,j], rs.r[rs[osym]],color=:black, linestyle=:dot)
                
                #text!(A[i,j],0.05,0.95,text=string(round(rs[o][rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:left,:top))
                
                #text!(A[i,j],rs.r[rs[osym]]-0.05,0.05,text=string(round(rs.r[rs[osym]], digits=2)), space=:relative, fontsize=12, color=:black, align=(:right,:bottom))

            end
            #length(outcomes)
            if u
                A[i,LL+1]=Axis(f[LL+1,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "") 
                heatmap!(A[i,LL+1],rs.sols, colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
                hidexdecorations!( A[i,LL+1])
                hidespines!( A[i,LL+1])
                i==1 ? hideydecorations!(A[i,LL+1], label=false, ticklabels=true, minorgrid=false) : hideydecorations!(A[i,LL+1], minorgrid=false, ticklabels=true)
                #hidespines!( A[i,LL+1])
                Label(f[1,0], text="Participation in\nresource use " , tellheight=false)

                #=[i,LL+2]=Axis(f[LL+2,i],  ylabel=i==1 ? "Actors w̃\nlow → high" : "")
                heatmap!(A[i,LL+2],log10.(rs.incdist), colormap=cgrad(["#f1f1f1",ColorSchemes.tab20[i]]))
                hidexdecorations!( A[i,LL+2])
                i==1 ? hideydecorations!(A[i,LL+2], label=false, ticklabels=true, grid=false) : hideydecorations!(A[i,LL+2], grid=false, ticklabels=true)
                #hidespines!( A[i,LL+2])
                Label(f[2,0], text="Incomes\n of actors" , tellheight=false)=#
            end
            if inc
                A[i,length(outcomes)+LL+2]=Axis(f[length(outcomes)+LL+2,i]) 
                incomes_plot!(A[i,length(outcomes)+LL+2],sim(policies[i], regulation=RS[i].r[RS[i].oGov]))
                hidedecorations!(A[i,length(outcomes)+LL+2])
            end
            policylabels[i]
            Label(f[0,i], text=policylabels[i],color=ColorSchemes.tab20[i], tellwidth=false)
        end
        #Label(f[length(outcomes)+LL+2,1:length(RS)], text="Regulation level", tellwidth=false, fontsize=25, font=:bold)
        sa=Axis(f[0,0], aspect=1)
        hidedecorations!(sa)
        hidespines!(sa)
        phase_plot!(sa,sim(s), incentive_line_color=:gray, impact_line_color=:gray)
        #Label(f[0,0], text="Outcomes", tellwidth=false, fontsize=25, font=:bold)

            [linkyaxes!([A[i,j+LL+1] for i in 1:length(RS)]...,B[1,j+1]) for j in 1:length(outcomes)]

        f
    end
end

# policy instruments definitions
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
        return change(scenario, R=R, regulation=f) # return use rights
    end

    # ===== Tradable Use Rights =====

    """
        regulate_tradable_use_rights(s, f)

    Regulation function for Tradable Use Rights. 
    Allocates tradable use rights to users.
    """
    function regulate_tradable_use_rights_new(s, f)
        R=fill(f==0 ? 1.0 : (1-Float64(f))/s.N, s.N)
    
            u0 = zeros(s.N); y0 = 1.0; ϕ0 = 0.0
            oaprob = ODEProblem(dxdt, [u0; y0; ϕ0], (0, 1000), s)
            oasol = solve(oaprob, SSPRK432(; stage_limiter!), callback=TerminateSteadyState(1e-6, 1e-4))
            hur = haskey(s, :historical_use_rights) ? oasol[1:s.N, end-1] .> 0.0 : 1:s.N
            if s.policy_target == :yield
                # historical effort levels at steady state
                hist_u = oasol[1:s.N, end-1]
                hist_y = oasol[s.N+1, end-1]
                hist_yield = hist_u .* hist_y
            
                # now allocate the *yield* quotas so they sum to (1 - f) * total_yield
                total_hist_yield = sum(hist_yield)
                R = hist_yield .* (1 - f) ./ total_hist_yield
            
            else
                # your existing effort‐share logic
                R = hur .* (1 - f) ./ sum(hur)
            end

        #R = haskey(s, :historical_use_rights) ? hur .* (1-Float64(f)) ./ sum(hur) : fill(f==0 ? 1.0 : (1-Float64(f))/s.N, s.N)

        q = change(s, R=R, regulation=f)
        
        return q
    end

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
    function ϕ_tradable_use_rights_new(dx, x, p, t)
        # we calculate the sum of all unused Use Rights and assume they are for sale
        # if the market is for quota (yield) then effort is yield/resource_density
        if p.policy_target == :yield
            supply = sum( clamp.( p.R .- (x[1:p.N] .* x[p.N+1]), 0.0, Inf ) )
        elseif p.policy_target == :effort
            supply = sum(clamp.( p.R .- x[1:p.N],0.0,Inf ))
        else
            println("please supply policy_target (:yield or :effort")
        end

        # To calculate demand we need to find all who want to increase their effort
        id = findall((dx[1:p.N] .> 0.0))

        # Calculate individual demand for increased usage, but assure they do not demand more than their physical limit, ū	    
        if p.policy_target == :yield
            max_extra_yield = (p.ū[id] .- x[id]) .* x[p.N+1]

            # desire to increase yield = Δu * y
            desired_extra_yield = dx[id] .* x[p.N+1]      

            ind_demand = min.(max_extra_yield, desired_extra_yield)
        else
            ind_demand = min.(p.ū[id] - x[id], dx[id])
        end
        demand = sum(ind_demand)

        # Update the tradable quota price based on the difference between demand and supply
        dx[p.N+2] = p.market_rate * (demand - supply)

        # adjust rate of change of increase in effort to account for limited supply. The condition assures that we never divide by zero demand.
        if demand > supply
            dx[id] .= supply .* ind_demand ./ demand
        end
    end

    function ϕ_tradable_use_rights(dx, x, p, t)
        # we calculate the sum of all unused Use Rights and assume they are for sale
        # if the market is for quota (yield) then effort is yield/resource_density
        if p.policy_target == :yield
            supply = clamp(sum(p.R .- x[1:p.N] * x[p.N+1]),0.0,Inf) 
        elseif p.policy_target == :effort
            supply = max.(0.0, sum(p.R .- x[1:p.N]))
        else
            println("please supply policy target (:yield / :effort")
        end

        # To calculate demand we need to find all who want to increase their effort
        id = findall((dx[1:p.N] .> 0.0))

        # Calculate individual demand for increased usage, but assure they do not demand more than their physical limit, ū	    
        if p.policy_target == :yield
            ind_demand = min.((p.ū[id] - x[id])*x[p.N+1], dx[id]*x[p.N+1])
        else
            ind_demand = min.(p.ū[id] - x[id], dx[id])
        end
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
        temp = (; p..., policy="Open Access",γ=γ,ϕ=ϕ,μ=μ,regulate=regulate, kwargs...)
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
        w̃=sed(min=0.1, max=1.0, distribution=LogNormal, random=random), 
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


    function regulation_scan(p; m=100, kR=0.5, kT=1.0, kG=-0.2, kE=0.0, kI=0.0)
        r = range(0.0, stop=1.0-1.0/m, length=m)
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
            Gov[j] = sum(inc.resource.^kR.+ inc.total.^kT.+ inc.gini.^kG.+inc.ecological.^kE.+ regimpact.^kI)
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
        oGov = argmax(Gov)

        return (; RR, WR, TR, ToR, GI, EH, RI, Gov=Gov./100.0, r, oRR, oWR, oTR, oToR, oGI, oEH, oRI,oGov, sols, incdist)
    end

end
