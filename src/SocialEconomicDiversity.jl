module SocialEconomicDiversity

using Colors, Statistics, OrdinaryDiffEq, Distributions,CairoMakie, FileIO, Graphs, Random, KernelDensity, ColorSchemes, NetworkLayout
using DiffEqCallbacks: TerminateSteadyState
using Base: @kwdef
import Base: show
import Distributions: pdf, Uniform, LogNormal, Normal, Exponential, Dirac

export SED, dist!,astext
export scenario
export sim!
export institutional_impact
export phaseplot!,phaseplot, incomes!,incomes, SEDplot!,SEDplot, individual_u!, dependencies, plot_institutional_impact
export Dynamic_permit_allocation, dynamic_permits, Equal_share_allocation, equal_share, Protected_area, protected_area,  Economic_incentive, economic_incentive, Market,market
export Uniform, LogNormal, Normal, Exponential, Dirac

include("diversity.jl")
include("scenario.jl")
include("model.jl")
include("abstract_institutions.jl")
include("specified_institutions.jl")
include("utils.jl")
include("visualizations.jl")
#include("figure_codes/figures.jl")

end
