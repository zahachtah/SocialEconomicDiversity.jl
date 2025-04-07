# =============================================================================
# SocialEconomicDiversity.jl - Next Generation SED Implementation
#
# A reimagined implementation of the Socio-Economic Distribution (SED) system
# with cleaner abstractions, simplified API, and more intuitive dependency handling.
# =============================================================================

using Statistics
using Distributions

# -----------------------------------------------------------------------------
# Distribution Types & Traits System
# -----------------------------------------------------------------------------

"""
Abstract type for all distribution specifications.
"""
abstract type DistributionSpec end

"""
Base trait system for different distribution specifications.
"""
abstract type DistributionTrait end
struct LogNormalDist <: DistributionTrait end
struct UniformDist <: DistributionTrait end
struct DiracDist <: DistributionTrait end
struct BernoulliDist <: DistributionTrait end

# Define trait dispatch for distribution types
distribution_trait(::Type{LogNormal}) = LogNormalDist()
distribution_trait(::Type{Uniform}) = UniformDist()
distribution_trait(::Type{Dirac}) = DiracDist()
distribution_trait(::Type{Bernoulli}) = BernoulliDist()
distribution_trait(d::Distribution) = distribution_trait(typeof(d))

"""
    MinMaxSpec(distribution_type, min, max)

A distribution specification with min/max parameters.
"""
struct MinMaxSpec <: DistributionSpec
    distribution_type::Type{<:Distribution}
    min::Float64
    max::Float64
end

"""
    MeanSigmaSpec(distribution_type, mean, sigma)

A distribution specification with mean/sigma parameters.
"""
struct MeanSigmaSpec <: DistributionSpec
    distribution_type::Type{<:Distribution}
    mean::Float64
    sigma::Float64
end

"""
    MedianSigmaSpec(distribution_type, median, sigma)

A distribution specification with median/sigma parameters.
"""
struct MedianSigmaSpec <: DistributionSpec
    distribution_type::Type{<:Distribution}
    median::Float64
    sigma::Float64
end

"""
    SingleValueSpec(distribution_type, value)

A distribution specification for constant/single-value distributions.
"""
struct SingleValueSpec <: DistributionSpec
    distribution_type::Type{<:Distribution}
    value::Float64
end

"""
    ProbabilitySpec(distribution_type, probability)

A distribution specification for distributions defined by a probability.
"""
struct ProbabilitySpec <: DistributionSpec
    distribution_type::Type{<:Distribution}
    probability::Float64
end

"""
    DirectSpec(distribution)

A direct distribution specification with a ready-made distribution.
"""
struct DirectSpec <: DistributionSpec
    distribution::Distribution
end

# -----------------------------------------------------------------------------
# Dependency Specification
# -----------------------------------------------------------------------------

"""
    DependencySpec

A specification for dependencies between variables.
"""
struct DependencySpec
    # Map of variable names to scaling factors
    factors::Dict{Symbol, Union{Float64, Function}}
    # Optional custom function to compute the final dependency
    custom_function::Union{Nothing, Function}
    # Function for combining independent and dependent contributions
    combination_function::Function
end

"""
    DependencySpec(; kwargs...)

Create a dependency specification from keyword arguments.
"""
function DependencySpec(; fun=nothing, combine=(indep, dep) -> indep .+ dep, kwargs...)
    factors = Dict{Symbol, Union{Float64, Function}}()
    for (k, v) in kwargs
        factors[k] = v
    end
    return DependencySpec(factors, fun, combine)
end

# -----------------------------------------------------------------------------
# Core SED Type
# -----------------------------------------------------------------------------

"""
    SED{T}

A socio-economic distribution that can represent various economic parameters
with support for different distribution types and dependencies.

# Fields
- `data`: The actual distribution data
- `spec`: Specification for how to generate the distribution
- `dependency`: Optional dependency specification
- `random`: Whether to use random sampling (true) or deterministic quantiles (false)
- `normalize`: Whether to normalize the generated data to sum to 1
- `reverse`: Whether to reverse the order of generated values
"""
mutable struct SED{T<:AbstractFloat}
    data::Vector{T}
    spec::DistributionSpec
    dependency::Union{Nothing, DependencySpec}
    random::Bool
    normalize::Bool
    reverse::Bool
    
    # Inner constructor with empty data
    function SED{T}(
        spec::DistributionSpec;
        dependency=nothing,
        random=false,
        normalize=false,
        reverse=false
    ) where T<:AbstractFloat
        return new{T}(T[], spec, dependency, random, normalize, reverse)
    end
