"""
    phaseplot!(A, S; show_sustained=true, show_potential=true, same_potential_color=true, 
                show_realized=nothing, show_trajectory=false, regulated_dot_reduction=0.3, 
                attractor_size=30, show_attractor=true, show_target=true, vector_field=false, 
                vector_grid=20, show_vertical_potential=false, attractor_color=nothing, 
                show_legend=nothing, attractor_to_legend=false, show_exploitation=true, 
                indicate_incentives=false)

Plot the phase diagram for the given system.

# Arguments
- `A`: The axis or plot object to draw on.
- `S`: The system or set of systems to plot. Can be a single system or an array of systems.
- `show_sustained::Bool`: Whether to show sustained potential lines. Default is `true`.
- `show_potential::Bool`: Whether to show potential lines. Default is `true`.
- `same_potential_color::Bool`: Whether to use the same color for potential lines. Default is `true`.
- `show_realized`: Whether to show realized potential. Default is `nothing`.
- `show_trajectory::Bool`: Whether to show the trajectory of the system. Default is `false`.
- `regulated_dot_reduction::Float64`: Reduction factor for regulated dots. Default is `0.3`.
- `attractor_size::Int`: Size of attractor points. Default is `30`.
- `show_attractor::Bool`: Whether to show attractor points. Default is `true`.
- `show_target::Bool`: Whether to show target lines. Default is `true`.
- `vector_field::Bool`: Whether to show the vector field. Default is `false`.
- `vector_grid::Int`: The resolution of the vector grid. Default is `20`.
- `show_vertical_potential::Bool`: Whether to show vertical potential lines. Default is `false`.
- `attractor_color`: Color for attractor points. Default is `nothing`.
- `show_legend`: Whether to show the legend. Default is `nothing`.
- `attractor_to_legend::Bool`: Whether to add attractors to the legend. Default is `false`.
- `show_exploitation::Bool`: Whether to show exploitation areas. Default is `true`.
- `indicate_incentives`: How to indicate incentives. Default is `false`.

# Description
This function plots the phase diagram of the given system or set of systems, including options to show sustained potential, trajectory, vector field, and more. It supports various customization options for colors, sizes, and legend display.

# Example
```julia
axis = Axis()
s = scenario()  
phaseplot!(axis, s, show_trajectory=true, vector_field=true)
```
"""
function phaseplot!(
    A, S; show_sustained=true, show_potential=true, same_potential_color=true, show_realized=nothing,
    show_trajectory=false, regulated_dot_reduction=0.3, attractor_size=30, show_attractor=true, 
    show_target=true, vector_field=false, vector_grid=20, show_vertical_potential=false, 
    attractor_color=nothing, show_legend=nothing, attractor_to_legend=false, show_exploitation=true, 
    indicate_incentives=false
)

    S = isa(S, Array) ? S : [S]

    for s in S
        w̃, ū = s.w̃ .* s.aw̃, s.ū .* s.aū

        function get_deriv_vector(y, u, z)
            du = zeros(z.N + 3)
            usum = cumsum(z.ū .* z.aū)
            Q = findall(usum.<=u)
            n = length(Q)
            U = zeros(z.N + 3)

            deltau = length(Q) > 0 ? usum[min(z.N, Q[end] + 1)] - u : 0
            if length(Q) > 0 U[Q] = z.ū[Q] end
            U[min(z.N, n + 1)] = deltau
            U[z.N + 1] = y
            dudt(du, U, z, 0)
            radian_angle = atan(sum(du[1:z.N]), du[z.N + 1])

            radian_angle - pi/2, hypot(sum(du[1:z.N]), du[z.N + 1])
        end

        if show_exploitation
            poly!(A, Rect(0, 0, 0.5, 1), color=HSLA(10, 0.5, 0.5, 0.1))
            poly!(A, Rect(0.5, 0, 0.5, 1), color=HSLA(180, 0.5, 0.5, 0.1))
        end

        c = s.color
        scatter!(A, [s.y], [s.U], color=attractor_color === nothing ? HSLA(c.h, c.s, c.l, 0.3) : attractor_color, 
                 markersize=show_attractor ? attractor_size : 0, strokecolor=:transparent, strokewidth=0)

        if vector_field
            points = [Point2f(x / (vector_grid + 1), y / (vector_grid + 1)) for y in 1:vector_grid for x in 1:vector_grid]
            rotations = [get_deriv_vector(p[1], p[2], s)[1] for p in points]
            markersizeVector = [(get_deriv_vector(p[1], p[2], s)[2] * 20)^0.2 * 15 for p in points]

            scatter!(A, points, rotation=rotations, markersize=markersizeVector * 0.7, marker='|', color=adjustColor(c, "l", 0.4))
            scatter!(A, points, rotation=rotations, markersize=4, color=:black)
        end

        us, ur, y = analytical(s)

        if show_target && !isempty(s.institution)
            
            if hasfield(typeof(s.institution[1]), :target)
                target, value = s.institution[1].target, s.institution[1].value
                up=us[findall(y.<=(1-value))[end]]
                if target == :yield
                    lines!(A, y, up ./ y, color=:black, linewidth=0.5, linestyle=:dash)
                elseif target == :effort
                    lines!(A, y, fill(up, length(y)), color=:black, linewidth=0.5, linestyle=:dash)
                end
            else
                lines!(A, y, fill(mean(s.institution[1].value), length(y)), color=:black, linewidth=0.5, linestyle=:dash)
            end
        end

        if show_trajectory
            lines!(A, s.t_y, s.t_U, color=c, linewidth=1, linestyle=:dash, label="Trajectory")
            scatter!(A, [s.y], [s.U], color=:black, markersize=show_attractor ? 8 : 0, strokecolor=:transparent, strokewidth=0)
        end

        if show_potential
            potential_color = same_potential_color ? c : :gray
            lines!(A, y, ur, color=potential_color, linewidth=10 * 0.2)
            if show_vertical_potential
                lines!(A, y, ur, color=potential_color, linewidth=10 * 0.2, label="P(y)")
            end
        end

        if show_realized === true
            realized_color = typeof(indicate_incentives) == Symbol ? getproperty(s, indicate_incentives) : c
            scatter!(A, w̃, cumsum(s.u ./ ū) / s.N, color=realized_color, markersize=10, label="R(y)")
        end

        if show_sustained
            lines!(A, y, us, linewidth=0.5, color=same_potential_color ? c : :gray, label="S(y)")
        end
    end

    ylims!(A, (-0.02, 1.02))
    xlims!(A, (0, 1))
    if show_legend !== nothing
        axislegend(A, framevisible=false, position=show_legend)
    end
