# Permits or use rights:
"""
    mutable struct Dynamic_permit_allocation <: LimitInstitution

A mutable struct that defines the parameters and function for dynamic permit allocation, inheriting from `LimitInstitution`.

# Fields
- `criteria::Symbol`: A symbol representing the criteria for allocating permits.
- `reverse::Bool`: A boolean flag indicating whether to reverse the order of allocation.
- `target::Symbol`: A symbol representing the target parameter for permit allocation.
- `value::Float64`: A value used in the calculation to determine the number of allowed permits.
- `fun::Function`: A function to execute the permit allocation process.

# Constructor
    Dynamic_permit_allocation(; criteria::Symbol = :w̃, reverse::Bool = false, target::Symbol = :effort, value::Float64 = 1.0, fun::Function = dynamic_permits)

Initializes an instance of `Dynamic_permit_allocation` with optional parameters, providing default values for each field.
"""
mutable struct Dynamic_permit_allocation <: LimitInstitution
    criteria::Symbol
    reverse::Bool
    value::Float64
    fun::Function
    label::String
    description::String
    cost::Function
    function Dynamic_permit_allocation(;criteria::Symbol = :w̃, reverse::Bool = false,  value::Float64 = 1.0, fun::Function = dynamic_permits, label::String="Dynamic permit allocation", description::String="Handles the dynamic allocation of permits based on the specified criteria and whether the order of allocation is reversed.", cost=x->0)
        new(criteria, reverse,  value, fun, label,description, cost)
    end
end

"""
    dynamic_permits(institution::Dynamic_permit_allocation, du, u, s, t)

Handles the dynamic allocation of permits based on the specified criteria and whether the order of allocation is reversed.

# Arguments
- `institution::Dynamic_permit_allocation`: An instance of the Dynamic_permit_allocation struct.
- `du`: A placeholder for differential updates, not used in the function.
- `u`: A vector indicating which entities wish to use the resource.
- `s`: A struct containing scenario data, including the criteria for allocation.
- `t`: A time step or other contextual parameter, not used in the function.

# Functionality
- Calculates the number of allowed permit holders based on the institution's value and the scenario's N.
- Identifies all entities that wish to use the resource (u > 0).
- If the number of potential users exceeds the number of allowed permits, it selects which entities will receive permits based on the criteria and whether the allocation is reversed.
- Sets the usage of non-selected entities to zero.
"""
function dynamic_permits(institution::Dynamic_permit_allocation,du,u,s,t)
  
    n=Int64(round(institution.value.*s.N)) # number of allowed permitholders (can we do this at scenario creation)
    id=findall(u.>0.0)      # get all who would like to use resource
    l=length(id)                  # number of potential resource users 
    if l>n  # if number of actors that want to use resource are more than number of permits 
        #println(p.target)
        if institution.reverse
            r=l-n+1:l   # select the permit holders (given to high w)
        else
            r=1:n # select the permit holders (given to low w)
        end
        q=sortperm(getfield(s,institution.criteria))
        idq=q[q .∉ Ref(id[r])] #checks if qdy is in id[r] and returns the indices of q that are not in id[r]
        u[idq] .= 0.0
    end
end

# Equal share
"""
    mutable struct Equal_share_allocation <: LimitInstitution

A mutable struct that defines the parameters and function for equal share allocation, inheriting from `LimitInstitution`.

# Fields
- `target::Symbol`: A symbol representing the target parameter for equal share allocation.
- `value::Float64`: A value used in the calculation to determine the allocation amount.
- `fun::Function`: A function to execute the equal share allocation process.

# Constructor
    Equal_share_allocation(; target::Symbol = :yield, value::Float64 = 0.0, fun::Function = equal_share)

Initializes an instance of `Equal_share_allocation` with optional parameters, providing default values for each field.
"""
mutable struct Equal_share_allocation <: LimitInstitution
    target::Symbol      # Target parameter for equal share allocation
    value::Float64      # Value used for allocation calculation
    fun::Function       # Function to execute equal share allocation
    label::String
    description::String
    cost::Function
    # Constructor for `Equal_share_allocation` with default parameter values
    function Equal_share_allocation(; target::Symbol = :yield, value::Float64 = 0.0, fun::Function = equal_share, label::String="Equal share allocation", description::String="Handles the equal share allocation based on the specified target and value.", cost=x->0)
        new(target, value, fun, label,description,cost)
    end
end