end

# Outer constructor with type parameter defaulting to Float64
function SED(
    spec::DistributionSpec;
    dependency=nothing,
    random=false,
    normalize=false,
    reverse=false
)
    return SED{Float64}(spec; dependency, random, normalize, reverse)
end

# -----------------------------------------------------------------------------
# Constructor Functions
# -----------------------------------------------------------------------------

"""
    sed(; distribution, kwargs...)

Create a new SED instance with specified parameters.

# Examples
```julia
# Min/max specification for LogNormal
s1 = sed(distribution=LogNormal, min=0.5, max=2.0)

# Mean/sigma specification for Uniform
s2 = sed(distribution=Uniform, mean=1.0, sigma=0.5)

# Median/sigma specification for LogNormal
s3 = sed(distribution=LogNormal, median=1.0, sigma=0.3)

# Constant value
s4 = sed(distribution=Dirac, value=1.0)

# With dependency
s5 = sed(
    distribution=LogNormal, 
    median=0.5, 
    sigma=0.2,
    dependent=(x=0.5, y=1.0, fun=(d -> d.x * d.y))
)
```
"""
function sed(;
    distribution::Union{Type{<:Distribution}, Distribution}=Uniform,
    min=nothing,
    max=nothing,
    mean=nothing,
    median=nothing,
    sigma=nothing,
    value=nothing,
    probability=nothing,
    random=false,
    normalize=false,
    reverse=false,
    dependent=nothing
)
    # Create the appropriate distribution specification
    if distribution isa Distribution
        spec = DirectSpec(distribution)
    elseif value !== nothing
        spec = SingleValueSpec(distribution, value)
    elseif min !== nothing && max !== nothing
        spec = MinMaxSpec(distribution, min, max)
    elseif mean !== nothing && sigma !== nothing
        spec = MeanSigmaSpec(distribution, mean, sigma)
    elseif median !== nothing && sigma !== nothing
        spec = MedianSigmaSpec(distribution, median, sigma)
    elseif probability !== nothing && distribution == Bernoulli
        spec = ProbabilitySpec(distribution, probability)
    else
        error("Invalid parameter combination for distribution specification")
    end
    
    # Create dependency specification if needed
    dependency_spec = if dependent !== nothing
        if dependent isa NamedTuple
            # Extract custom function if present
            fun = haskey(dependent, :fun) ? dependent.fun : nothing
            # Extract combination function if present
            combine = haskey(dependent, :combine) ? dependent.combine : (indep, dep) -> indep .+ dep
            # Build factors dict from remaining fields
            factors = Dict{Symbol, Union{Float64, Function}}()
            for (k, v) in pairs(dependent)
                if k != :fun && k != :combine
                    factors[k] = v
                end
            end
            DependencySpec(factors, fun, combine)
        else
            error("dependent must be a NamedTuple")
        end
    else
        nothing
    end
    
    return SED(spec; dependency=dependency_spec, random, normalize, reverse)
end

# -----------------------------------------------------------------------------
# Distribution Generation
# -----------------------------------------------------------------------------

"""
    create_distribution(spec::DistributionSpec)

Create a distribution from a specification.
"""
function create_distribution(spec::DirectSpec)
    return spec.distribution
end

function create_distribution(spec::SingleValueSpec)
    return Dirac(spec.value)
end

function create_distribution(spec::ProbabilitySpec)
    @assert spec.distribution == Bernoulli "ProbabilitySpec only works with Bernoulli"
    return Bernoulli(spec.probability)
end

# Create LogNormal distribution from min/max
function create_distribution(spec::MinMaxSpec, n::Int, trait::LogNormalDist)
    if spec.min ≈ spec.max
        return Dirac(spec.min)
    end
    
    # Create a LogNormal distribution that spans the min/max range
    min_val, max_val = minmax(spec.min, spec.max)
    
    # Generate logarithmically spaced points and find parameters
    if n > 1
        # Create log-spaced points and estimate distribution parameters
        points = exp.(range(log(min_val), stop=log(max_val), length=n))
        μ = log(median(points))
        σ = std(log.(points))
        return LogNormal(μ, σ)
    else
        # Single point case
        return Dirac((min_val + max_val) / 2)
    end