end


function phaseplot_old!(A,S; show_sustained=true,show_potential=true,same_potential_color=true, show_realized=nothing,show_trajectory=false, regulated_dot_reduction=0.3, attractor_size=30, show_attractor=true,show_target=true, vector_field=false,vector_grid=20,show_vertical_potential=false, attractor_color=nothing, show_legend=nothing, attractor_to_legend=false, show_exploitation=true, indicate_incentives=false)

    if !isa(S,Array)
        S=[S];
    end

    for s in S
        w̃ = s.w̃.* s.aw̃
        ū = s.ū.* s.aū
        
        function get_deriv_vector(y,u,z)
            du=zeros(z.N+3)
            usum=cumsum(z.ū.*z.aū)
            Q=findall(usum.<=u)
            n=length(Q)
            U=zeros(z.N+3)

            deltau=length(Q)>0 ? usum[min(z.N,Q[end]+1)]-u : 0
            length(Q)>0 ? U[Q]=z.ū[Q] : nothing
            U[min(z.N,n+1)]=deltau
            U[z.N+1]=y
            dudt(du,U,z,0)
            radian_angle = atan(sum(du[1:z.N]),du[z.N+1])

            radian_angle-pi/2,sqrt(sum(du[1:z.N])^2+du[z.N+1]^2)
        end

        if show_exploitation
            poly!(A, Rect(0, 0, 0.5,1), color=HSLA(10, 0.5, 0.5,0.1))
            poly!(A, Rect(0.5, 0, 0.5,1), color=HSLA(180, 0.5, 0.5,0.1))
        end

        p=s;
        c=p.color
        MS=10
        id=sortperm(w̃)
        scatter!(A,[s.y],[s.U],color=attractor_color==nothing ? HSLA(c.h,c.s,c.l,0.3) : attractor_color,markersize=show_attractor ? attractor_size : 0,strokecolor=:transparent,strokewidth=0,rotations=pi)
        
        if vector_field
            points = [Point2f(x/(vector_grid+1), y/(vector_grid+1)) for y in 1:vector_grid for x in 1:vector_grid]
            rotations = [get_deriv_vector(p[1],p[2],s)[1] for p in points]
            markersizeVector = [(get_deriv_vector(p[1],p[2],s)[2]*20)^0.2*15 for p in points]

            scatter!(A,points, rotations = rotations, markersize = markersizeVector*0.7, marker = '|', color=adjustColor(c,"l",0.4))
            scatter!(A,points, rotations = rotations, markersize = 4, color=:black)
        end

        (us,ur,y)=analytical(s)

        if !isempty(s.institution)
            if hasfield(typeof(s.institution[1]),:target)
                if s.institution[1].target==:yield && show_target
                    lines!(A,y,s.institution[1].value./y, color=:black, linewidth=0.5, linestyle=:dash)
                elseif s.institution[1].target==:effort && show_target
                    lines!(A,y,fill(mean(s.institution[1].value),length(y)), color=:black, linewidth=0.5, linestyle=:dash)
                end
            end
        end

        # Trajectory plot
        show_trajectory ? lines!(A,s.t_y,s.t_U,color=c, linewidth=1,linestyle=:dash, label="Trajectory") : nothing

        institutional_impact=(s.y.-w̃ .>0 .&& ū.-s.u.>1e-5).*MS*regulated_dot_reduction
        institutional_not_profitable=(s.y.-w̃ .<0 ).*MS*1.11
        open_access_not_profitable=(s.y.-w̃[id] .<0 ).*MS

        optoutvector=[w̃[i]>s.y ? s.u[i] : s.u[i] for i in eachindex(w̃[id])] #for non-flattened curve: s.final.p.ū[i]

        if show_potential 
            potential=lines!(A,y,ur,color=same_potential_color ? c : :gray, linewidth=MS*0.2,markersize=MS.*0.3)
            show_vertical_potential ? lines!(A,y,ur,color=same_potential_color ? c : :gray, linewidth=MS.*0.2,label="P(y)") : nothing
        end

        if show_realized==true
            inst=MarkerElement(marker = :circle, color = :black,strokecolor = c,strokewidth=1,markersize = MS)

            # Shows actors that opt out of resource use 
            # scatter!(A,w̃[id],cumsum(x.u[id]./x.ū[id])/x.N,color=adjustColor(c,"l",0.15), markersize=open_access_not_profitable.*0.3)
            
            realized=scatter!(A,w̃[id],cumsum(s.u[id]./ū[id])/s.N,color=typeof(indicate_incentives)==Symbol ? getproperty(s, indicate_incentives) : c, markersize=MS,label="R(y)")
            
            # optout=scatter!(A,w̃[id],cumsum(optoutvector./ū)./s.N,color=adjustColor(c,"l",0.85), markersize=institutional_not_profitable)
            
            # scatter!(A,w̃[id],cumsum(s.u./ū)./s.N, color=:black,markersize=institutional_impact)
        end
        
        show_trajectory ? scatter!(A,[s.y],[s.U],color=:black,markersize=show_attractor ? 8 : 0,strokecolor=:transparent,strokewidth=0,rotations=pi) : nothing
        # scatter!(A,[s.y],[s.U],color=:transparent,markersize=show_attractor ? attractor_size : 0,strokecolor=c,strokewidth=2,rotations=pi)

        show_sustained ? sustained=lines!(A,y,us,linewidth=0.5,markersize=0.5,color=same_potential_color ? c : :gray,label="S(y)") : nothing
    end
    ylims!(A,(-0.02,1.02))
    xlims!(A,(0,1))
    show_legend!=nothing ? axislegend(A,framevisible = false,position=show_legend) : nothing