"""
    equal_share(institution::Equal_share_allocation, du, u, s, t)

Handles the equal share allocation based on the specified target and value.

# Arguments
- `institution::Equal_share_allocation`: An instance of the Equal_share_allocation struct.
- `du`: A placeholder for differential updates, not used in the function.
- `u`: A vector indicating which entities wish to use the resource.
- `s`: A struct containing scenario data, including the total number of entities (N).
- `t`: A time step or other contextual parameter, not used in the function.

# Functionality
- Calculates the number of entities that wish to use the resource.
- If the target is `:yield`, it adjusts the usage of each entity to ensure that no entity exceeds its fair share of the yield.
- If the target is `:effort`, it adjusts the usage of each entity to ensure that no entity exceeds its fair share of the effort.
"""
function equal_share(institution::Equal_share_allocation, du, u, s, t)
    # Calculate the number of entities that wish to use the resource
    n = sum(u .> 0.0)

    if institution.target == :yield
        # Adjust usage to ensure no entity exceeds its fair share of the yield
        u[1:s.N] .= ifelse.(u[1:s.N] .> institution.value / u[s.N+1] / n, institution.value / u[s.N+1] / n, u[1:s.N])
    elseif institution.target == :effort
        # Adjust usage to ensure no entity exceeds its fair share of the effort
        u[1:s.N] .= ifelse.(u[1:s.N] .> institution.value / n, institution.value / n, u[1:s.N])
    end
end



# Protected area
"""
    mutable struct Protected_area <: StaticInstitution

A mutable struct that defines the parameters and function for a protected area, inheriting from `StaticInstitution`.

# Fields
- `dispersal::Float64`: A value representing the dispersal rate in the protected area.
- `value::Float64`: A value used to determine the proportion of the area that is protected.
- `fun::Function`: A function to execute the protected area configuration.

# Constructor
    Protected_area(; dispersal::Float64 = 0.1, value::Float64 = 0.0, fun::Function = protected_area)

Initializes an instance of `Protected_area` with optional parameters, providing default values for each field.
"""
mutable struct Protected_area <: StaticInstitution
    dispersal::Float64  # Dispersal rate in the protected area
    value::Float64      # Proportion of the area that is protected
    fun::Function       # Function to configure the protected area
    label::String
    description::String
    cost::Function
    # Constructor for `Protected_area` with default parameter values
    function Protected_area(; dispersal::Float64 = 0.1, value::Float64 = 0.0, fun::Function = protected_area, label::String="Protected area", description::String="Configures the protected area based on the specified dispersal rate and value.", cost=x->0)
        new(dispersal, value, fun, label,description,cost)
    end
end

"""
    protected_area(institution::Protected_area, s)

Configures the protected area based on the specified dispersal rate and value.

# Arguments
- `institution::Protected_area`: An instance of the Protected_area struct.
- `s`: A struct containing scenario data, including fields for `protected` and `dispersal`.

# Functionality
- Sets the proportion of the area that is protected based on the institution's value.
- Sets the dispersal rate in the scenario based on the institution's dispersal value.
"""
function protected_area(institution::Protected_area, s)
    # Set the proportion of the area that is protected
    s.protected = 1 - institution.value
    
    # Set the dispersal rate in the scenario
    s.dispersal = institution.dispersal
end


# Subsidies and taxes

"""
    mutable struct Economic_incentive <: StaticInstitution

A mutable struct that defines the parameters and function for an economic incentive, inheriting from `StaticInstitution`.

# Fields
- `target::Symbol`: A symbol representing the target parameter for the economic incentive.
- `max::Float64`: A maximum value used in the calculation of the economic incentive.
- `subsidize::Bool`: A boolean flag indicating whether to reverse the effect of the economic incentive.
- `value::Float64`: A value used in the calculation to determine the magnitude of the economic incentive.
- `fun::Function`: A function to execute the economic incentive configuration.

# Constructor
    Economic_incentive(; target::Symbol = :q, max::Float64 = 0.5, subsidize::Bool = false, value::Float64 = 1.0, fun::Function = economic_incentive)

Initializes an instance of `Economic_incentive` with optional parameters, providing default values for each field.
"""
mutable struct Economic_incentive <: StaticInstitution
    target::Symbol      # Target parameter for the economic incentive
    max::Float64        # Maximum value used for the incentive calculation
    subsidize::Bool       # subsidize=true or tax
    value::Float64      # Value used to determine the magnitude of the incentive
    fun::Function       # Function to execute the economic incentive configuration
    label::String
    description::String
    cost::Function
    # Constructor for `Economic_incentive` with default parameter values
    function Economic_incentive(; target::Symbol = :q, max::Float64 = 1.0, subsidize::Bool = false, value::Float64 = 1.0, fun::Function = economic_incentive, label::String="Economic incentive", description::String="Configures the economic incentive based on the specified target, maximum value, reverse flag, and value.", cost=x->subsidize ? -x : x)
        new(target, max, subsidize, value, fun, label,description,cost)
    end
end

