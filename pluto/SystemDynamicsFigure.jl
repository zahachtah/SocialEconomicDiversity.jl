### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ ede552f6-3535-11ef-3366-477f9b9b522e
begin
	using Pkg

	# downloading latest package from private repo
	Pkg.add(url="https://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@github.com/zahachtah/SocialEconomicDiversity.jl")
	#Pkg.add(url="https://github.com/zahachtah/SocialEconomicDiversity.jl");
	using SocialEconomicDiversity, CairoMakie, DataFrames, Colors,ColorSchemes, Statistics, Images, FileIO
	set_theme!(theme_light())
end;

# ╔═╡ cc0aebe2-dbb9-4159-b91f-2ef9475ad435
begin 
	str = "M 130 110 C 160 110, 150 180, 190 180"
	bp = BezierPath(str, fit = true)
	scatter([1],[1], marker = bp, markersize = 20, color=:transparent, strokewidth=2,strokecolor=:black)
end

# ╔═╡ 545cd41b-44d6-44a1-967a-fae9efcf88b6
function figure3d(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]), saveas="", show_attractor=true, attractor_size=12)


	nc=10	
	(low,medium,high)=cs
	
	N=200
	B=300
	fig3=Figure(size=(3.5*B,2*B))
	
	impact_potential=CairoMakie.Axis(fig3[1,2],yticks = 0:1,xticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential, ticklabels=false)
	hidespines!(impact_potential)
	
	covar_impact=CairoMakie.Axis(fig3[2,2],yticks = 0:1,xticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact, ticklabels=false)
	hidespines!(covar_impact)
	
	Behavioural_adaptability=CairoMakie.Axis(fig3[1,3],xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	
	inequality=CairoMakie.Axis(fig3[1,1],titlefont=font,yticks = 0:1,xticks = 0:1)
	hidexdecorations!(inequality, ticklabels=false)
	hideydecorations!(inequality)
	hidespines!(inequality)
	
	development=CairoMakie.Axis(fig3[2,1],titlefont=font, ylabel="Participation",yticks = 0:1,xticks = 0:1)
	hidexdecorations!(development, ticklabels=false)
	hideydecorations!(development, label=false)
	hidespines!(development)
	
	
	Kuznets=CairoMakie.Axis(fig3[1,4],yticks = 0:1,xticks = 0:1,titlefont=font, xlabel="Resource Level")
	hidespines!(Kuznets)
	
	individual=CairoMakie.Axis(fig3[2,3], yscale = log10,titlefont=font, ylabel="time →",xlabel="Actors sorted by incentive, w̃")
	xlims!(individual,0,1)
	hidespines!(individual)
	
	Income_distribution=fig3[2,4]=GridLayout( rowgap=0)

	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)

	arcarrow!(inequality,Point2f(0.25,0.55), 0.4, π/2, π/4)
	text!(inequality, 0.55,0.55,text="Increasing\nincentive\ndiversity",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)
	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.45,sigma=0.22, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.75,sigma=0.13, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development,d1,show_trajectory=false,show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(development,d2,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(development,d3,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	xs=[0.15]; ys=[0.5]
	arrow_fun(x) = Point2f(1.9,0.0)
	strength=0.5
	arrows!(development, xs, ys, arrow_fun, arrowsize = 15, lengthscale = 0.3, linewidth=2)
	text!(development, 0.52,0.5,text="Economic\ndevelopment",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)
		text!(development, 0.45,0.08,text="Increasing\nmean outside\nlievelihood\nopportunities",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)
	

   
	phaseplot!(impact_potential,scenario(ū=sed(mean=0.5, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=1.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false,show_exploitation=false;show_attractor,attractor_size)
	arcarrow!(impact_potential,Point2f(1.0,0.0), 0.7, π*0.9, π*0.6, begin_arrow=true,end_arrow=false)
		text!(impact_potential, 0.25,-0.03,text="Increasing\ntotal impact",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)

	covstr=2.4
	coscGray=scenario(ū=sed(mean=1.5, sigma=0.0,  normalize=true),w̃=sed(min=0.15,max=0.65, normalize=false, distribution=LogNormal),color=:lightgray;N)
	coscneg=scenario(ū=sed(mean=1.5, sigma=-covstr/2.94, normalize=true, distribution=LogNormal),w̃=sed(min=0.15,max=0.65, normalize=false, distribution=LogNormal),color=low;N)
	coscbase=scenario(ū=sed(mean=1.5, sigma=0.0,  normalize=true),w̃=sed(min=0.15,max=0.65, normalize=false, distribution=LogNormal),color=medium;N)
	coscpos=scenario(ū=sed(mean=2.0, sigma=covstr/2.04,  normalize=true,distribution=LogNormal),w̃=sed(min=0.15,max=0.65, normalize=false, distribution=LogNormal),color=high;N)
	phaseplot!(covar_impact,coscGray,show_trajectory=false, show_exploitation=true,show_sustained=false,show_attractor=false;attractor_size)
	phaseplot!(covar_impact,coscneg,show_trajectory=false, show_exploitation=false,show_potential=false;show_attractor,attractor_size)
	phaseplot!(covar_impact,coscbase,show_trajectory=false, show_exploitation=false,show_potential=false;show_attractor,attractor_size)
	phaseplot!(covar_impact,coscpos,show_trajectory=false, show_exploitation=false,show_potential=false;show_attractor,attractor_size)
	text!(covar_impact, 0.15,0.8,text="Convex impact curve:\nw̃ and ū correlate",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)
	text!(covar_impact, 0.48,0.7,text="cor(w̃,ū)>0",font=annotation_font,fontsize=16,color=high,lineheight=0.5)
	text!(covar_impact, 0.29,-0.02,text="cor(w̃,ū)<0",font=annotation_font,fontsize=16,color=low,lineheight=0.5)
	text!(covar_impact, 0.4,0.4,text="cor(w̃,ū)=0",font=annotation_font,fontsize=16,color=medium,lineheight=0.5)
	scatter!(covar_impact,coscneg.y,coscneg.U,markersize=12,color=low)
	scatter!(covar_impact,coscpos.y,coscpos.U,markersize=12,color=high)
	scatter!(covar_impact,coscbase.y,coscbase.U,markersize=12,color=medium)
   
	ba1=scenario(α=sed(mean=0.5,sigma=0.0, normalize=true),	ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=low;N)
	ba2=scenario(α=sed(mean=2.0,sigma=0.0, normalize=true),ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(Behavioural_adaptability,ba1,show_trajectory=true, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(Behavioural_adaptability,ba2,show_trajectory=true, show_exploitation=false;show_attractor,attractor_size)
	text!(Behavioural_adaptability, 0.55,0.6,text="Increasing\nrelative\ndynamics",font=annotation_font,fontsize=14,color=:black,lineheight=0.5)
	arrow_fun2(x) = Point2f(0.2,0.3)
	arrows!(Behavioural_adaptability, [0.5], [0.35], arrow_fun2, arrowsize = 15, lengthscale = 0.55, linewidth=2)

		s13=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=high;N)
	#Main Phaseplot
    csc=ColorSchemes.:rainbow2#bam#magma
	cl=length(csc)
	rand=false
	is=1.25
	S=[scenario(ū=sed(mean=3*c*is, sigma=0.0,  normalize=true),w=sed(median=0.8*c/is,sigma=0.5, normalize=true, distribution=LogNormal),color=:lightgray;N) for c in range(0.1,stop=2.0,length=100)]
	s1=scenario(ū=sed(mean=0.5, sigma=0.0,  normalize=true),w=sed(min=0.05,max=0.25, normalize=true, distribution=LogNormal),color=:lightgray;N)
	s2=scenario(ū=sed(mean=1.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.05,max=0.65, normalize=true, distribution=LogNormal, random=rand),color=csc[40];N)
	s3=scenario(ū=sed(mean=1.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.075,max=0.75, normalize=true, distribution=LogNormal, random=rand),color=csc[50];N)
	s4=scenario(ū=sed(mean=2.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.1,max=0.95, normalize=true, distribution=LogNormal, random=rand),color=csc[60];N)
	s5=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.15,max=1.55, normalize=true, distribution=LogNormal, random=rand),color=csc[70];N)
	s6=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.2,max=2.55, normalize=true, distribution=LogNormal, random=rand),color=csc[90];N)
	s7=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.4,max=4.55, normalize=true, distribution=LogNormal, random=rand),color=csc[100];N)

	m=7
	for (i,s) in enumerate(S)
		mod(i,m)==1 ? phaseplot!(Kuznets,s; attractor_size=0, show_exploitation=i==1 ? true : false) : nothing
		scatter!(Kuznets,[s.y],[s.U],color=csc[i])
	end
	lines!(Kuznets,[s.y for s in S],[s.U for s in S], colormap=csc,color=1:length(S), linewidth=1)
	text!(Kuznets, 0.3,0.4,text="Attractor\ntrajectory\nover time as\nincentives and\nimpacts change",font=annotation_font,fontsize=16,color=:black,lineheight=0.5)
	#=
	phaseplot!(Kuznets,s1; attractor_size)
	phaseplot!(Kuznets,s2,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s3,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s4,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s5,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s6,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s7,show_exploitation=false;attractor_size)
