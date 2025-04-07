using Distributions
using Statistics
using CairoMakie

"""
Example of a socio-economic context where multiple factors influence key economic parameters.

This example models:
1. Individual characteristics: health, age, parental economic status, gender
2. Group associations (e.g., cooperatives, social networks)
3. Derived parameters: max time for work (ebar), harvest efficiency (q), opportunity cost (w)
4. Resource dynamics parameters: carrying capacity (K) and growth rate (r)
5. Final SED parameters: opportunity cost (w̃) and utility of resource use (ū)
"""

# Create a simulation with 1000 individuals
N = 1000

# ===== Base Individual Characteristics =====

# Health status (0-1 scale, lognormal distribution centered at 0.7)
health = rand(LogNormal(log(0.7), 0.3), N)

# Age (18-80 years, somewhat right-skewed)
age = 18 .+ rand(LogNormal(log(35-18), 0.4), N)

# Parental economic status (0-1 scale, bimodal to represent inequality)
# 30% from lower economic class, 70% from higher economic class
parental_status = zeros(N)
class = rand(Bernoulli(0.7), N)
for i in 1:N
    # Lower economic class distribution
    lower_dist = LogNormal(log(0.3), 0.2)
    # Higher economic class distribution
    higher_dist = LogNormal(log(0.7), 0.2)
    parental_status[i] = class[i] ? rand(higher_dist) : rand(lower_dist)
end

# Gender (binary for simplicity: 0=male, 1=female) with gender wage gap effects
gender = rand(Bernoulli(0.5), N)

# ===== Group Associations =====

# Cooperative membership (binary: 0=no, 1=yes)
# Higher parental status and age slightly increase likelihood of membership
cooperative = zeros(N)
for i in 1:N
    p_coop = min(1.0, 0.2 + 0.2 * parental_status[i] + 0.005 * age[i] / 80)
    cooperative[i] = rand() < p_coop ? 1.0 : 0.0
end

# Social network strength (0-1 scale)
# Influenced by age (peaks at middle age) and cooperative membership
network = zeros(N)
for i in 1:N
    # Age effect peaks at age 40
    age_effect = 1.0 - abs(age[i] - 40) / 40
    base_network = rand(LogNormal(log(0.5), 0.3))
    network_contrib = 0.3 * age_effect + 0.2 * cooperative[i]
    network[i] = base_network + network_contrib
end

# ===== Derived Economic Parameters =====

# Maximum time available for work (ebar) - in hours per day
# Affected by health, age, and gender (representing care responsibilities)
ebar = zeros(N)
for i in 1:N
    health_effect = health[i]
    age_norm = age[i] / 80
    age_effect = 1.0 - 2.0 * abs(age_norm - 0.5)
    gender_effect = 1.0 - 0.2 * gender[i]
    ebar[i] = 8.0 * health_effect * age_effect * gender_effect
end

# Harvest efficiency (q) - catch per unit effort
# Affected by health, age (experience), and cooperative membership
q = zeros(N)
for i in 1:N
    health_effect = health[i]
    age_experience = min(1.0, age[i] / 40)
    coop_effect = 1.0 + 0.3 * cooperative[i]
    q[i] = health_effect * (0.7 + 0.5 * age_experience) * coop_effect
end

# Alternative income opportunities (w) - income per hour from other activities
# Affected by education (approximated by parental status), network, gender, health
w = zeros(N)
for i in 1:N
    education_effect = 5.0 + 15.0 * parental_status[i]
    network_effect = 1.0 + 0.5 * network[i]
    gender_effect = 1.0 - 0.2 * gender[i]
    health_effect = 0.8 + 0.2 * health[i]
    w[i] = education_effect * network_effect * gender_effect * health_effect
end

# ===== Resource Parameters =====

# Carrying capacity (K) - single value constant
K = 1000.0

# Intrinsic growth rate (r) - single value constant
r = 0.3

# ===== Final SED Parameters =====

# Opportunity cost (w̃) - Alternative income vs. max time available
w̃ = w ./ ebar

