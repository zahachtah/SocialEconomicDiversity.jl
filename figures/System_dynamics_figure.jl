function figure3(; font="Gloria Hallelujah", fontsize=12)

	function get_deriv_vector(y,u,z)
		p=z.final.p
		du=zeros(p.N+2)
		usum=cumsum(p.ū)
		Q=findall(usum.<=u)
		n=length(Q)
		deltau=usum[min(p.N,Q[end]+1)]-u
		U=zeros(p.N+2)
		U[Q]=p.ū[Q]
		U[min(p.N,n+1)]=deltau
		U[p.N+1]=y
		dudt(du,U,p,0)
		radian_angle = atan(sum(du[1:p.N]),du[p.N+1])
    	#rad2deg(radian_angle)+180
		#(du[p.N+1],sum(du[1:p.N]))
		radian_angle-pi/2,sqrt(sum(du[1:p.N])^2+du[p.N+1]^2)
	end


	
	N=20
	fig3=Figure(size=(1200,800))
	ax11_fig3=Axis(fig3[1,2], title="Impact potential",yticks = 0:1,titlefont=font)#, titlecolor=:black
	hidexdecorations!(ax11_fig3)
	ax21_fig3=Axis(fig3[2,2], title="covar Impact - Incentive ",yticks = 0:1,titlefont=font)
	hidexdecorations!(ax21_fig3)
	Behavioural_adaptability=Axis(fig3[3,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	ax12_fig3=Axis(fig3[1,1], title="Inequality (slope^-1)",titlefont=font)
	hidexdecorations!(ax12_fig3)
	hideydecorations!(ax12_fig3)
	ax22_fig3=Axis(fig3[2,1], title="Development (position)",titlefont=font)
	hidexdecorations!(ax22_fig3)
	hideydecorations!(ax22_fig3)
	ax32_fig3=Axis(fig3[3,1], title="Development & Inequality",xticks = 0:1,titlefont=font)
	hideydecorations!(ax32_fig3)
	ax13_fig3=Axis(fig3[1,3], title="Phase plane dynamics",yticks = 0:1,xticks = 0:1,titlefont=font)
	ax23_fig3=Axis(fig3[2,3], xscale = identity,title="Individual actors responses",titlefont=font)
	#ax33_fig3=Axis(fig3[3,3],title="Income distribution",titlefont=font)
	
	#hideydecorations!(ax23_fig3)
	ax23_fig3.ylabel="resource use"
	#ax33_fig3=Axis(fig3[3,4], title="ū")


   
	#Main Phaseplot
    
	s13=scenario(w=SED(min=0.15,max=0.95,normalize=true,distribution=LogNormal),color=colorant"crimson";N)
	#=
	points = [Point2f(x/11, y/11) for y in 1:10 for x in 1:10]
	rotations = [get_deriv_vector(p[1],p[2],s13)[1] for p in points]
	markersize13 = [(get_deriv_vector(p[1],p[2],s13)[2]*20)^0.2*15 for p in points]

	scatter!(ax13_fig3,points, rotations = rotations, markersize = markersize13, marker = '↑', color=:lightgray)
	=#
	phaseplot!(ax13_fig3,scenario(),vector_field=true)
 #=
	# Individual u's
	testbands=true
	cbarPal = :rainbow2
	cmap = cgrad(colorschemes[cbarPal], s13.final.p.N, categorical = true)
    period=s13.final.period
	cs=cumsum(s13.u,dims=1)
    for i in 1:s13.final.p.N
		if testbands
			band!(ax23_fig3,s13.t[period[2:end]].+1,i==1 ? 0. *cs[i,period[2:end]] :  cs[i-1,period[2:end]],cs[i,period[2:end]], color=cmap[i])
		else
        lines!(ax23_fig3,s13.t[period].+1,s13.u[i,period], color=cmap[i],linestyle=:dot)#./s13.final.p.ū[i]
		end
    end
	Colorbar(fig3[2,4] , label="Incentive level, w̃", limits = (minimum(s13.final.p.w̃), maximum(s13.final.p.w̃)), colormap = :rainbow2,halign=:left,tellwidth=true)



	
		#income distribution



	#Base scenario with dynamics
	phaseplots(ax13_fig3,s13,show_trajectory=true)

	#Increasing inequality
	phaseplots(ax12_fig3,sim(cenario(a=1,w=SharedLinear(0.5,0.5),color=convert(HSL,colorant"crimson");N)),show_trajectory=false, attractor_size=40,show_required=false,show_attractor=false)
	phaseplots(ax12_fig3,sim(cenario(w=SharedLognormal(0.33,0.75),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false, attractor_size=30,show_required=false,show_attractor=false)
	phaseplots(ax12_fig3,sim(cenario(w=SharedLognormal(0.15,1.69),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false, attractor_size=20,show_required=false,show_attractor=false)
	lines!(ax12_fig3,[0.5,0.5],[0.0,1.0],color=:crimson)
	text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	#Increasing wealth
	phaseplots(ax22_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),color=convert(HSL,colorant"crimson");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplots(ax22_fig3,sim(cenario(w=SharedLognormal(0.1,0.4),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplots(ax22_fig3,sim(cenario(w=SharedLognormal(0.6,0.9),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false,show_required=false,show_attractor=false)
	#text!(ax22_fig3,0.2,0.2,text="increasing wealth",font="Gloria Hallelujah", align=(:left, :top), color=:black)
	#arrows!(ax22_fig3,0.2, 0.1, 0.5, 0)
	#text!(ax22_fig3, 0.5, 0.4, text=L"\tilde{w}=\frac{w}{q p K}", align=(:left, :top), color=:black)

	#Increasing inequality & dev
	phaseplots(ax32_fig3,sim(cenario(w=SharedLognormal(0.05,0.3),color=convert(HSL,colorant"crimson");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplots(ax32_fig3,sim(cenario(w=SharedLognormal(0.05,0.95),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false,show_required=false,show_attractor=false)
	phaseplots(ax32_fig3,sim(cenario(w=SharedLognormal(0.05,2.25),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false,show_required=false,show_attractor=false)
	text!(ax32_fig3,0.55,0.75,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax32_fig3,0.09,1.07,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:crimson)
	text!(ax32_fig3,0.12,0.04,text="<- low end stuck",font="Gloria Hallelujah", align=(:left, :bottom), color=:gray)

	# Increasing impact potential
	phaseplots(ax11_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),color=convert(HSL,colorant"crimson");N)),show_trajectory=false)
	phaseplots(ax11_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),ē=Linear(0.4,0.4),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false)
	phaseplots(ax11_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),ē=Linear(1.6,1.6),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false)
		text!(ax11_fig3,0.55,0.3,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax11_fig3,0.8,0.85,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)
	text!(ax11_fig3,0.56,0.95,text="↑ maximum resource reduction",font="Gloria Hallelujah", align=(:left, :top), color=:gray, fontsize=10)
	text!(ax11_fig3,0.0,0.7,text="<- fraction use that crashes resource",font="Gloria Hallelujah", align=(:left, :top), color=:gray, fontsize=10)

	# bending impact potential
	phaseplots(ax21_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),color=convert(HSL,colorant"crimson");N)),show_trajectory=false)
	phaseplots(ax21_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),ē=Linear(0.1,1.9),color=convert(HSL,colorant"steelblue");N)),show_trajectory=false)
	phaseplots(ax21_fig3,sim(cenario(w=SharedLognormal(0.35,0.55),ē=Linear(1.9,0.1),color=convert(HSL,colorant"forestgreen");N)),show_trajectory=false)
	text!(ax21_fig3,0.05,0.4,text="positive",font="Gloria Hallelujah", align=(:left, :top), color=:forestgreen)
	text!(ax21_fig3,0.6,0.8,text="negative",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)

	# Dynamics
	phaseplots(Behavioural_adaptability,sim(cenario(w=SharedLognormal(0.35,0.55),a=0.5,color=convert(HSL,colorant"crimson");N)))
	phaseplots(Behavioural_adaptability,sim(cenario(w=SharedLognormal(0.35,0.55),a=2,color=convert(HSL,colorant"steelblue");N)))
	text!(Behavioural_adaptability,0.8,0.85,text="low",font="Gloria Hallelujah", align=(:left, :top), color=:steelblue)
	text!(Behavioural_adaptability,0.7,0.65,text="high",font="Gloria Hallelujah", align=(:left, :top), color=:crimson)
	


=#
	fig3
end