mutable struct Scenario
    N
    external
    w
    q
    ē
    a
    r
    K
    protected
    dispersal
    p
    w̃
    ū
    aw̃
    aū
    α
    g
    u
    U
    y
    ϕ
    t
    t_u
    t_U
    t_y
    t_ϕ
    total_revenue
    resource_revenue
    wage_revenue
    trade_revenue
    gini
    institution
    sim
    label
    image
    caption
    color
    institutional_impacts
end

function Base.show(io::IO, scenario::Scenario)
    println(io, "Scenario:")
    println(io, "=========")
    println(io, "N: ", scenario.N)
    !isempty(scenario.external) ? println(io, "External Parameters: ", scenario.external) : nothing
    println(io, "w: ", scenario.w)
    println(io, "q: ", scenario.q)
    println(io, "ē: ", scenario.ē)  # and so on for other fields...
    println(io, "a: ", scenario.a) 
    println(io, "r: ", scenario.r) 
    println(io, "K: ", scenario.K) 
    println(io, "p: ", scenario.p)
    println(io, "w̃: ", scenario.w̃)
    println(io, "ū: ", scenario.ū)
    println(io, "α: ", scenario.α)
    #println(io, "aw̃: ", scenario.aw̃)
    #println(io, "aū: ", scenario.aū)
    if scenario.protected>0.0
    println(io, "protected: ", scenario.protected)
    println(io, "dispersal: ", scenario.dispersal)
    end
    
    println(io, "Institution: ", isempty(scenario.institution) ? "Open access" : scenario.institution)
end


"""
    scenario(;N=100, external=Dict(), ē=SED(min=1.0,max=1.0), q=SED(min=1.0/N,max=1.0/N),
             a=SED(min=1.0,max=1.0), w=SED(min=0.1/N,max=0.9/N), r=1.0, K=1.0, p=1.0,
             w̃=nothing, ū=nothing, α=nothing, institution="OA", β=0.0 (conditional),
             target="effort", value=1.0, ts=0.0, ū0=Array of zeros, y0=1.0, dydt=1.0,
             dt=0.01, label="", image="", caption="", color=nothing, simulate=true)

Simulates a scenario based on various parameters. The function adjusts these parameters and visualizes the outcomes. It is designed to work with a range of inputs, including basic dimensionalized and non-dimensionalized parameters, institutional parameters, and simulation parameters.

# Basic dimensionalized parameters
- `N::Int`: Number of entities or units in the simulation (default: 100).
- `external::NamedTuple`: External parameters provided as a dictionary (default: empty dict).
- `ē::SED`: Basic dimensionalized parameter (default: SED(min=1.0, max=1.0)).
- `q::SED`: Another basic dimensionalized parameter (default: SED(min=1.0/N, max=1.0/N)).
- `a::SED`, representing the efficiency of the technology
- `w::SED`, 
- `r::Float64`, 
- `K::Float64`, 
- `protected::Float64`,
- `dispersal::Float64`,
- `p::Float64`: 

# Basic non-dimensionalized parameters
- `w̃::Union{Float64,Nothing}`, The incentive ratio
- `ū::Union{Float64,Nothing}`, The impact ratio
- `α::Union{Float64,Nothing}`: The rate ratio

- `g::Graph : the directed graph of parameter dependence

# Institutional parameters
- `institution::Institution`: Type of institution (default: []).

# Simulation parameters
- `ts::Float64`, 
- `ū0::Array{Float64,1}`, 
- `y0::Float64`, 
- `dydt::Float64`, 
- `dt::Float64`: Simulation parameters.

# Visualization parameters
- `label::String`, `image::String`, `caption::String`: Visualization parameters (default: empty strings).
- `color::Union{HSL,Colorant,String,Symbol}`: Color for visualization (default: none) converted to.
- `simulate::Bool`: Flag to indicate if simulation should be executed (default: true).

# Returns
- `S`: A `Scenario` object containing the results of the simulation.

# Examples
```julia
scenario_result = scenario(N=200, institution="TQ", simulate=true)
"""