end


	"""
	    SEDplot(a, s, v1, v2; show_density=false, sort=true, markersize=5, labels=true, icons=false, icon_size=30)
	
	Plot a Scatter or Density Enhanced plot for given attributes of a data structure.
	
	# Arguments
	- `a`: the axis or plot object to draw on.
	- `s`: a data structure containing the data and settings for the plot.
	- `v1`: the first variable or attribute to plot. Can be a `Symbol` or `String`.
	- `v2`: the second variable or attribute to plot. Can be a `Symbol` or `String` or special value like `:cumsum` to represent cumulative sum.
	- `show_density`: if `true`, shows a density plot for `v1`; otherwise, shows a scatter plot.
	- `sort`: if `true`, the data points are sorted based on `v1`.
	- `markersize`: size of the markers in the scatter plot.
	- `labels`: if `true`, adds labels to the x and y axes.
	- `icons`: if `true`, adds icons to the plot.
	- `icon_size`: size of the icons if `icons` is `true`.
	
	# Returns
	- The plot object `L` (can be `nothing` if `show_density` is `true`).
	"""
	function SEDplot!(a, S, v1, v2; show_density=false, sort=true, markersize=5, labels=true, icons=false, icon_size=30, color=nothing, show_cor=true)
	    # Ensure v1 and v2 are Symbols
		v1 = isa(v1, String) ? Symbol(v1) : v1
		v2 = isa(v2, String) ? Symbol(v2) : v2
		S = isa(S,Array) ? S : [S]
		L=[]
	    for s in S

			# NOTE NOTE NOTE !!!!
			# TO ALLOW PLOTTING AGAINST EXTERNAL VARIABLES:
			# one could have s1 and s2 here and assign s1=s if v1 in internal variables and s1=s.external if v1 in external variables!
			# NOTE NOTE NOTE !!!!

		    # Obtain the color from the data structure
		    plot_color = s.color
		    
		    # Sort indices if needed
		    indices = (sort && v1!=:id) ? sortperm(getfield(s, v1)) : 1:getfield(s, :N)
		    
		    # Initialize the object used for creating legend for this plot
		    L = nothing

		    if show_density
				
				# !!! USE ACTUAL DISTRIBUTION WHEN AVAILABLE! !!!!
		        # Perform kernel density estimation on the sorted data
		        data_for_kde = getfield(s, v1)[indices]
		        density_estimation = kde(data_for_kde, boundary=extrema(data_for_kde)) 
		        kde_indices = findall(density_estimation.x .> 0)
		        
		        # Plot the density estimation
		        band!(a, density_estimation.x[kde_indices], density_estimation.x[kde_indices] .* 0, density_estimation.density[kde_indices], color=(plot_color, 0.5))
		        lines!(a, density_estimation.x[kde_indices], density_estimation.density[kde_indices], color=plot_color, linewidth=1)
		    else

		        # Scatter plot
		        if v2 == cumsum

		            # Special case for cumulative sum
		            cumulative_data = collect(1:s.N) ./ s.N
					v=getfield(s, v1)
					id=sortperm(v)
		            l = scatter!(a, v1 != :id ? v.data[id] :  1:length(v), cumulative_data, color= color==nothing ? plot_color : color; markersize)
		        else
		            # General case for scatter plot
		            l = scatter!(a, v1 != :id ? getfield(s, v1) :  1:length(getfield(s, v2)), getfield(s, v2), color= color==nothing ? plot_color : color; markersize)
		        end
		    end
		    
		    # Add labels if specified
			 if labels
			    a.xlabel = string(v1)
			    a.ylabel = string(v2)
			end
		
		    
		    # Add icons if specified
		    if icons
		        y_icon = load("graphics/" * string(v2) * ".png")
		        scatter!(a, 0.1, 0.9, marker=y_icon, markersize=icon_size, space=:relative)
		        
		        x_icon = load("graphics/" * string(v1) * ".png")
		        scatter!(a, 0.88, 0.15, marker=x_icon, markersize=icon_size, space=:relative)
		    end
			#push!(L,l) fix for Legend
		end
	    return L
