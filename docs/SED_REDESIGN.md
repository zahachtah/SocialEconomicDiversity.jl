# SED Redesign Documentation

This document describes the redesign of the Socio-Economic Distribution (SED) system in SocialEconomicDiversity.jl. The redesign aims to provide a cleaner, more intuitive API while maintaining all the functionality of the original implementation.

## Key Improvements

1. **Cleaner Abstractions**: The new design separates the concerns of distribution specification, sampling, and dependency resolution into distinct components.

2. **Type-Based Architecture**: Uses Julia's type system and multiple dispatch to handle different distribution types elegantly.

3. **Simplified API**: More consistent and intuitive API with fewer special cases.

4. **Better Dependency Model**: Dependencies are explicitly modeled and easier to understand.

5. **Improved Performance**: More type-stable code that should result in better performance.

6. **Enhanced Documentation**: Better docstrings and examples throughout the codebase.

## Core Components

### Distribution Specifications

The new design introduces explicit types for different ways to specify distributions:

```julia
# Different ways to specify distributions
MinMaxSpec        # Using min/max values
MeanSigmaSpec     # Using mean/sigma values
MedianSigmaSpec   # Using median/sigma values
SingleValueSpec   # Constant values
ProbabilitySpec   # For distributions defined by a probability
DirectSpec        # For directly providing a distribution
```

This makes it clearer how a distribution is being defined and allows for more elegant dispatch.

### Dependency Specification

Dependencies are now represented by a dedicated type:

```julia
DependencySpec(
    factors::Dict{Symbol, Union{Float64, Function}},  # Scaling factors for dependencies
    custom_function::Union{Nothing, Function},        # Optional custom computation
    combination_function::Function                    # How to combine independent & dependent parts
)
```

This provides a clearer model of how dependencies work and how they are combined with the independent distribution.

### SED Type

The new `SED` type is more focused:

```julia
mutable struct SED{T<:AbstractFloat}
    data::Vector{T}                             # The actual distribution data
    spec::DistributionSpec                      # How to generate the distribution
    dependency::Union{Nothing, DependencySpec}  # Optional dependency specification
    random::Bool                                # Whether to use random sampling
    normalize::Bool                             # Whether to normalize the data
    reverse::Bool                               # Whether to reverse the order
end
```

This design clearly separates the distribution specification from the actual data and makes the purpose of each field more obvious.

## Usage Examples

### Creating SEDs

```julia
# Min/max specification for LogNormal
s1 = sed(distribution=LogNormal, min=0.5, max=2.0)

# Mean/sigma specification for Uniform
s2 = sed(distribution=Uniform, mean=1.0, sigma=0.5)

# Median/sigma specification for LogNormal
s3 = sed(distribution=LogNormal, median=1.0, sigma=0.3)

# Constant value
s4 = sed(distribution=Dirac, value=1.0)

# Bernoulli distribution with probability
s5 = sed(distribution=Bernoulli, probability=0.7)
```

### Dependencies

```julia
# Simple dependency (z = 2x + 3y)
z = sed(
    distribution=Uniform, 
    min=0.0, 
    max=1.0,
    dependent=(x=2.0, y=3.0)
)

# Complex dependency with custom function
z = sed(
    distribution=Uniform, 
    min=0.0, 
    max=1.0,
    dependent=(
        x=1.0, 
        y=1.0, 
        fun=(dep -> dep.x .* dep.y ./ (dep.x .+ dep.y))
    )
)
```

### Generating Distributions

```julia
# Generate for a single SED
dist!(my_sed, 100)

# Generate with dependencies
dist!(my_sed, 100, context=my_context)

# Generate all SEDs in a context
dist!(my_context, 100)

# Generate for a specific parameter
dist!(my_context, :parameter_name)
```

## Migration Guide

### Function Call Changes

Old API:
```julia
w̃ = sed(min=0.5, max=2.0, distribution=LogNormal)
```

New API:
```julia
w̃ = sed(distribution=LogNormal, min=0.5, max=2.0)
```

### Dependency Changes

Old API:
```julia
w̃ = sed(
    dependent=(ē = 1.0, q = 1.0, r = 1.0, fun = (dep -> (dep.ē * dep.q) / dep.r)), 
    min = 0.1, 
    max = 0.2, 
    distribution = LogNormal
)
```

New API:
```julia
w̃ = sed(
    distribution=LogNormal,
    min=0.1,
    max=0.2,
    dependent=(
        ē=1.0, 
        q=1.0, 
        r=1.0, 
        fun=(dep -> (dep.ē * dep.q) / dep.r)
    )
)
```

### Distribution Generation

The `dist!` function maintains the same API but with better error messages and more consistent behavior.

## Benefits Over Original Implementation

1. **Clarity**: The new implementation makes it clear how distributions are specified and how dependencies work.

2. **Consistency**: Uniform handling of different distribution types without special cases.

3. **Type Safety**: Better use of Julia's type system for improved safety and performance.

4. **Error Handling**: More specific and helpful error messages.

5. **Extensibility**: Easier to add new distribution types or dependency mechanisms.

6. **Testability**: Cleaner separation of concerns makes the code more testable.

## Implementation Notes

The redesign was guided by several key principles:

1. **Separation of Concerns**: Clearly separate distribution specification, sampling, and dependency resolution.

2. **Type-Based Design**: Use Julia's type system and multiple dispatch effectively.

3. **Explicit Over Implicit**: Make behavior explicit rather than relying on conventions or global state.

4. **Consistency**: Provide a consistent API without special cases.

5. **Backward Compatibility**: Maintain the same high-level API while cleaning up the implementation.