end

# Create Uniform distribution from min/max
function create_distribution(spec::MinMaxSpec, ::Int, trait::UniformDist)
    if spec.min ≈ spec.max
        return Dirac(spec.min)
    end
    min_val, max_val = minmax(spec.min, spec.max)
    return Uniform(min_val, max_val)
end

# Create LogNormal distribution from mean/sigma
function create_distribution(spec::MeanSigmaSpec, ::Int, trait::LogNormalDist)
    if spec.sigma ≈ 0.0
        return Dirac(spec.mean)
    end
    # Convert mean/sigma to LogNormal parameters
    σ = abs(spec.sigma)
    μ = log(spec.mean) - σ^2/2
    return LogNormal(μ, σ)
end

# Create Uniform distribution from mean/sigma
function create_distribution(spec::MeanSigmaSpec, ::Int, trait::UniformDist)
    if spec.sigma ≈ 0.0
        return Dirac(spec.mean)
    end
    σ = abs(spec.sigma)
    # For Uniform, sigma = (b-a)/sqrt(12), so half-width = sigma*sqrt(3)
    half_width = σ * sqrt(3)
    return Uniform(spec.mean - half_width, spec.mean + half_width)
end

# Create LogNormal distribution from median/sigma
function create_distribution(spec::MedianSigmaSpec, ::Int, trait::LogNormalDist)
    if spec.sigma ≈ 0.0
        return Dirac(spec.median)
    end
    # For LogNormal, the median is exp(μ), so μ = log(median)
    return LogNormal(log(spec.median), abs(spec.sigma))
end

# Create Uniform distribution from median/sigma
function create_distribution(spec::MedianSigmaSpec, ::Int, trait::UniformDist)
    # For uniform, median = mean
    return create_distribution(MeanSigmaSpec(spec.distribution_type, spec.median, spec.sigma), 0, trait)
end

# Default handler for unsupported combinations
function create_distribution(spec::DistributionSpec, ::Int, trait::DistributionTrait)
    error("Unsupported combination: $(typeof(spec)) with $(typeof(trait))")
end

# -----------------------------------------------------------------------------
# Sampling Functions
# -----------------------------------------------------------------------------

"""
    sample_distribution(dist::Distribution, n::Int, random::Bool, reverse::Bool)

Sample n points from a distribution.
"""
function sample_distribution(dist::Distribution, n::Int, random::Bool, reverse::Bool)
    if random
        return rand(dist, n)
    else
        if n == 1
            return [quantile(dist, 0.5)]
        else
            qs = range(1/n, stop=1-1/n, length=n)
            result = quantile.(Ref(dist), qs)
            return reverse ? reverse(result) : result
        end
    end
end

# -----------------------------------------------------------------------------
# Dependency Resolution
# -----------------------------------------------------------------------------

"""
    resolve_dependency(sed::SED, context::NamedTuple)

Resolve dependencies for a SED using the provided context.
"""
function resolve_dependency(sed::SED, context::NamedTuple)
    isnothing(sed.dependency) && return sed.data
    
    dep_spec = sed.dependency
    n = length(sed.data)
    
    # Get all dependency values from context
    dep_values = Dict{Symbol, Vector{Float64}}()
    for (name, factor) in dep_spec.factors
        if !haskey(context, name)
            error("Dependency '$name' not found in context")
        end
        
        var = context[name]
        # Extract data from the dependency
        if var isa SED
            if isempty(var.data)
                error("Dependency '$name' has no data. Generate its distribution first.")
            end
            dep_values[name] = var.data
        elseif var isa AbstractVector
            dep_values[name] = convert(Vector{Float64}, var)
        else
            dep_values[name] = fill(convert(Float64, var), n)
        end
        
        # Scale by the factor
        if factor isa Function
            dep_values[name] = factor.(dep_values[name])
        else
            dep_values[name] .*= factor
        end
    end
    
    # Compute final dependency contribution
    if dep_spec.custom_function !== nothing
        # Use custom function
        dep_tuple = (; (k => v for (k, v) in dep_values)...)
        dep_contribution = dep_spec.custom_function(dep_tuple)
    else
        # Sum scaled dependencies
        dep_contribution = zeros(n)
        for (_, values) in dep_values
            dep_contribution .+= values
        end
    end
    
    # Combine with independent data
    return dep_spec.combination_function(sed.data, dep_contribution)