=#
	for (i,s) in enumerate([coscpos,coscbase,coscneg])
		iax=CairoMakie.Axis(Income_distribution[i,1])
		hidedecorations!(iax)
		#incomes!(iax,s,show_text=false, indexed=:w̃, fix_xlim=false)
	end

	Colorbar(fig3[1,5], label="Time",ticks=([0,1],["end","start"]),colormap=reverse(csc),tellwidth=true)
	
	fs=20
	Label(fig3[0,3],text="Dynamics, α", tellwidth=false, fontsize=fs)
	Label(fig3[0,1],text="Incentives, w̃", tellwidth=false, fontsize=fs)
	Label(fig3[0,2],text="Impact, ū", tellwidth=false, fontsize=fs)
	Label(fig3[0,4],text="Environmental Kuznets", tellwidth=false, fontsize=fs)
	fst=18
	text!(Behavioural_adaptability,0.05,0.9,text="e", fontsize=fst)
	text!(individual,0.05,1000,text="f", fontsize=fst)
	text!(individual,0.65,1000,text="Participation \nover time", fontsize=fst)
	text!(inequality,0.05,0.9,text="a", fontsize=fst)
	text!(development,0.05,0.9,text="b", fontsize=fst)
	text!(impact_potential,0.05,0.9,text="c", fontsize=fst)
	text!(covar_impact,0.05,0.9,text="d", fontsize=fst)
	text!(Kuznets,0.05,0.9,text="g", fontsize=fst)
	#println(s13.w̃.data)
	individual_u!(individual,ba2, rot=true)
 	saveas!="" ? save(saveas,fig3) : nothing
	fig3
