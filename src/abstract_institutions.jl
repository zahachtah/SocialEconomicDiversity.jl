

abstract type Institution end

abstract type dynamicInstitution <: Institution end
abstract type staticInstitution <: Institution end
abstract type limitInstitution <: Institution end

function dynamic_institution(institution::dynamicInstitution,du,u,s,t)
    
    institution.fun(institution,du,u,s,t)
end


function dynamic_institution(institution::Union{limitInstitution,staticInstitution},du,u,s,t)
    return
end

function limit_institution(institution::limitInstitution,s,integrator)

    institution.fun(institution, integrator.du,integrator.u,s, integrator.t)
end

function limit_institution(institution::Union{dynamicInstitution,staticInstitution},s,integrator)
    return
end

function static_institution(institution::staticInstitution,s)
    institution.fun(institution,s)
end

function static_institution(institution::Union{limitInstitution,dynamicInstitution},s)
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