end

function individual_u!(a,S;labels=true,rot=false)
	# divide by S.ū
	id=sortperm(S.w̃)
	if rot
		heatmap!(a,S.w̃[id],S.t,rotl90(S.t_u[:,reverse(id)]),colormap=cgrad([:white,S.color]))
		!labels ? hidedecorations!(a) : nothing
	else
        heatmap!(a,S.t,S.w̃[id],S.t_u[:,id],colormap=cgrad([:white,S.color]))
        !labels ? hidedecorations!(a) : nothing
	end
	hidespines!(a)
end

function incomes!(
    a, z;
    fix_xlim=true,
    indexed=true,
    show_w̃=true,
    show_text=true,
    annotation_size=12,
    densityplot=false,
	wage_indicator=false,
	text_color=:black,
	anntext="",
	texty=nothing
    )
    c = z.color
    cw = HSL(c.h, c.s, 0.8)
	c=HSL(c.h, c.s, 0.45)
    mw = (z.w̃[end] - z.w̃[1]) / z.N

    if z.w̃[1] == z.w̃[end]
        mw = z.w̃[end] / 5
    end

    indexed==true ? nothing : fix_xlim ? xlims!(a, [0, 1]) : xlims!(a, [z.w̃[1], z.w̃[end]])

    #hideydecorations!(a)
    #hidespines!(a)

    id = indexed==true ? collect(1:z.N) : sortperm(getfield(z,indexed))
    if densityplot
        pred = kde(z.total_revenue[id])
        band!(a, pred.x, pred.x .* 0, pred.density, color=(c, 0.5))
        lines!(a, kde(z.total_revenue[id]), color=c)
    else
        barplot!(a, indexed==true ? collect(1:z.N) : z.w̃, z.total_revenue[id], color=c, width=indexed==true ? 1 : mw, offset=z.trade_revenue[id])
        barplot!(a, indexed==true ? collect(1:z.N) : z.w̃, z.wage_revenue[id], color=cw, width=indexed==true ? 1 : mw, offset=z.trade_revenue[id] + z.resource_revenue[id])
        barplot!(a, indexed==true ? collect(1:z.N) : z.w̃, abs.(z.trade_revenue[id]), color=HSLA(0,0,0.8,0.5), width=indexed==true ? 1 : mw, offset=min.(0.0,z.trade_revenue[id]))
    end

    mi = minimum(z.trade_revenue[id] + z.resource_revenue[id])
    ma = maximum(z.total_revenue[id])