function scenario(;
    # basic dimensionalized parameters
    N::Int=100,
    external=(;),
    ē=sed(min=1.0,max=1.0),
    q=sed(min=1.0,max=1.0,normalize=true),
    a=sed(min=1000.0,max=1000.0),
    w=sed(min=0.1,max=0.9,normalize=true,distribution=Uniform),
    r=1.0,
    K=1.0,
    protected=0.0,
    dispersal=0.0,
    p=sed(min=1.0,max=1.0),
    # basic non-dimensionalized parameters, if set these override dimensionalized parameters
    w̃=sed(distribution=Derived),
    ū=sed(distribution=Derived),
    aw̃=fill(1.0,N),
    aū=fill(1.0,N),
    g=DiGraph(),
    α=sed(distribution=Derived),
    # institutional parameters
    institution=[],
    #simulation parameters
    ts::Float64=0.0,
    ū0::Array{Float64,1}=fill(0.0,N),
    y0::Float64=1.0,
    dydt::Float64=1.0,
    dt::Float64=0.01,
    # visualzaion parameters
    label::String="",
    image::String="",
    caption::String="",
    color::Union{Colorant,Symbol,String,Nothing}=nothing,
    simulate::Bool=true,
    institutional_impacts=[]
)
    # Set default outputs
    t=[];t_u=[];t_U=[];t_y=[];t_ϕ=[];total_revenue=[];resource_revenue=[];wage_revenue=[];trade_revenue=[];gini=0;sim=(;ū0,y0,dt,dydt);u=[];U=0;y=0.0;ϕ=0.0

    color = isa(color, Nothing) ? convert(HSL, colorant"crimson") : isa(color, RGB) ? convert(HSL, color) : isa(color, String) ? convert(HSL, parse(Colorant, color)) : isa(color, Symbol) ? convert(HSL, parse(Colorant, string(color))) : color


    S=Scenario(N,external,w,q,ē,a,r,K,protected,dispersal,p,w̃,ū,aw̃,aū,α,g,u,U,y,ϕ,t,t_u,t_U,t_y,t_ϕ,total_revenue,resource_revenue,wage_revenue,trade_revenue,gini,institution,sim,label,image,caption,color,institutional_impacts)
   dist!(S); sim!(S)
	return S
end


function dist!(s::Scenario)

    # for all dimensional variables, check if they are SED and if so recalculate the distribution
    for key in [:w,:q,:ē,:a,:p,:r,:K]
        if isa(getfield(s,key),SED) 

            dist!(getfield(s,key),s.N) 

        end
    end


    # first check if dimensional variables for w̃ and ū  are defined

    if s.w̃.distribution==Derived
        s.w̃.data=s.w./(s.K.*s.p.*s.q)
    else
        if isa(s.w̃,SED)
            dist!(s.w̃,s.N)
        end
    end

    if s.ū.distribution==Derived
        s.ū.data=s.ē.*s.q./s.r
    else
        if isa(s.ū,SED)
            dist!(s.ū,s.N)
        end
    end

    if s.α.distribution==Derived
        s.α.data=(s.a.*s.p.*s.K.*s.q.^2)./s.r.^2
    else
        if isa(s.α,SED)
            dist!(s.α,s.N)
        end
    end
end





function update(scenario::Scenario; kwargs...)
    # Create a copy of the scenario to avoid mutating the original
    s = deepcopy(scenario)

    s.w̃=nothing
    s.ū=nothing
    s.α=nothing
    # Iterate over each keyword argument and update the corresponding field
    for (key, value) in kwargs
        if hasfield(typeof(s), key)
            setfield!(s, key, value)
        else
            println("Warning: Scenario does not have a field named $key")
        end
    end

    dist!(s.w,s.N)
    dist!(s.q,s.N)
    dist!(s.ē,s.N)
    dist!(s.a,s.N)
    dist!(s.p,s.N)
    dist!(s.w̃,s.N)
    dist!(s.ū,s.N)
    dist!(s.α,s.N)
    dist!(s.r,s.N)
    dist!(s.K,s.N)


    s.w̃==nothing ? s.w̃=sed(data=s.w./(s.K.*s.p.*s.q)) : isa(s.w̃,SED) ? s.w̃=dist!(s.w̃,s.N) : nothing
    s.ū==nothing ? s.ū=sed(data=s.ē.*s.q./s.r) : isa(s.ū,SED) ? s.ū=dist!(s.ū,s.N) : nothing
    s.α==nothing ? s.α=sed(data=(s.a.*s.p.*s.K.*s.q)./s.r) : isa(s.α,SED) ? s.α=dist!(s.α,s.N) : nothing

    # We just need a good recalc method to be able to adjust e.g. PA dependence!

println("older scenario update")
    return s
end

function inputs(s::Scenario)
    println("N: ", s.N)
    isempty(s.external) ? nothing : println("external: ", s.external)
    println("w: ", isa(s.w,Array) ? "["*string(round(maximum(s.w), digits=3))*"..."*string(round(minimum(s.w), digits=3))*"]" : s.w)
    println("q: ", s.q)
    println("ē: ", s.ē)
    println("a: ", s.a)
    println("r: ", s.r)
    println("K: ", s.K)
    println("p: ", s.p)

end

function outputs(::Scenario)
    println("Outputs:")
end

function settings(::Scenario)
    println("Settings:")
end

function randomize!(::Scenario)
    isa(s.w,SED) ? dist!(s.w,s.N) : nothing
    isa(s.ē,SED) ? dist!(s.ē,s.N) : nothing
    isa(s.q,SED) ? dist!(s.q,s.N) : nothing
    isa(s.p,SED) ? dist!(s.p,s.N) : nothing
    isa(s.a,SED) ? dist!(s.a,s.N) : nothing
    isa(s.K,SED) ? dist!(s.K,s.N) : nothing
    isa(s.r,SED) ? dist!(s.r,s.N) : nothing
end
    


