

abstract type Institution end

abstract type DynamicInstitution <: Institution end
abstract type StaticInstitution <: Institution end
abstract type LimitInstitution <: Institution end

function dynamic_institution(institution::DynamicInstitution,du,u,s,t)
    institution.fun(institution,du,u,s,t)
end


function dynamic_institution(institution::Union{LimitInstitution,StaticInstitution},du,u,s,t)
    return
end

function limit_institution(institution::LimitInstitution,s,integrator)

    institution.fun(institution, integrator.du,view(integrator.u,1:s.N),s, integrator.t)
end

function limit_institution(institution::Union{DynamicInstitution,StaticInstitution},s,integrator)
    return
end

function static_institution(institution::StaticInstitution,s)
    institution.fun(institution,s)
end

function static_institution(institution::Union{LimitInstitution,DynamicInstitution},s)
    return
end


function Base.show(io::IO, inst::Institution)
    typename = typeof(inst)
    fields = fieldnames(typename)
    println(io, "$(typename):")
    for field in fields
        value = getfield(inst, field)
        fieldtype = typeof(value)
        if value isa Function
            func_name = String(nameof(fieldtype))[2:end]
            println(io, "  $(field) (Function): $func_name")
        else
            println(io, "  $(field) ($(fieldtype)): $value")
        end
    end
end
