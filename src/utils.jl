
function gini(x)
    sum([abs(x[i]-x[j]) for i in 1:length(x), j in 1:length(x)])/(2*length(x)*sum(x))
end

#=
function analytical(p)
    Y=range(0.0,stop=max(1.0,maximum(p.w̃))	,length=1000)
    us=sum.(u_sust.(Y,Ref(p)))/p.N
    ur=sum.(u_real.(Y,Ref(p)))/p.N
    return (us,ur,Y)
end


function u_sust(y,p)
    id=sortperm(p.w̃)
    cu=cumsum(p.ū[id])
    f=sum(cu.<(1.0-y))
    if f==0
        f=(1.0-y)/p.ū[id[1]]
    elseif f<p.N
        f=f+((1-y)-cu[f])/p.ū[id[f+1]]
    end
    return f
end

function u_real(y,p)
    id=sortperm(p.w̃) # if w_bar's are not in ascending order
    f=sum(p.w̃[id].<y) # how many are participating
    return f
end
=#
function analytical(p)
    w̃ = p.w̃ .* p.aw̃
    ū = p.ū .* p.aū

    Y = range(0.0, stop = max(1.0, maximum(w̃)), length = 1000)
    us = sum.(u_sust.(Y, Ref(p))) / p.N
    ur = sum.(u_real.(Y, Ref(p))) / p.N
    return (us, ur, Y)
end

function u_sust(y, p)
    w̃ = p.w̃ .* p.aw̃
    ū = p.ū .* p.aū

    id = sortperm(w̃)
    cu = cumsum(ū[id])
    f = sum(cu .< (1.0 - y))
    if f == 0
        f = (1.0 - y) / ū[id[1]]
    elseif f < p.N
        f = f + ((1 - y) - cu[f]) / ū[id[f + 1]]
    end
    return f
end

function u_real(y, p)
    w̃ = p.w̃ .* p.aw̃

    id = sortperm(w̃) # if w_bar's are not in ascending order
    f = sum(w̃[id] .< y) # how many are participating
    return f
end

	


function adjustColor(C,f,v)
    h=C.h
    s=C.s
    l=C.l
    f=="h" ? h=v : nothing
    f=="s" ? s=v : nothing
    f=="l" ? l=v : nothing
    return HSL(h,s,l)
end





function institutional_impact!(S;M=100, inst=1)
    !isa(S,Array) ? S=[S] : nothing
    for q in S
        s=deepcopy(q)
        total::Array{Float64}=[]
        resource::Array{Float64}=[]
        gini::Array{Float64}=[]
        I::Array{Float64}=[]
        y::Array{Float64}=[]
        t=range(0.0,stop=1.0,length=M)
        told=s.institution[inst].value
        U=zeros(s.N,M)
        for i in 1:M
            s.institution[inst].value=t[i]
            sim!(s)
            
            push!(total,sum(s.total_revenue))
            push!(resource,sum(s.resource_revenue))
            push!(gini,s.gini)
            push!(y,s.y)
            U[:,i]=s.resource_revenue
            s.institution[inst].value=0
            du=zeros(s.N+3)
            dudt(du,vcat(s.u,s.y,0.0,s.ϕ),s,0.0)
            push!(I,sum(max.(0.0,du[1:s.N])))
        end
        s.institution[inst].value=told
        #id_total=t[argmax(total)],id_resource=t[argmax(resource)],id_ginnig=t[argmin(gini)],
        push!(q.institutional_impacts,(target=collect(t),id_total=t[argmax(total)],id_resource=t[argmax(resource)],id_gini=t[argmin(gini)],id_y=t[argmin((y.-0.5).^2)],total=total,resource=resource,gini=gini,I=I,y=y,U=U, institution=string(typeof(S[1].institution[1]))[25:end]*" "*string((hasfield(typeof(S[1].institution[1]),:target) ? S[1].institution[1].target : ""))))
    end 
end
