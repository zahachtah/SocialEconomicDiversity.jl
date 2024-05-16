#=

Consider this instead:

struct dynamic_permit_allocation <: limitInstitution
    params=NamedTuple()
end

function dyn_permits(institution::dynamic_permit_allocation,du,u,s,t)
    @unpack criteria, reverse, target, value, control, fun = institution.params

end

=#



# Permits or use rights:

mutable struct Dynamic_permit_allocation <: LimitInstitution
    criteria::Symbol
    reverse::Bool
    target::Symbol
    value::Float64
    control::Symbol
    fun::Function
end

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


mutable struct Equal_share_allocation <: LimitInstitution
    criteria::Symbol
    reverse::Bool
    target::Symbol
    value::Float64
    control::Symbol
    fun::Function
end

function equal_share(institution::Equal_share_allocation,du,u,s,t)
    n=sum(u.>0.0)
    if institution.target==:yield
        u[1:s.N].=ifelse.(u[1:s.N].>institution.value/u[s.N+1]/n, institution.value/u[s.N+1]/n , u[1:s.N] )
    elseif institution.target==:effort
        u[1:s.N].=ifelse.(u[1:s.N].>institution.value/n, institution.value/n , u[1:s.N] )
    end
end


# Protected area

mutable struct Protected_area <: StaticInstitution
    dispersal::Float64
    value::Float64
    fun::Function
end

function protected_area(institution::Protected_area,s)
  s.protected=1-institution.value
  s.dispersal=institution.dispersal
end

mutable struct Economic_incentive <: StaticInstitution
    criteria::Symbol
    reverse::Bool
    target::Symbol
    value::Float64
    control::Symbol
    fun::Function
end

function economic_incentive(institution::Economic_incentive,s)
    if institution.criteria==:p
        s.aw̃=s.aw̃.+institution.value*(institution.reverse ? -1.0 : 1.0) 
    elseif institution.criteria==:q
        s.aū=s.aū.+institution.value*(institution.reverse ? -1.0 : 1.0)
        s.aw̃=s.aw̃./(1+institution.value*(institution.reverse ? -1.0 : 1.0))
    end
end





mutable struct Market <: DynamicInstitution
    criteria::Symbol
    reverse::Bool
    target::Symbol
    value::Float64
    control::Symbol
    fun::Function

    # Inner constructor with default values
    function Market(;criteria::Symbol = :ϕ, 
                    reverse::Bool = false, 
                    target::Symbol = :effort, 
                    value::Float64 = 1.0, 
                    control::Symbol = :default_control, 
                    fun::Function = market)
        new(criteria, reverse, target, value, control, fun)
    end
end

function market(institution::Market,du,u,s,t)
    if s.institution[1].target==:yield
        supply=max(0.0,s.institution[1].value-sum(u[1:s.N])*u[s.N+1])
    else
        supply=max(0.0,s.institution[1].value-sum(u[1:s.N]))
        
    end
    id=findall(du[1:s.N].>0.0) # who wants to increase u => id
    
        # available quotas, but in units of u
    #demand=sum(max.(0.0,view(ū,id).-(view(u,id).+view(dx,id)))) # demand, as in intending to increase u
    ind_demand=min.(view(du,id),view(s.ū,id).-(view(u,id)))
    demand=sum(ind_demand)
    #println((demand, supply))
    if demand > supply # if demand is greater than supply, buyers have to share supply proportionally to their individual demand or willingness to pay.
        du[id].=supply.*ind_demand./demand # Supply shared among all who demand
        # implement highst incomes first!
    end  

    # else they can just do as they please, i.e. dudt is not adjusted

    # Dynamics of tradable quota price
    du[s.N+3]= s.β*(demand -supply)
end
