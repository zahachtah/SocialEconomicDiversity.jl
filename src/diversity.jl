# Define a constant for the Dirac distribution
Constant=Dirac

# Define custom distribution types
struct Derived <: ContinuousUnivariateDistribution
    data::Vector{Float64}
end

struct Data <: ContinuousUnivariateDistribution
    data::Vector{Float64}
end

# Overload statistical functions for custom types
import Statistics: mean, median, std, var

function mean(d::Union{Derived, Data})
    return mean(d.data)
end

function median(d::Union{Derived, Data})
    return median(d.data)
end

function std(d::Union{Derived, Data})
    return std(d.data)
end

function var(d::Union{Derived, Data})
    return var(d.data)
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

# Example
```julia
sed = SED(min=0.1, max=1.0, distribution=Uniform)
dist!(sed, 100)
This creates an SED instance with a uniform distribution between 0.1 and 1.0, and then generates 100 data points following this distribution.
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

# Define pretty-printing functions

function show(io::IO, sed::SED{T, N, A}) where {T, N, A<:AbstractArray{T,N}}
    for (field, value) in zip(fieldnames(SED), getfield.(Ref(sed), fieldnames(SED)))
        if value !== nothing
            print(io, "$field: $value ")
        end
    end
end

function astext(sed::SED{T, N, A}) where {T, N, A<:AbstractArray{T,N}}
    io = IOBuffer()
    show(io, sed)
    str = String(take!(io))
    str = replace(str, "Distributions." => "")
    str = replace(str, "{Float64}" => "")
    return str
end

# Distribution functions
"""
    dist!(s::SED, N::Int)

Generate or update the data in the `SED` instance `s` based on the specified distribution parameters and the number of data points `N`.

# Arguments
- `s::SED`: An instance of `SED` representing the distribution.
- `N::Int`: The number of data points to generate.

# Description
This function updates the `data` field of the `SED` instance `s` based on its specified distribution parameters. The function handles different distribution types (`LogNormal`, `Uniform`, `Constant`, etc.) and generates data points accordingly. If `random` is set to `true`, data points are randomly sampled from the distribution. Otherwise, they are deterministically generated based on quantiles. The function also handles normalization if `normalize` is set to `true`.

# Example
```julia
sed = SED(min=0.1, max=1.0, distribution=Uniform)
dist!(sed, 100)
"""
function dist!(s::SED, N::Int)
    rev = false
    if s.min !== nothing && s.max !== nothing
        rev = s.min > s.max
        if s.max != s.min && N > 1
            temp = lognormal(minimum([s.min, s.max]), stop=maximum([s.min, s.max]), length=N)
            medianLN = median(temp)
            spreadLN = std(log.(temp))
            s.distribution = LogNormal(log(medianLN), spreadLN)
        else
            s.distribution = Dirac(N == 1 ? middle(s.min, s.max) : s.min)
        end
    elseif s.mean !== nothing && s.sigma !== nothing
        rev = s.sigma < 0
        s.distribution = s.sigma != 0.0 ? LogNormal(log(s.mean) - abs(s.sigma)^2 / 2, abs(s.sigma)) : Dirac(s.mean)
    elseif s.median !== nothing && s.sigma !== nothing
        rev = s.sigma < 0
        s.distribution = s.sigma != 0.0 ? LogNormal(log(s.median), abs(s.sigma)) : Dirac(s.median)
    end

    if s.random
        s.data = rand(s.distribution, N)
    else
        s.data = quantile.(s.distribution, range(1 / N, stop=1 - 1 / N, length=N))
        if rev
            s.data = reverse(s.data)
        end
    end

    if s.normalize
        s.data /= N
    end

    return s
end

function lognormal(min; stop=1.0, length=10)
    min = max(min, 0.01)
    stop = max(stop, min + 0.01)
    if length == 1
        return middle(min, stop)
    else
        lr = quantile.(Normal(0.0, 2.0), range(1 / (length + 1), stop=1 - 1 / (length + 1), length=length))
        lr .= lr .- minimum(lr)
        lr ./= maximum(lr)
        lr *= (log(stop) - log(min))
        lr .+= log(min)
        return exp.(lr)
    end
end

# Overload Base array interface functions for SED

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

# PDF calculation for SED

function pdf(s::SED)
    return [pdf(s.distribution, x) for x in s]
end

# SED constructor with optional data

function SED(; data=nothing, min=nothing, max=nothing, kwargs...)
    T = Float64 # Default type if not inferred from data
    N = 1 # Default number of dimensions
    A = Array{T, N} # Default array type if not inferred from data
    if data !== nothing
        T, N = eltype(data), ndims(data)
        A = typeof(data)
    else
        data = A(undef, 0) # Handle the case where there is no data
    end

    sed = SED{T, N, A}(;data, min, max, kwargs...)
    return sed
end