# ylims!(a, (mi - 2 * (ma - mi) / 20, ma)) 

    cmap = cgrad(colorschemes[:rainbow2], z.N, categorical=true)
	if wage_indicator
		for i in 1:z.N
			poly!(a, Rect(i - 0.5, mi - (ma - mi) / 40, 1, -(ma - mi) / 40), color=cmap[i])
		end
	end
	#barplot!(a,collect(1:z.N),z.total_revenue[id],color=c, width=mw)
    if show_text
		incometext=anntext*"\nT:" * string(round(sum(z.total_revenue), digits=2)) * " R:" * string(round(sum(z.resource_revenue), digits=2)) * " G:" * string(round(gini(z.total_revenue), digits=2))
        a.title=incometext
		a.titlesize=annotation_size
		#a.titlefont="Arial"
		a.titlegap=1
		a.titlefont=:regular
		#text!(a,0.09,1.0, space=:relative, text=incometext, font="Arial", align=(:left, :top), color=text_color, fontsize=annotation_size)
		#text!(a, 0.09, maximum(z.total_revenue) * 0.8, text="Gini: " * string(round(gini(z.total_revenue), digits=2)), font="Arial", align=(:left, :top), color=text_color, fontsize=annotation_size)
        #text!(a, 0.09, maximum(z.total_revenue), text="Total: " * string(round(sum(z.total_revenue), digits=2)), font="Arial", align=(:left, :top), color=text_color, fontsize=annotation_size)
        #text!(a, 0.09, maximum(z.total_revenue) * 0.9, text="Resource: " * string(round(sum(z.resource_revenue), digits=2)), font="Arial", align=(:left, :top), color=text_color, fontsize=annotation_size)
    end
