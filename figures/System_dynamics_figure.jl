function figure3(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]))

	function get_deriv_vector2(y,u,z)
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

	nc=10	
	(low,medium,high)=cs
	
	N=200
	fig3=Figure(size=(900,900))
	impact_potential=Axis(fig3[1,2], title="Impact potential",yticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential)
	hidespines!(impact_potential)
	hidexdecorations!(impact_potential)
	covar_impact=Axis(fig3[2,2], title="Covariation Impact ~ Incentive ",yticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact)
	hidespines!(covar_impact)
	Behavioural_adaptability=Axis(fig3[3,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	inequality=Axis(fig3[1,1], title="Inequality",titlefont=font)
	hidexdecorations!(inequality)
	hideydecorations!(inequality)
	hidespines!(inequality)
	development=Axis(fig3[3,1], title="Equal Development",titlefont=font)
	hidexdecorations!(development)
	hideydecorations!(development)
	hidespines!(development)
	development_inequality=Axis(fig3[2,1], title="Increasing Development and Inequality",xticks = 0:1,titlefont=font)
	hideydecorations!(development_inequality)
	hidespines!(development_inequality)
	vector_field=Axis(fig3[1,3], title="Phase plane dynamics",yticks = 0:1,xticks = 0:1,titlefont=font)
	hidespines!(vector_field)
	individual=Axis(fig3[2,3], xscale = log10,title="Individual actors use over time",titlefont=font, xlabel="time",ylabel="incentives, w̃")
	hidespines!(individual)
	Income_distribution=fig3[3,2]=GridLayout(title="incomes")
	#Axis(fig3[3,2],title="Income distribution",titlefont=font)
	#hidespines!(Income_distribution)
	
	#hideydecorations!(ax23_fig3)
	#ax23_fig3.ylabel="resource use"
	#ax33_fig3=Axis(fig3[3,4], title="ū")

#=
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.25,max=0.25, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.16,max=0.36, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.05,max=0.88, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
=#
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)


	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.35,sigma=0.4, normalize=true, distribution=LogNormal),color=high;N)
	phaseplot!(development,d1,show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(development,d2,show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(development,d3,show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
	
	di1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N)
	di2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.65, normalize=true, distribution=LogNormal),color=medium;N)
	di3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.95, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development_inequality,di1,show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(development_inequality,di2,show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(development_inequality,di3,show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   
	phaseplot!(impact_potential,scenario(ū=sed(mean=0.5, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(impact_potential,scenario(ū=sed(mean=1.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(impact_potential,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=-2.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=2.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   

	phaseplot!(Behavioural_adaptability,scenario(α=sed(mean=0.5,sigma=0.0, normalize=true),	ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=true, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(Behavioural_adaptability,scenario(α=sed(mean=2.0,sigma=0.0, normalize=true),ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=true, attractor_size=30,show_attractor=false, show_exploitation=false)
	


	#Main Phaseplot
    
	s13=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=medium;N)#scenario(w=sed(min=0.15,max=0.95,normalize=true,distribution=LogNormal),α=sed(mean=2.0,sigma=0.0, normalize=true),color=colorant"crimson";N)
	#=
	points = [Point2f(x/11, y/11) for y in 1:10 for x in 1:10]
	rotations = [get_deriv_vector(p[1],p[2],s13)[1] for p in points]
	markersize13 = [(get_deriv_vector(p[1],p[2],s13)[2]*20)^0.2*15 for p in points]

	scatter!(ax13_fig3,points, rotations = rotations, markersize = markersize13, marker = '↑', color=:lightgray)
	=#
	phaseplot!(vector_field,s13,vector_field=true)

	#Label(Income_distribution[0,1], "Income distributions", fontsize=fontsize, font=font, tellwidth=false)
	i1=Axis(Income_distribution[1,1])
	hidedecorations!(i1)
	hidespines!(i1)
	incomes!(i1,d1, indexed=:w̃)
	i2=Axis(Income_distribution[2,1])
	hidedecorations!(i2)
	hidespines!(i2)
	incomes!(i2,d2, indexed=:w̃)
	i3=Axis(Income_distribution[3,1])
	hidedecorations!(i3)
	hidespines!(i3)
	incomes!(i3,d3, indexed=:w̃)
	individual_u!(individual,s13)
 
	fig3
end


function figure3_newSED(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]))


	nc=10	
	(low,medium,high)=cs
	s=base()
	N=200
	fig3=Figure(size=(900,900))
	impact_potential=Axis(fig3[1,2], title="Impact potential",yticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential)
	hidespines!(impact_potential)
	hidexdecorations!(impact_potential)
	covar_impact=Axis(fig3[2,2], title="Covariation Impact ~ Incentive ",yticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact)
	hidespines!(covar_impact)
	Behavioural_adaptability=Axis(fig3[3,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	inequality=Axis(fig3[1,1], title="Inequality",titlefont=font)
	hidexdecorations!(inequality)
	hideydecorations!(inequality)
	hidespines!(inequality)
	development=Axis(fig3[3,1], title="Equal Development",titlefont=font)
	hidexdecorations!(development)
	hideydecorations!(development)
	hidespines!(development)
	development_inequality=Axis(fig3[2,1], title="Increasing Development and Inequality",xticks = 0:1,titlefont=font)
	hideydecorations!(development_inequality)
	hidespines!(development_inequality)
	vector_field=Axis(fig3[1,3], title="Phase plane dynamics",yticks = 0:1,xticks = 0:1,titlefont=font)
	hidespines!(vector_field)
	individual=Axis(fig3[2,3], xscale = log10,title="Individual actors use over time",titlefont=font, xlabel="time",ylabel="incentives, w̃")
	hidespines!(individual)
	Income_distribution=fig3[3,2]=GridLayout(title="incomes")
	#Axis(fig3[3,2],title="Income distribution",titlefont=font)
	#hidespines!(Income_distribution)
	
	#hideydecorations!(ax23_fig3)
	#ax23_fig3.ylabel="resource use"
	#ax33_fig3=Axis(fig3[3,4], title="ū")

#=
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.25,max=0.25, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.16,max=0.36, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.05,max=0.88, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
=#
	phaseplot!(inequality,scenario(s,ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(inequality,scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(inequality,scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)


	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(s,ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.35,sigma=0.4, normalize=true, distribution=LogNormal),color=high;N)
	phaseplot!(development,d1,show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(development,d2,show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(development,d3,show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
	
	di1=scenario(s,ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N)
	di2=scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.65, normalize=true, distribution=LogNormal),color=medium;N)
	di3=scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.95, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development_inequality,di1,show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(development_inequality,di2,show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(development_inequality,di3,show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   
	phaseplot!(impact_potential,scenario(ū=sed(mean=0.5, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(impact_potential,scenario(ū=sed(mean=1.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(impact_potential,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=-2.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, attractor_size=30,show_attractor=false, show_exploitation=false)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=2.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, attractor_size=20,show_attractor=false, show_exploitation=false)
   

	phaseplot!(Behavioural_adaptability,scenario(α=sed(mean=0.5,sigma=0.0, normalize=true),	ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=true, attractor_size=40,show_attractor=false,show_exploitation=true)
	phaseplot!(Behavioural_adaptability,scenario(α=sed(mean=2.0,sigma=0.0, normalize=true),ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=true, attractor_size=30,show_attractor=false, show_exploitation=false)
	


	#Main Phaseplot
    
	s13=scenario(s,ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=medium;N)#scenario(w=sed(min=0.15,max=0.95,normalize=true,distribution=LogNormal),α=sed(mean=2.0,sigma=0.0, normalize=true),color=colorant"crimson";N)
	#=
	points = [Point2f(x/11, y/11) for y in 1:10 for x in 1:10]
	rotations = [get_deriv_vector(p[1],p[2],s13)[1] for p in points]
	markersize13 = [(get_deriv_vector(p[1],p[2],s13)[2]*20)^0.2*15 for p in points]

	scatter!(ax13_fig3,points, rotations = rotations, markersize = markersize13, marker = '↑', color=:lightgray)
	=#
	

	#Label(Income_distribution[0,1], "Income distributions", fontsize=fontsize, font=font, tellwidth=false)
	i1=Axis(Income_distribution[1,1])
	hidedecorations!(i1)
	hidespines!(i1)
	incomes!(i1,d1, indexed=:w̃)
	i2=Axis(Income_distribution[2,1])
	hidedecorations!(i2)
	hidespines!(i2)
	incomes!(i2,d2, indexed=:w̃)
	i3=Axis(Income_distribution[3,1])
	hidedecorations!(i3)
	hidespines!(i3)
	incomes!(i3,d3, indexed=:w̃)
	individual_u!(individual,s13)
 
	fig3
end

function phaseplot!()
	
end