function dependencies(external, w, q, ē, a, p, r, K)
    # Initialize the directed graph with no vertices
    g = SimpleDiGraph()
    
    # Create a mapping from variable names to graph vertices
    var_to_vertex = Dict{Symbol, Int}()

    # Helper function to add vertices and dependencies
    function add_dependencies!(g, var_to_vertex, var_name, var)
        # Add vertex for the variable and update the mapping
        var_to_vertex[var_name] = add_vertex!(g)
        if isa(var, SED) && !isempty(var.dependent)
            for dep in var.dependent
                dep_name, _ = dep
                add_edge!(g, var_to_vertex[dep_name], var_to_vertex[var_name])
            end
        end
    end
    
    # Add internal variables first
    for (var_name, var) in zip([:w, :q, :ē, :a, :p, :r, :K], [w, q, ē, a, p, r, K])
        add_dependencies!(g, var_to_vertex, var_name, var)
    end
    
    # Now add external variables
    for (name, var) in external
        add_dependencies!(g, var_to_vertex, name, var)
    end
    
    # Check for cycles which would indicate circular dependencies
    if is_cyclic(g)
        error("Circular dependency detected.")
    end
    
    # Perform topological sort to get an evaluation order
    topological_order = topological_sort_by_dfs(g)

    # Map the vertex numbers back to variable names for readability
    variable_order = []
    for i in topological_order
        variable_name = findfirst(==(i), collect(values(var_to_vertex)))
        if isnothing(variable_name)
            continue  # or handle the error according to your requirements
        end
        push!(variable_order, collect(keys(var_to_vertex))[variable_name])
    end
    
    return variable_order
end

function scenario(
    original::Scenario;
    N=nothing,
    external=nothing,
    w=nothing,
    q=nothing,
    ē=nothing,
    a=nothing,
    r=nothing,
    K=nothing,
    protected=nothing,
    dispersal=nothing,
    p=nothing,
    w̃=nothing,
    ū=nothing,
    aw̃=nothing,
    aū=nothing,
    α=nothing,
    u=nothing,
    U=nothing,
    y=nothing,
    ϕ=nothing,
    t=nothing,
    t_u=nothing,
    t_U=nothing,
    t_y=nothing,
    t_ϕ=nothing,
    total_revenue=nothing,
    resource_revenue=nothing,
    wage_revenue=nothing,
    trade_revenue=nothing,
    gini=nothing,
    institution=nothing,
    target=nothing,
    value=nothing,
    β=nothing,
    sim=nothing,
    label=nothing,
    image=nothing,
    caption=nothing,
    color=nothing
)

    # Create a new copy of the original scenario
    updated = deepcopy(original)
    # Update fields if a new value is provided (not nothing)
    N !== nothing && (updated.N = N)
    external !== nothing && (updated.external = external)
    w !== nothing && (updated.w = w)
    q !== nothing && (updated.q = q)
    ē !== nothing && (updated.ē = ē)
    a !== nothing && (updated.a = a)
    r !== nothing && (updated.r = r)
    K !== nothing && (updated.K = K)
    protected !== nothing && (updated.protected = protected)
    dispersal !== nothing && (updated.dispersal = dispersal)
    p !== nothing && (updated.p = p)
    w̃ !== nothing && (updated.w̃ = w̃)
    ū !== nothing && (updated.ū = ū)
    aw̃ !== nothing && (updated.aw̃ = aw̃)
    aū !== nothing && (updated.aū = aū)
    α !== nothing && (updated.α = α)
    u !== nothing && (updated.u = u)
    U !== nothing && (updated.U = U)
    y !== nothing && (updated.y = y)
    ϕ !== nothing && (updated.ϕ = ϕ)
    t !== nothing && (updated.t = t)
    t_u !== nothing && (updated.t_u = t_u)
    t_U !== nothing && (updated.t_U = t_U)
    t_y !== nothing && (updated.t_y = t_y)
    t_ϕ !== nothing && (updated.t_ϕ = t_ϕ)
    total_revenue !== nothing && (updated.total_revenue = total_revenue)
    resource_revenue !== nothing && (updated.resource_revenue = resource_revenue)
    wage_revenue !== nothing && (updated.wage_revenue = wage_revenue)
    trade_revenue !== nothing && (updated.trade_revenue = trade_revenue)
    gini !== nothing && (updated.gini = gini)
    institution !== nothing && (updated.institution = institution)
    target !== nothing && (updated.target = target)
    value !== nothing && (updated.value = value)
    β !== nothing && (updated.β = β)
    sim !== nothing && (updated.sim = sim)
    label !== nothing && (updated.label = label)
    image !== nothing && (updated.image = image)
    caption !== nothing && (updated.caption = caption)
    color !== nothing && (updated.color = color)

    dist!(updated.w,updated.N)
    dist!(updated.q,updated.N)
    dist!(updated.ē,updated.N)
    dist!(updated.a,updated.N)
    dist!(updated.p,updated.N)
    dist!(updated.r,updated.N)
    dist!(updated.K,updated.N)
    dist!(updated.w̃,updated.N)
    dist!(updated.ū,updated.N)
    dist!(updated.α,updated.N)


    return updated
end