"""
    economic_incentive(institution::Economic_incentive, s)

Configures the economic incentive based on the specified target, maximum value, reverse flag, and value.

# Arguments
- `institution::Economic_incentive`: An instance of the Economic_incentive struct.
- `s`: A struct containing scenario data, including fields for `aw̃` and `aū`.

# Functionality
- If the target is `:p`, it adjusts `s.aw̃` by adding the incentive effect.
- If the target is `:q`, it adjusts both `s.aū` and `s.aw̃` by adding the incentive effect to `s.aū` and normalizing `s.aw̃`.
"""
function economic_incentive(institution::Economic_incentive, s)
   
    if institution.target == :p
        # Adjust aw̃ by adding the incentive effect
        s.aw̃ = ones(s.N)  ./ (1 + institution.max * (1.0-institution.value) * (institution.subsidize ? 1.0 : -1.0))
    elseif institution.target == :q
        # Adjust aū by adding the incentive effect
        s.aū = ones(s.N) .*(1 + institution.max * (1.0-institution.value) * (institution.subsidize ? 1.0 : -1.0))
        # Normalize aw̃ based on the incentive effect
        s.aw̃ = ones(s.N)  ./ (1 + institution.max * (1.0-institution.value) * (institution.subsidize ? 1.0 : -1.0))
    elseif institution.target == :w
        # Normalize aw̃ based on the incentive effect
        s.aw̃ = ones(s.N)  .* (1 + institution.max * (1.0-institution.value) * (institution.subsidize ? 1.0 : -1.0))
      
    end
end

# Market
"""
    mutable struct Market <: DynamicInstitution

A mutable struct that defines the parameters and function for a market mechanism, inheriting from `DynamicInstitution`.

# Fields
- `criteria::Symbol`: A symbol representing the criteria for market allocation.
- `target::Symbol`: A symbol representing the target parameter for market allocation.
- `value::Float64`: A value used in the calculation to determine the total supply available in the market.
- `fun::Function`: A function to execute the market mechanism.

# Constructor
    Market(; criteria::Symbol = :ϕ, reverse::Bool = false, target::Symbol = :effort, value::Float64 = 1.0, control::Symbol = :default_control, fun::Function = market)

Initializes an instance of `Market` with optional parameters, providing default values for each field.
"""
mutable struct Market <: DynamicInstitution
    criteria::Symbol    # Criteria for market allocation
    target::Symbol      # Target parameter for market allocation
    value::Float64      # Total supply available in the market
    market_rate::Float64 # Rate of change in the tradable quota price
    fun::Function       # Function to execute the market mechanism
    label::String
    description::String
    cost::Function
    # Constructor for `Market` with default parameter values
    function Market(;criteria::Symbol = :ϕ, 
                    target::Symbol = :effort, 
                    value::Float64 = 1.0, 
                    market_rate::Float64 = 0.01, 
                    fun::Function = market,
                    label::String="Market mechanism",
                    description::String="Executes the market mechanism for allocating resources based on supply and demand.", 
                    cost=x->0)
        new(criteria, target, value, market_rate,fun, label,description,cost)
    end
end
"""
    market(institution::Market, du, u, s, t)

Executes the market mechanism for allocating resources based on supply and demand.

# Arguments
- `institution::Market`: An instance of the Market struct.
- `du`: A vector indicating the desired change in usage for each entity.
- `u`: A vector indicating the current usage for each entity.
- `s`: A struct containing scenario data, including fields for `institution`, `N`, `ū`, and `β`.
- `t`: A time step or other contextual parameter, not used in the function.

# Functionality
- Determines the supply available in the market based on the target and value.
- Identifies entities that wish to increase their usage.
- Calculates the demand for increased usage and compares it to the available supply.
- If demand exceeds supply, adjusts the desired change in usage proportionally to the available supply.
- Updates the tradable quota price based on the difference between demand and supply.
"""
function market(institution::Market, du, u, s, t)
    # Determine the supply available in the market based on the target and value
    if s.institution[1].target == :yield
        supply = max(0.0, s.institution[1].value - sum(u[1:s.N]) * u[s.N+1])
    else
        supply = max(0.0, s.institution[1].value - sum(u[1:s.N]))
    end

    # Identify entities that wish to increase their usage
    id = findall(du[1:s.N] .> 0.0)
    
    # Calculate individual demand for increased usage
    ind_demand = min.(view(du, id), view(s.ū, id) .- (view(u, id)))
    demand = sum(ind_demand)
    
    # If demand exceeds supply, adjust the desired change in usage proportionally to the available supply
    if demand > supply
        du[id] .= supply .* ind_demand ./ demand
    end
    
    # Update the tradable quota price based on the difference between demand and supply
    du[s.N+3] = s.institution[1].market_rate * (demand - supply)
end


mutable struct Open_access <: StaticInstitution
    fun::Function
    value::Float64
    label::String
    description::String
    cost::Function
    function Open_access(fun::Function = open_access, value::Float64 = 0.0, label::String="Open access", description::String="Handles the open access scenario.", cost=x->0)
        new(fun, value, label,description,cost)
    end
end

function open_access(inst::Open_access, s)
    return
end