# Utility of resource use (ū) - Maximum utility from resource
ū = 1.0 .+ 0.5 .* q

# Create the complete context
context = (
    N=N,
    # Individual characteristics
    health=health,
    age=age,
    parental_status=parental_status,
    gender=gender,
    
    # Group associations
    cooperative=cooperative,
    network=network,
    
    # Derived economic parameters
    ebar=ebar,
    q=q,
    w=w,
    
    # Resource parameters
    K=K,
    r=r,
    
    # Final SED parameters
    w̃=w̃,
    ū=ū
)

# ===== Analysis Functions =====

"""Analyze the impact of individual factors on economic outcomes"""
function analyze_correlations(context)
    println("=== Correlation Analysis ===")
    
    # Correlations with w̃ (opportunity cost)
    println("\nFactors influencing opportunity cost (w̃):")
    println("Health correlation: ", cor(context.health, context.w̃))
    println("Age correlation: ", cor(context.age, context.w̃))
    println("Parental status correlation: ", cor(context.parental_status, context.w̃))
    println("Gender correlation: ", cor(context.gender, context.w̃))
    println("Cooperative membership correlation: ", cor(context.cooperative, context.w̃))
    
    # Correlations with ū (utility of resource use)
    println("\nFactors influencing utility of resource use (ū):")
    println("Health correlation: ", cor(context.health, context.ū))
    println("Age correlation: ", cor(context.age, context.ū))
    println("Cooperative membership correlation: ", cor(context.cooperative, context.ū))
    
    # Gini coefficients to measure inequality
    function gini(x)
        # Sort values
        x_sorted = sort(x)
        n = length(x)
        # Calculate Gini coefficient
        return sum([abs(x_sorted[i] - x_sorted[j]) for i in 1:n, j in 1:n]) / (2 * n * sum(x_sorted))
    end
    
    println("\n=== Inequality Analysis (Gini Coefficients) ===")
    println("Alternative income (w): ", gini(context.w))
    println("Opportunity cost (w̃): ", gini(context.w̃))
    println("Utility of resource use (ū): ", gini(context.ū))
    
    # Group analysis
    println("\n=== Group Analysis ===")
    
    # Gender differences
    male_indices = findall(x -> x == 0, context.gender)
    female_indices = findall(x -> x == 1, context.gender)
    
    println("Average opportunity cost (w̃):")
    println("  Males: ", mean(context.w̃[male_indices]))
    println("  Females: ", mean(context.w̃[female_indices]))
    
    println("Average utility of resource use (ū):")
    println("  Males: ", mean(context.ū[male_indices]))
    println("  Females: ", mean(context.ū[female_indices]))
    
    # Cooperative vs non-cooperative
    coop_indices = findall(x -> x == 1, context.cooperative)
    noncoop_indices = findall(x -> x == 0, context.cooperative)
    
    println("\nAverage opportunity cost (w̃):")
    println("  Cooperative members: ", mean(context.w̃[coop_indices]))
    println("  Non-members: ", mean(context.w̃[noncoop_indices]))
    
    println("Average utility of resource use (ū):")
    println("  Cooperative members: ", mean(context.ū[coop_indices]))
    println("  Non-members: ", mean(context.ū[noncoop_indices]))
end

# Run the analysis
analyze_correlations(context)

# ===== Visualization Functions =====

