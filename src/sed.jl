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
import Statistics: mean, median, std, var

# -----------------------------------------------------------------------------
# Basic Data Types
# -----------------------------------------------------------------------------

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
        println(v)
        if has_deps
            
            dist!(v, N; context=s)
        end
    end
    if !haskey(s,:w̃) && haskey(s,:w) && haskey(s,:q) && haskey(s,:ē) && haskey(s,:p) && haskey(s,:r) && haskey(s,:K)
        println("did")
        s=(s...,w̃=sed(data=s.w./(s.q.*s.p.*s.K)))#dependent=(q=1.0, w=0.5, p=1,ē=1,r=1,K=1, fun=(dep -> dep.w ./( dep.q.*dep.p.*dep.K)))))
    else
        println("missing one of w,q,ē,p,K,r")
    end

    if !haskey(s,:ū) && haskey(s,:w) && haskey(s,:q) && haskey(s,:ē) && haskey(s,:p) && haskey(s,:r) && haskey(s,:K)
        s=(s...,ū=sed(data=s.ē.*s.q./s.r))#dependent=(q=1.0, w=0.5, ē=1,  p=1,r=1,K=1, fun=(dep -> dep.ē .* dep.q ./ dep.r))))
    else
        println("missing one of w,q,ē,p,K,r")
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