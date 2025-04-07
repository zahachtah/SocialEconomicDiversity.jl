# SocialEconomicDiversity

[![Build Status](https://github.com/zahachtah/SocialEconomicDiversity.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/zahachtah/SocialEconomicDiversity.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Overview

SocialEconomicDiversity.jl is a Julia package for modeling and analyzing the impacts of conservation policies on diverse socio-economic groups. The package facilitates modeling how agents with different socio-economic characteristics interact with natural resources under various policy instruments.

## Key Features

- **Socio-Economic Diversity (SED)**: Create and manipulate distributions of socio-economic characteristics across agent populations
- **Policy Instruments**: Model different conservation approaches including:
  - Open Access (no regulation)
  - Exclusive Use Rights
  - Tradable Use Rights
  - Protected Areas
  - Economic Incentives
  - Development Policies
- **Simulation**: System dynamics modeling using ODEs
- **Analysis**: Analyze income distributions, inequality, and resource states
- **Visualization**: Plot phase diagrams, incentive distributions, impact distributions, and income distributions

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl.git")
```

## Basic Usage

Here's a simple example demonstrating how to create a socio-economic scenario, apply a policy instrument, run a simulation, and visualize the results:

```julia
using SocialEconomicDiversity
using CairoMakie

# Create a base scenario with socio-economic diversity
s = base(N=100)  # Create a base scenario with 100 agents

# Generate distributions for all parameters
dist!(s)

# Create a scenario with Protected Area policy and mobility rate of 0.3
s_pa = scenario(s, policy="Protected Area", m=0.3)

# Run simulation with 20% protected area
sol = sim(s_pa, regulation=0.2)

# Create a figure for visualization
fig = Figure(size=(800, 600))

# Create a phase plot to show resource dynamics
ax1 = Axis(fig[1, 1], xlabel="Resource State (x)", ylabel="Effort (h)")
phase_plot!(ax1, sol)

# Plot income distributions
ax2 = Axis(fig[1, 2], xlabel="Income Percentile", ylabel="Income")
incomes_plot!(ax2, sol)

# Save the figure
save("example_plot.png", fig)
```

## Module Structure

The package is organized into several modules:

- **Core (SocialEconomicDiversity.jl)**: Main module that exports all functionality
- **SED (sed.jl)**: Implementation of socio-economic diversity distributions
- **Policy Instruments (policy_instruments.jl)**: Implementation of different policy approaches
- **Visualizations (visualizations.jl)**: Functions for creating plots and figures

## Socio-Economic Diversity (SED)

The `SED` type allows for creating distributions of agent characteristics:

```julia
# Create SED with specific parameters
my_sed = sed(
    w̃ = (dist=:LogNormal, median=0.5, sigma=0.5),  # Opportunity cost
    ū = (dist=:Uniform, min=0.5, max=1.5),         # Utility of resource use
    β = (dist=:Dirac, val=0.5),                    # Discount rate (constant)
    γ = (dist=:LogNormal, median=1.0, sigma=0.5)   # Catchability coefficient
)

# Generate distributions with 100 samples
dist!(my_sed, 100)
```

## Policy Instruments

Different policy instruments can be applied to scenarios:

```julia
# Create base scenario
s = base()

# Apply different policies
s_oa = s                                   # Open Access (no regulation)
s_eur = scenario(s, policy="Exclusive Use Rights")  # Exclusive Use Rights 
s_tur = scenario(s, policy="Tradable Use Rights")   # Tradable Use Rights
s_pa = scenario(s, policy="Protected Area")         # Protected Area
s_ei = scenario(s, policy="Economic Incentive")     # Economic Incentive
s_dev = scenario(s, policy="Development")           # Development policy

# Run simulations with different regulation levels
sol_oa = sim(s_oa)                      # Open Access (no regulation)
sol_eur = sim(s_eur, regulation=0.5)    # Exclusive Use Rights (50% regulation)
sol_tur = sim(s_tur, regulation=0.5)    # Tradable Use Rights (50% regulation) 
sol_pa = sim(s_pa, regulation=0.2)      # Protected Area (20% coverage)
sol_ei = sim(s_ei, regulation=2.0)      # Economic Incentive (subsidy level 2.0)
sol_dev = sim(s_dev, regulation=0.5)    # Development policy (50% intervention)
```

## Publication Figures

The package includes scripts to recreate figures from the accompanying publication:

1. Figure 1: Redrawn from Cinner in Google Drawing
2. Figure 2: Combination of visual assets
3. Figure 3: System dynamics
4. Figure 4: Formalizing Policy Instruments through incentives
5. Figure 5: Optimal policy regulation level
6. Figure 6: Comparing Different socio-economic contexts

## License

This package is licensed under the MIT License - see the LICENSE file for details.