end

# ╔═╡ fdbe88f9-d515-4ee1-8d30-ad6e636314a2
figure3d(saveas="../figures/system_dynamic_figure.png")

# ╔═╡ d6124a1f-4b50-47ba-899c-904742a0cce5
function figure3c(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]), saveas="", show_attractor=true, attractor_size=10)

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
	B=300
	fig3=Figure(size=(2*B,3.5*B))
	
	impact_potential=CairoMakie.Axis(fig3[3,1],yticks = 0:1,xticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential, ticklabels=false)
	hidespines!(impact_potential)
	
	covar_impact=CairoMakie.Axis(fig3[3,2],yticks = 0:1,xticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact, ticklabels=false)
	hidespines!(covar_impact)
	
	Behavioural_adaptability=CairoMakie.Axis(fig3[1,1],xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	
	inequality=CairoMakie.Axis(fig3[2,1],titlefont=font,yticks = 0:1,xticks = 0:1)
	hidexdecorations!(inequality, ticklabels=false)
	hideydecorations!(inequality)
	hidespines!(inequality)
	
	development=CairoMakie.Axis(fig3[2,2],titlefont=font, ylabel="Participation",yticks = 0:1,xticks = 0:1)
	hidexdecorations!(development, ticklabels=false)
	hideydecorations!(development, label=false)
	hidespines!(development)
	
	
	Kuznets=CairoMakie.Axis(fig3[4,1],yticks = 0:1,xticks = 0:1,titlefont=font, xlabel="Resource Level")
	hidespines!(Kuznets)
	
	individual=CairoMakie.Axis(fig3[1,2], yscale = log10,titlefont=font, ylabel="time →",xlabel="Actors sorted by incentive, w̃")
	xlims!(individual,0,1)
	hidespines!(individual)
	
	Income_distribution=fig3[4,2]=GridLayout( rowgap=0)

	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)


	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.35,sigma=0.22, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.55,sigma=0.13, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development,d1,show_trajectory=false,show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(development,d2,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(development,d3,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	

   
	phaseplot!(impact_potential,scenario(ū=sed(mean=0.5, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=1.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false,show_exploitation=false;show_attractor,attractor_size)
   
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=-2.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=2.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
   
	ba1=scenario(α=sed(mean=0.5,sigma=0.0, normalize=true),	ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=low;N)
	ba2=scenario(α=sed(mean=2.0,sigma=0.0, normalize=true),ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(Behavioural_adaptability,ba1,show_trajectory=true, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(Behavioural_adaptability,ba2,show_trajectory=true, show_exploitation=false;show_attractor,attractor_size)
	

		s13=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=high;N)
	#Main Phaseplot
    csc=ColorSchemes.magma
	rand=false
	s1=scenario(ū=sed(mean=0.5, sigma=0.0,  normalize=true),w=sed(min=0.05,max=0.25, normalize=true, distribution=LogNormal),color=csc[1];N)
	s2=scenario(ū=sed(mean=1.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.05,max=0.65, normalize=true, distribution=LogNormal, random=rand),color=csc[33];N)
	s3=scenario(ū=sed(mean=1.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.075,max=0.75, normalize=true, distribution=LogNormal, random=rand),color=csc[66];N)
	s4=scenario(ū=sed(mean=2.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.1,max=0.95, normalize=true, distribution=LogNormal, random=rand),color=csc[100];N)
	s5=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.15,max=1.55, normalize=true, distribution=LogNormal, random=rand),color=csc[150];N)
	s6=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.2,max=2.55, normalize=true, distribution=LogNormal, random=rand),color=csc[200];N)
	s7=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.4,max=4.55, normalize=true, distribution=LogNormal, random=rand),color=csc[250];N)

	phaseplot!(Kuznets,s1; attractor_size)
	phaseplot!(Kuznets,s2,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s3,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s4,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s5,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s6,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s7,show_exploitation=false;attractor_size)

	for (i,s) in enumerate([s1,s3,s5,s7])
		iax=CairoMakie.Axis(Income_distribution[i,1])
		hidedecorations!(iax)
		incomes!(iax,s,show_text=false, indexed=:w̃, fix_xlim=false)
	end
	fs=20
	Label(fig3[1,0],text="Dynamics",rotation=pi/2, tellheight=false, fontsize=fs)
	Label(fig3[2,0],text="Incentives",rotation=pi/2, tellheight=false, fontsize=fs)
	Label(fig3[3,0],text="Impacts",rotation=pi/2, tellheight=false, fontsize=fs)
	Label(fig3[4,0],text="Environmental Kuznets",rotation=pi/2, tellheight=false, fontsize=fs)
	
	#println(s13.w̃.data)
	individual_u!(individual,ba2, rot=true)
 	saveas!="" ? save(saveas,fig3) : nothing
	fig3
