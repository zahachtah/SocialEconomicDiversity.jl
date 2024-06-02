using Statistics
using Base: @kwdef
import Base: show

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