"""Create a multi-facet correlation plot for the key variables"""
function create_correlation_plot(context)
    # Select key variables for visualization
    variables = [
        "Health" => context.health,
        "Age" => context.age,
        "Parental Status" => context.parental_status,
        "Gender" => context.gender,
        "Cooperative" => context.cooperative,
        "Network" => context.network,
        "Work Time (ebar)" => context.ebar,
        "Efficiency (q)" => context.q,
        "Alt. Income (w)" => context.w,
        "Opportunity Cost (w̃)" => context.w̃,
        "Utility (ū)" => context.ū
    ]
    
    # Create a correlation matrix
    n_vars = length(variables)
    corr_matrix = zeros(n_vars, n_vars)
    for i in 1:n_vars
        for j in 1:n_vars
            corr_matrix[i, j] = cor(variables[i][2], variables[j][2])
        end
    end
    
    # Create a multi-facet plot
    fig = Figure(size=(1000, 800), fontsize=12)
    
    # Create a heatmap of the correlation matrix
    ax_heatmap = Axis(fig[1, 1], 
                      title="Correlation Heatmap",
                      xlabel="Variables", 
                      ylabel="Variables",
                      xticks=(1:n_vars, [v[1] for v in variables]),
                      yticks=(1:n_vars, [v[1] for v in variables]))
    
    hm = heatmap!(ax_heatmap, corr_matrix, 
                  colormap=:RdBu, 
                  colorrange=(-1, 1))
    
    # Set the axis properties
    ax_heatmap.xticklabelrotation = π/4
    
    # Add a colorbar with tellwidth=false
    Colorbar(fig[1, 2], hm, label="Correlation", tellwidth=false)
    
    # Create scatter plots for key relationships
    key_relationships = [
        ("Health", "Utility (ū)"),
        ("Parental Status", "Alt. Income (w)"),
        ("Gender", "Opportunity Cost (w̃)"),
        ("Cooperative", "Efficiency (q)")
    ]
    
    for (i, (var1, var2)) in enumerate(key_relationships)
        row = 2 + (i-1) ÷ 2
        col = 1 + (i-1) % 2
        
        idx1 = findfirst(v -> v[1] == var1, variables)
        idx2 = findfirst(v -> v[1] == var2, variables)
        
        x_data = variables[idx1][2]
        y_data = variables[idx2][2]
        
        ax = Axis(fig[row, col], 
                  title="$(var1) vs $(var2)",
                  xlabel=var1,
                  ylabel=var2)
        
        # If the variable is binary (gender or cooperative), create grouped boxplots
        if var1 in ["Gender", "Cooperative"]
            x0_indices = findall(x -> x == 0, x_data)
            x1_indices = findall(x -> x == 1, x_data)
            
            # Create data for boxplots
            positions = [1, 2]
            labels = var1 == "Gender" ? ["Male", "Female"] : ["Non-member", "Member"]
            
            boxplot!(ax, fill(positions[1], length(x0_indices)), y_data[x0_indices], 
                     label=labels[1])
            boxplot!(ax, fill(positions[2], length(x1_indices)), y_data[x1_indices], 
                     label=labels[2])
            
            # Set x-ticks to match the boxplot positions
            ax.xticks = (positions, labels)
            
            # Add a legend
            axislegend(ax, position=:lt)
        else
            # Regular scatter plot with trend line
            scatter!(ax, x_data, y_data, 
                     markersize=5, 
                     alpha=0.5,
                     color=:darkblue)
            
            # Fit a trend line
            if !(var1 in ["Gender", "Cooperative"] || var2 in ["Gender", "Cooperative"])
                try
                    # Simple linear regression
                    b = [ones(length(x_data)) x_data] \ y_data
                    x_range = range(minimum(x_data), maximum(x_data), length=100)
                    lines!(ax, x_range, b[1] .+ b[2] .* x_range, 
                           color=:red, 
                           linewidth=2,
                           label="Trend")
                catch
                    # In case of singular matrix or other issues
                end
            end
        end
    end
    
    # Add a title
    Label(fig[0, :], "Socio-Economic Context: Variable Relationships", 
          fontsize=20)
    
    # Save the figure
    save("socioeconomic_correlations.png", fig)
    
    # Return the figure for display
    return fig
end

# Create the correlation plot
fig = create_correlation_plot(context)

# Display key statistics
println("\n=== Key Statistics ===")
println("Mean opportunity cost (w̃): ", mean(context.w̃))
println("Mean utility of resource use (ū): ", mean(context.ū))
println("Correlation between w̃ and ū: ", cor(context.w̃, context.ū))

# Return the figure
fig