end

# ╔═╡ 54c44bd0-db85-40af-934c-adb9a372a9c8
function figure3a(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]), saveas="", show_attractor=true, attractor_size=10)

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
	
	impact_potential=CairoMakie.Axis(fig3[1,2], title="Impact potential",yticks = 0:1,xticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential, ticklabels=false)
	hidespines!(impact_potential)
	
	covar_impact=CairoMakie.Axis(fig3[2,2], title="Covariation Impact ~ Incentive ",yticks = 0:1,xticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact, ticklabels=false)
	hidespines!(covar_impact)
	
	Behavioural_adaptability=CairoMakie.Axis(fig3[1,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	
	inequality=CairoMakie.Axis(fig3[1,1], title="Inequality",titlefont=font,yticks = 0:1,xticks = 0:1)
	hidexdecorations!(inequality, ticklabels=false)
	hideydecorations!(inequality)
	hidespines!(inequality)
	
	development=CairoMakie.Axis(fig3[2,1], title="Equal Development",titlefont=font, ylabel="Participation",yticks = 0:1,xticks = 0:1)
	hidexdecorations!(development, ticklabels=false)
	hideydecorations!(development, label=false)
	hidespines!(development)
	
	development_inequality=CairoMakie.Axis(fig3[3,1], title="Increasing Development and Inequality",yticks = 0:1,xticks = 0:1,titlefont=font)
	hideydecorations!(development_inequality)
	hidespines!(development_inequality)
	
	Kuznets=CairoMakie.Axis(fig3[3,2], title="Kuznets development trajectory",yticks = 0:1,xticks = 0:1,titlefont=font, xlabel="Resource Level")
	hidespines!(Kuznets)
	
	individual=CairoMakie.Axis(fig3[2,3], yscale = log10,title="Actors resurce use over time",titlefont=font, ylabel="time →",xlabel="Actors sorted by incentive, w̃")
	xlims!(individual,0,1)
	hidespines!(individual)
	
	Income_distribution=fig3[3,3]=GridLayout(title="incomes", rowgap=0)

	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)


	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.35,sigma=0.22, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.55,sigma=0.13, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development,d1,show_trajectory=false,show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(development,d2,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(development,d3,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	di1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N)
	di2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.85, normalize=true, distribution=LogNormal),color=medium;N)
	di3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=1.35, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development_inequality,di1,show_trajectory=false,show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(development_inequality,di2,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(development_inequality,di3,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
   
	phaseplot!(impact_potential,scenario(ū=sed(mean=0.5, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=1.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(impact_potential,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false,show_exploitation=false;show_attractor,attractor_size)
   
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=-2.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(covar_impact,scenario(ū=sed(mean=2.0, sigma=2.0,  normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
   
	ba1=scenario(α=sed(mean=0.5,sigma=0.0, normalize=true),	ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=low;N)
	ba2=scenario(α=sed(mean=2.0,sigma=0.0, normalize=true),ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.1,max=1.0, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(Behavioural_adaptability,ba1,show_trajectory=true, show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(Behavioural_adaptability,ba2,show_trajectory=true, show_exploitation=false;show_attractor,attractor_size)
	

		s13=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=high;N)
	#Main Phaseplot
    csc=ColorSchemes.magma
	rand=false
	s1=scenario(ū=sed(mean=0.5, sigma=0.0,  normalize=true),w=sed(min=0.05,max=0.25, normalize=true, distribution=LogNormal),color=csc[1];N)
	s2=scenario(ū=sed(mean=1.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.05,max=0.65, normalize=true, distribution=LogNormal, random=rand),color=csc[33];N)
	s3=scenario(ū=sed(mean=1.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.075,max=0.75, normalize=true, distribution=LogNormal, random=rand),color=csc[66];N)
	s4=scenario(ū=sed(mean=2.0, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.1,max=0.95, normalize=true, distribution=LogNormal, random=rand),color=csc[100];N)
	s5=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.15,max=1.55, normalize=true, distribution=LogNormal, random=rand),color=csc[150];N)
	s6=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.2,max=2.55, normalize=true, distribution=LogNormal, random=rand),color=csc[200];N)
	s7=scenario(ū=sed(mean=2.5, sigma=1.0,  normalize=true, random=rand),w=sed(min=0.4,max=4.55, normalize=true, distribution=LogNormal, random=rand),color=csc[250];N)

	phaseplot!(Kuznets,s1; attractor_size)
	phaseplot!(Kuznets,s2,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s3,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s4,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s5,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s6,show_exploitation=false;attractor_size)
	phaseplot!(Kuznets,s7,show_exploitation=false;attractor_size)

	for (i,s) in enumerate([s1,s3,s5,s7])
		iax=CairoMakie.Axis(Income_distribution[i,1])
		hidedecorations!(iax)
		incomes!(iax,s,show_text=false, indexed=:w̃, fix_xlim=false)
	end
	
	#println(s13.w̃.data)
	individual_u!(individual,ba2, rot=true)
 	saveas!="" ? save(saveas,fig3) : nothing
	fig3
end

# ╔═╡ 404f5879-c9b0-4bbd-8ab8-9ab397bb4bea
function figure3(; font="Georgia", annotation_font="Gloria Hallelujah", fontsize=12, cs=(low=ColorSchemes.tab20[1], medium=ColorSchemes.tab20[5], high=ColorSchemes.tab20[3]), saveas="", show_attractor=true, attractor_size=10)

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
	
	impact_potential=CairoMakie.Axis(fig3[1,2], title="Impact potential",yticks = 0:1,titlefont=font, limits=(0,1,0,1),aspect=1)#, titlecolor=:black
	hidexdecorations!(impact_potential)
	hidespines!(impact_potential)
	hidexdecorations!(impact_potential)
	
	covar_impact=CairoMakie.Axis(fig3[2,2], title="Covariation Impact ~ Incentive ",yticks = 0:1,titlefont=font)
	hidexdecorations!(covar_impact)
	hidespines!(covar_impact)
	
	Behavioural_adaptability=CairoMakie.Axis(fig3[3,3], title="Behavioural adaptability",xticks = 0:1,yticks = 0:1,titlefont=font)
	hideydecorations!(Behavioural_adaptability)
	hidespines!(Behavioural_adaptability)
	
	inequality=CairoMakie.Axis(fig3[1,1], title="Inequality",titlefont=font)
	hidexdecorations!(inequality)
	hideydecorations!(inequality)
	hidespines!(inequality)
	
	development=CairoMakie.Axis(fig3[2,1], title="Equal Development",titlefont=font)
	hidexdecorations!(development)
	hideydecorations!(development)
	hidespines!(development)
	
	development_inequality=CairoMakie.Axis(fig3[3,1], title="Increasing Development and Inequality",xticks = 0:1,titlefont=font)
	hideydecorations!(development_inequality)
	hidespines!(development_inequality)
	
	vector_field=CairoMakie.Axis(fig3[1,3], title="Phase plane dynamics",yticks = 0:1,xticks = 0:1,titlefont=font)
	hidespines!(vector_field)
	individual=CairoMakie.Axis(fig3[2,3], xscale = log10,title="Actors resurce use over time",titlefont=font, xlabel="time →",ylabel="Actors sorted by incentive, w̃")
	hidespines!(individual)
	Income_distribution=fig3[3,2]=GridLayout(title="incomes")

	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.25,sigma=0.0, normalize=true, distribution=LogNormal),color=low;N),show_trajectory=false, show_exploitation=true;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.4, normalize=true, distribution=LogNormal),color=medium;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	phaseplot!(inequality,scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.25,sigma=0.8, normalize=true, distribution=LogNormal),color=high;N),show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)


	#text!(ax12_fig3,0.6,0.7,text="Some actors will\nnot participate\neven with max resource",font="Gloria Hallelujah", fontsize=10,align=(:left, :top), color=:black)

	d1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(median=0.15,sigma=0.4, normalize=true, distribution=LogNormal),color=low;N)
	d2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.35,sigma=0.22, normalize=true, distribution=LogNormal),color=medium;N)
	d3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(median=0.55,sigma=0.13, normalize=true, distribution=LogNormal),color=high;N)
	
	phaseplot!(development,d1,show_trajectory=false,show_exploitation=true;show_attractor,attractor_size)
	phaseplot!(development,d2,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	phaseplot!(development,d3,show_trajectory=false, show_exploitation=false;show_attractor,attractor_size)
	
	di1=scenario(ū=sed(mean=2.0, sigma=0.0, normalize=true),w=sed(min=0.15,max=0.35, normalize=true, distribution=LogNormal),color=low;N)
	di2=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=0.85, normalize=true, distribution=LogNormal),color=medium;N)
	di3=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.15,max=1.35, normalize=true, distribution=LogNormal),color=high;N)
	
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
    
	s13=scenario(ū=sed(mean=2.0, sigma=0.0,  normalize=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal),color=medium;N)
	#s23=scenario(ū=sed(mean=2.0, sigma=1.0,  normalize=true, random=true),w=sed(min=0.25,max=0.55, normalize=true, distribution=LogNormal, random=true),color=medium;N)
	#=
	points = [Point2f(x/11, y/11) for y in 1:10 for x in 1:10]
	rotations = [get_deriv_vector(p[1],p[2],s13)[1] for p in points]
	markersize13 = [(get_deriv_vector(p[1],p[2],s13)[2]*20)^0.2*15 for p in points]

	scatter!(ax13_fig3,points, rotations = rotations, markersize = markersize13, marker = '↑', color=:lightgray)
	=#
	#phaseplot!(vector_field,s13,vector_field=false)
	phaseplot!(vector_field,s13,vector_field=true)

	#Label(Income_distribution[0,1], "Income distributions", fontsize=fontsize, font=font, tellwidth=false)
	Label(Income_distribution[0,1],"Income Distributions", tellwidth=false)
	i1=CairoMakie.Axis(Income_distribution[1,1])
	hidedecorations!(i1)
	hidespines!(i1)
	incomes!(i1,di1, indexed=:w̃)
	i2=CairoMakie.Axis(Income_distribution[2,1])
	hidedecorations!(i2)
	hidespines!(i2)
	incomes!(i2,di2, indexed=:w̃)
	i3=CairoMakie.Axis(Income_distribution[3,1])
	hidedecorations!(i3)
	hidespines!(i3)
	incomes!(i3,di3, indexed=:w̃)
	individual_u!(individual,s13)
 	saveas!="" ? save(saveas,fig3) : nothing
	fig3
end

# ╔═╡ Cell order:
# ╠═fdbe88f9-d515-4ee1-8d30-ad6e636314a2
# ╠═cc0aebe2-dbb9-4159-b91f-2ef9475ad435
# ╠═545cd41b-44d6-44a1-967a-fae9efcf88b6
# ╠═d6124a1f-4b50-47ba-899c-904742a0cce5
# ╠═54c44bd0-db85-40af-934c-adb9a372a9c8
# ╠═404f5879-c9b0-4bbd-8ab8-9ab397bb4bea
# ╠═ede552f6-3535-11ef-3366-477f9b9b522e