end

# -----------------------------------------------------------------------------
# Main Distribution Generation Function
# -----------------------------------------------------------------------------

"""
    dist!(sed::SED, n::Int; context=nothing)

Generate a distribution for a SED with n points.

# Examples
```julia
# Generate 100 points
dist!(my_sed, 100)

# Generate with dependencies
dist!(my_sed, 100, context=my_context)
```
"""
function dist!(sed::SED, n::Int; context=nothing)
    # Create appropriate distribution from spec
    if sed.spec isa DirectSpec || sed.spec isa SingleValueSpec || sed.spec isa ProbabilitySpec
        dist = create_distribution(sed.spec)
    else
        # Pass length for min/max specs that need it
        trait = distribution_trait(sed.spec.distribution_type)
        dist = create_distribution(sed.spec, n, trait)
    end
    
    # Sample from the distribution
    sed.data = sample_distribution(dist, n, sed.random, sed.reverse)
    
    # Apply dependencies if context is provided
    if context !== nothing && sed.dependency !== nothing
        sed.data = resolve_dependency(sed, context)
    end
    
    # Normalize if requested
    if sed.normalize && !isempty(sed.data)
        sed.data ./= sum(sed.data)
    end
    
    return sed
end

"""
    dist!(context::NamedTuple, n::Int)

Generate distributions for all SEDs in a context.
"""
function dist!(context::NamedTuple, n::Int)
    # Identify all SED parameters
    sed_params = []
    for (k, v) in pairs(context)
        if v isa SED
            has_deps = v.dependency !== nothing
            push!(sed_params, (k, v, has_deps))
        end
    end
    
    # First process independent SEDs
    for (_, v, has_deps) in sed_params
        if !has_deps
            dist!(v, n)
        end
    end
    
    # Then process dependent SEDs
    for (_, v, has_deps) in sed_params
        if has_deps
            dist!(v, n, context=context)
        end
    end
    
    return context
end

"""
    dist!(context, param_name::Symbol)

Generate distribution for a specific parameter in a context.
"""
function dist!(context, param_name::Symbol)
    n = context.N  # Get length from context
    
    # Handle special symbol cases like w̃/w and ū/u
    param_names = [param_name]
    if param_name == :w
        push!(param_names, :w̃)
    elseif param_name == :u
        push!(param_names, :ū)
    end
    
    # Look for the parameter in the context
    for name in param_names
        for (k, v) in pairs(context)
            if k == name && v isa SED
                return dist!(v, n, context=context)
            end
        end
    end
    
    error("Parameter '$param_name' not found in context")
end

# -----------------------------------------------------------------------------
# Array Interface
# -----------------------------------------------------------------------------

# Make SED behave like an array
Base.getindex(sed::SED, i...) = getindex(sed.data, i...)
Base.setindex!(sed::SED, v, i...) = setindex!(sed.data, v, i...)
Base.length(sed::SED) = length(sed.data)
Base.size(sed::SED) = size(sed.data)
Base.iterate(sed::SED, state...) = iterate(sed.data, state...)

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

"""
    merge_contexts(a::NamedTuple, b::NamedTuple)

Merge two context NamedTuples, with values from b taking precedence.
"""
function merge_contexts(a::NamedTuple, b::NamedTuple)
    return (; a..., b...)
end

# -----------------------------------------------------------------------------
# Display Functions
# -----------------------------------------------------------------------------

function Base.show(io::IO, sed::SED)
    if isempty(sed.data)
        print(io, "SED($(typeof(sed.spec)), no data)")
    else
        print(io, "SED(n=$(length(sed.data)), μ=$(round(mean(sed.data), digits=3)), σ=$(round(std(sed.data), digits=3)))")
    end
end

function Base.summary(io::IO, sed::SED)
    print(io, "SED with $(length(sed.data)) values")
end