end


function dependencies(s)

	function midpoint(p1::Point2{Float64}, p2::Point2{Float64})
		println(p1,p2)
		return Point2((p1[1] + p2[1]) / 2, (p1[2] + p2[2]) / 2)
	end
	
	# Function to calculate the angle between two points
	function angle(p1::Point2{Float64}, p2::Point2{Float64})
		return atan(p2[2] - p1[2], p2[1] - p1[1])
	end
	M=Dict()
	I=[:w,:q,:ē,:a,:p,:r,:K]
	E=collect(keys(s.external))
	g=DiGraph()
	for (i,k) in enumerate(vcat(I,E))
		if k in E
			add_vertex!(g)
			M[k]=i
			M[i]=k
		else
			if isa(getfield(s,k),SED)
				if !isempty(getfield(s,k).dependent)
					add_vertex!(g)
					M[k]=i
					M[i]=k
				end 
			end
		end
	end
	for i in I
		if isa(getfield(s,i),SED) 
			N= keys(getfield(s,i).dependent)
			for n in N
				
				add_edge!(g, M[n], M[i])

			end
		end
	end
	
	layout =Spring(C=10.0; iterations=200)#SFDP(Ptype=Float64, tol=0.01, C=0.2, K=0.01)#Spring(; iterations=200)# SFDP(Ptype=Float32, tol=0.01, C=0.2, K=1)#Spring(; iterations=200)#SFDP(Ptype=Float32, tol=0.01, C=0.2, K=1)#Spring(; iterations=200)#Buchheim()#Spring(; iterations=200)#Buchheim()#Spring(; iterations=20)
    pos = layout(g)
	
    f=Figure()
    a=Axis(f[1,1], aspect=1)
    for p in edges(g)
        lines!(a,[pos[p.src][1],pos[p.dst][1]],[pos[p.src][2],pos[p.dst][2]], color=:gray)
        scatter!(a,midpoint(pos[p.src],pos[p.dst]),marker=:utriangle,markersize=10,rotations=angle(pos[p.src],pos[p.dst])-pi/2,color=:gray)
    end

    scatter!(a,pos, markersize=30, strokewidth=5, strokecolor=:white,color=:crimson)

    hidespines!(a)
    hidedecorations!(a)
    f
end

