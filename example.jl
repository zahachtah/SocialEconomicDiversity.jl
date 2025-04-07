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

# Plot income distributions directly
ax2 = Axis(fig[1, 2], xlabel="Income Percentile", ylabel="Income")
incomes_plot!(ax2, sol)

# Save the figure
save("example_plot.png", fig)

println("Example completed successfully!")