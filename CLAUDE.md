# SocialEconomicDiversity.jl Development Guide

## Build & Test Commands
- Run tests: `julia --project -e "using Pkg; Pkg.test()"`
- Run single test: `julia --project -e "using Pkg; Pkg.test(\"SocialEconomicDiversity\", test_args=[\"diversity.jl\"])"`
- Load project in REPL: `julia --project`
- Enable hot-reloading: `julia --project -e "using Revise; using SocialEconomicDiversity"`

## Code Style Guidelines
- Naming: Use descriptive names; math symbols (e.g., `γ`, `μ`, `ϕ`) for model parameters
- Types: Use parametric types with proper type annotations; prefer `@kwdef` for structs
- Imports: Group imports by functionality; use explicit imports to avoid ambiguities
- Documentation: Use docstrings for functions/types (""" ... """ format)
- Error handling: Use informative error messages with `error()` function
- Functions: Implement both mutating (with !) and non-mutating versions of functions
- Dependencies: Clearly specify and document dependencies between components
- Visualization: Use CairoMakie for plotting with consistent styling parameters