function plot_institutional_impact(o,s;weight=[1,1,1,1,1])
    weight=round.(weight, digits=4)
    w=o.resource.^weight[1].*o.total.^weight[2].*o.gini.^weight[3].*o.I.^weight[4].*o.y.^weight[5]
    w=round.(w,digits=4)
    opt=findall(w.==w[argmax(w)])[end]
    f=Figure(size=(800,700))
    t="hello"
    a=CairoMakie.Axis(f[1,1:2], xticks=([],[]),yticks=([],[]),ylabel="normalized")
    a2=CairoMakie.Axis(f[2,1:2], xticks=([],[]),yticks=([],[]),titlesize=20,ylabel="utility u(i)",title=L"$u_G(i)=R^{%$(weight[1])} T^{%$(weight[2])} G^{%$(weight[3])} I^{%$(weight[4])} Y^{%$(weight[5])}$")#L"Weighted goal function: $u(i)=R(i)^{%(string(wheight[1]))} $T"*string(wheight[2])*" G"*string(wheight[3])*" I"*string(wheight[4])*" Y"*string(wheight[5]))
    a3=CairoMakie.Axis(f[3,1:2],xticks = ([10,90], ["Full Regulation", "Open Access"]),yticks = ([10,90], ["Low", "High"]),ylabel="alternative opportunities")
    a4=CairoMakie.Axis(f[2,3])
    l2=lines!(a,o.target,o.total./maximum(o.total),label="Total Revenue", linewidth=3)
    l1=lines!(a,o.target,o.resource./maximum(o.resource),label="Resource Revenue", linewidth=3)
    l3=lines!(a,o.target,o.gini./maximum(o.gini),label="Gini", linewidth=3)
    #l4=lines!(a,o.target,(o.I.-minimum(o.I))./maximum(o.I.-minimum(o.I)),label="Institutional Impact", linewidth=3)
    l5=lines!(a,o.target,o.y/maximum(o.y),label="Stock", linewidth=3)
    ylims!(a,(-1,1))
    lines!(a,[o.target[opt],o.target[opt]],[0,1],color=:darkorange,linestyle=:dash)
    Legend(f[1,3],[l1,l2,l3,l5],["Resource Revenue","Total Revenue","Gini","Stock"],"Governance aspects",tellwidth=false,orientation = :vertical, halign=:left)
   
    lines!(a2,o.target,w./maximum(w),color=:darkorange, linewidth=3)
    lines!(a2,[o.target[opt],o.target[opt]],[0,1],color=:darkorange,linestyle=:dash)
    heatmap!(a3,o.U', colormap=:BuGn)
    Colorbar(f[3, 3], limits = (0, maximum(o.U)),label="Resource income", colormap = :BuGn,
    flipaxis = true, tellwidth=false, halign=:left)
    lines!(a3,[opt,opt],[0,100],color=:darkorange,linestyle=:dash)
    S=deepcopy(s)
    S.institution[1].value=o.target[opt]
    S.color=convert(HSL,colorant"darkorange")
    sim!(S);
    phaseplot!(a4,S,show_realized=true)
    S.institution[1].value=1.0
    S.color=convert(HSL,colorant"gray")
    sim!(S);
    phaseplot!(a4,S,show_realized=true)
    return f
end

function plot_incentive_shift(;steps=100,N=100,rn=false, distribution=Uniform, plotit=false)
	wmin=0.05*10
	wmax=0.10*10
	qmin=0.01*20
	qmax=0.2*20
	U=zeros(N,steps)
	S=zeros(steps)
	T=zeros(steps)
	R=zeros(steps)
	G=zeros(steps)
	
	for (i, v) in enumerate(range(qmin, stop=qmax, length=steps))
		sw=(wmax-wmin)/N
		iw=wmin-sw
		sq=((qmax-v)-v)/N
		iq=v-sq
	
		s=scenario(;N,w=SED(min=wmin,max=wmax, normalize=true, random=rn, distribution=distribution),q=SED(min=v,max=qmax-v,normalize=true, random=rn,),ē=1.0,r=1.0,K=1.0,p=5.0)
		dist!(s)
		sim!(s, tend=(0.0,20000))
		id=sortperm(s.w̃)
		U[:,i]=s.u#[id]
		
		T[i]=sum(s.total_revenue)
		R[i]=sum(s.resource_revenue)
		G[i]=s.gini
		A=diff(s.w).*s.q[1:(end-1)].-diff(s.q).*s.w[1:(end-1)]
		S[i]=median(A)
		if plotit==true
		f=Figure()
		a1=CairoMakie.Axis(f[1,1],title="$(round(sq*iw-sw*iq,digits=5)) ")   #q=qmin=$(round(v,digits=3)), qmax=$(round((qmax-v),digits=3))")
		a2=CairoMakie.Axis(f[1,2])
		a3=CairoMakie.Axis(f[2,2])
		a4=CairoMakie.Axis(f[3,1])
		a5=CairoMakie.Axis(f[2,1], ylabel=L"$f^'_w f_q - f^'_q f_w$")
		ylims!(a1,(0.0,qmax/N))
		#ylims!(a4,(0.0,1.0))
			
			lines!(a5,[1,length(A)],[0,0],color=:gray)
			
		scatter!(a5,A, color=[a>=0.0 ? :green : :red for a in A], markersize=4)
		
		hideydecorations!(a5, label=false)
		hidespines!(a5)
		SEDplot!(a1,s,:id,:w)
		SEDplot!(a1,s,:id,:q, color=:steelblue)
		SEDplot!(a4,s,:id,:w̃)
		SEDplot!(a4,s,:id,:ū, color=:steelblue)
		phaseplot!(a2,s, show_exploitation=false)
		incomes!(a3,s)
		display(f)
		end
	
	end
	ff=Figure()
	aa=CairoMakie.Axis(ff[1,1], ylabel="Actor id",title="Incentive shift of resource use, distribution: "*string(distribution))
	aa2=CairoMakie.Axis(ff[2,1], ylabel="Revenue & Gini", xlabel=L"average $f^'_w f_q - f^'_q f_w$")
	linkxaxes!(aa, aa2)
	hidexdecorations!(aa)
	heatmap!(aa,S,1:N,U',colormap=:BuGn)
	l1=lines!(aa2,S,T, label="Total Revenue", color=:blue)
	l2=lines!(aa2,S,R, label="Resource Revenue", color=:red)
	l3=lines!(aa2,S,G, label="Gini", color=:green)
	Legend(ff[3,1],[l1,l2,l3],["Total Revenue","Resource Revenue","Gini"],orientation=:horizontal)
	
	save("graphics/incentive_shift_"*string(distribution)*".png",ff)
	display(ff)
	end
    """
    phaseplot(S; show_sustained=true, show_potential=true, same_potential_color=true, 
                show_realized=nothing, show_trajectory=false, regulated_dot_reduction=0.3, 
                attractor_size=30, show_attractor=true, show_target=true, vector_field=false, 
                vector_grid=20, show_vertical_potential=false, attractor_color=nothing, 
                show_legend=nothing, attractor_to_legend=false, show_exploitation=true, 
                indicate_incentives=false)

Plot the phase diagram for the given system.

# Arguments
- `S`: The system or set of systems to plot. Can be a single system or an array of systems.
- `show_sustained::Bool`: Whether to show sustained potential lines. Default is `true`.
- `show_potential::Bool`: Whether to show potential lines. Default is `true`.
- `same_potential_color::Bool`: Whether to use the same color for potential lines. Default is `true`.
- `show_realized`: Whether to show realized potential. Default is `nothing`.
- `show_trajectory::Bool`: Whether to show the trajectory of the system. Default is `false`.
- `regulated_dot_reduction::Float64`: Reduction factor for regulated dots. Default is `0.3`.
- `attractor_size::Int`: Size of attractor points. Default is `30`.
- `show_attractor::Bool`: Whether to show attractor points. Default is `true`.
- `show_target::Bool`: Whether to show target lines. Default is `true`.
- `vector_field::Bool`: Whether to show the vector field. Default is `false`.
- `vector_grid::Int`: The resolution of the vector grid. Default is `20`.
- `show_vertical_potential::Bool`: Whether to show vertical potential lines. Default is `false`.
- `attractor_color`: Color for attractor points. Default is `nothing`.
- `show_legend`: Whether to show the legend. Default is `nothing`.
- `attractor_to_legend::Bool`: Whether to add attractors to the legend. Default is `false`.
- `show_exploitation::Bool`: Whether to show exploitation areas. Default is `true`.
- `indicate_incentives`: How to indicate incentives. Default is `false`.

# Description
This function plots the phase diagram of the given system or set of systems, including options to show sustained potential, trajectory, vector field, and more. It supports various customization options for colors, sizes, and legend display.

# Example
```julia
s = scenario()  
phaseplot!(s, show_trajectory=true, vector_field=true)
```
"""
    function phaseplot(S;vector_field=false, show_realized=false, show_sustained=true, show_trajectory=false, show_target=true,saveas="")
        f=Figure()
        a=CairoMakie.Axis(f[1,1])
        hidespines!(a)
        phaseplot!(a,S;vector_field,show_realized, show_trajectory,show_target,show_sustained)
        if saveas!=""
            save("graphics/"*saveas,f)
        end
        f
    end
    
    function incomes(S; indexed=true)
        f=Figure()
        a=Axis(f[1,1])
        hidespines!(a)
        incomes!(a,S;indexed)
        f
    end
    
    function SEDplot(S,vx,vy; show_density=false, sort=true, markersize=5, labels=true, icons=false, icon_size=30, color=nothing)
        f=Figure()
        a=Axis(f[1,1])
        hidespines!(a)
        SEDplot!(a,S,vx,vy; show_density, sort, markersize, labels, icons, icon_size, color)
        f
    end