#constrain(du,u,minu,maxu,dt)=du.*dt.+u.<minu ? -u : du.*dt.+u.>maxu ? maxu-u : du

function dudt(dx,x,p,t)
	

	# extract the parameters from named tuple containers for simpler equation syntax
    dydt=p.sim.dydt # used when y is held constant
    N=p.N
	ū=p.ū.*p.aū
	w̃=p.w̃.*p.aw̃
	# should add a\alpha
	α=p.α
	
	dt=p.sim.dt #parameters
    
    # extract the variables from state vector
    u=view(x,1:N)   # actions
	du=view(dx,1:N) 
    #y=mean(x[N+1:end-1]) # if one wants to use spatial models of resource dynamics 		
    y=x[N+1]  
	yp=x[N+2]      # resource level
	ϕ=x[N+3] 		#trade price

	# NOTE NOTE NOTE: added 0.7 (f=0.3) to resource income calculation in scenarios.jl, change that

	# DO we need the dydt still? probably, for calculating attractor for fixed y
	
    @inline dx[1:N]=α.*(y*(1-p.protected).-w̃.-ϕ)
	dx[N+1]=dydt*(((1 -y)-sum(u)/(1-p.protected)) *y+((1-p.protected)!=0 ? p.protected/(1-p.protected)*p.dispersal*(yp-y) : 0))	
	dx[N+2]=dydt*(((1 -yp)) *yp+(p.protected!=0 ? (1-p.protected)/p.protected*p.dispersal*(y-yp) : 0))
	dx[N+3]=0.0
	[dynamic_institution(inst,du,u,p,t) for inst in p.institution]
end


function stage_limiter!(u, integrator, p, t)


	[limit_institution(inst,p,integrator) for inst in p.institution]
	
    u[p.N+3]=max(0.0,u[p.N+3])
	u[1:p.N].=ifelse.(u[1:p.N].<0.0,0.0,ifelse.(u[1:p.N].>(p.ū.*p.aū),p.ū.*p.aū,u[1:p.N]))


end

"""
sim(p; tend=(0.0,2000.0), y0=1.0, dydt=1.0,u0=fill(0.0/p.N,p.N), p0=0.0,solution=false, terminate_steady_state=true)

Main function to run a simulation with parameters provided by a scenario.

### Arguments
- `p`: Scenario parameters given by a Scenario struct, i.e., scenario() for default
- `tend`: Tuple representing the start and end time for the simulation (default: (0.0,2000.0))
- `y0`: Initial resource level (default: 1.0)
- `dydt`: Initial rate of change of the resource (default: 1.0). Useful if one wants to check the outcome for a given resource set by y0, then set to 0.0.
- `u0`: Initial effort level array. By default, it is an array filled with zeros of size `p.N`.
- `p0`: Initial tradable quota price (default: 0.0)
- `solution`: Boolean value to indicate if the function should return the solution object. If false, the function returns the solution vector (default: false).
- `terminate_steady_state`: Boolean value to indicate if the function should terminate when reaching a steady state. If true, the function terminates when reaching a steady state (default: true).

### Output
`Simulation`: Returns a Simulation struct which consists of the following fields:
- `t`: Vector of time points at which the solution was calculated
- `y`: Vector of resource level at each time point
- `ϕ`: Vector of tradable quota prices at each time point
- `frac_u`: Vector of the fraction of total effort at each time point
- `u`: Matrix with individual effort level at each time point
- `final`: A nested struct containing several final state values including:
    + `u`: Mean effort level over the periodic part of the solution
    + `frac_u`: Fraction of total effort over the periodic part of the solution
    + `y`: Mean resource level over the periodic part of the solution
    + `ϕ`: Mean quota price over the periodic part of the solution
    + `period`: Indices of the periodic part of the solution
    + `time`: Time taken by the simulation
    + `p`: Scenario parameters
- `sol`: Solution object if the `solution` argument was set to true, otherwise nothing


    """
function sim!(p; tend=(0.0,2000.0), y0=1.0, dydt=1.0,u0=fill(0.0/p.N,p.N), p0=0.0,solution=false,terminate_steady_state=true)
	t0=time()
    N=p.N
	isa(p.institution,Array) ? nothing : p.institution=[p.institution]
	[static_institution(inst,p) for inst in p.institution]
    # sets up the problem,
    prob = ODEProblem(dudt,[u0;y0;y0;p0],tend,p)
	#prob = ODEProblem(dudt_old,[u0;y0;y0;p0],tend,p)
    # solves the ODESSPRK22
    #sol=solve(prob,adaptive=false, Euler(),saveat=0.1,callback=terminate_steady_state ? TerminateSteadyState(1e-6,1e-4) : nothing,dt=p.sim.dt)#  
	sol=solve(prob,SSPRK432(;stage_limiter!),callback=terminate_steady_state ? TerminateSteadyState(1e-6,1e-4) : nothing, reltol=1e-5)
	if sol.retcode != :Success && sol.retcode != :Terminated
		println("Simulation failed with retcode: ", sol.retcode)
		println((p.label,p.institution[1]))
	end
	poa=deepcopy(p)
    poa.institution=[]
    DUDT=zeros(N+3)
    dudt(DUDT,sol.u[end],poa,0.0)
	individual=zeros(N,length(sol.t))
    [individual[:,i]=sol.u[i][1:N] for i in 1:length(sol.t)]
	#check for periodicity
		yy=[u[N+1] for u in sol.u]
		period=1:length(yy)

        id=findall(p.ū.>0.0)
		p.u=sol.u[end][1:N]
		p.U=sum(sol.u[end][id]./(p.ū[id].*p.aū[id])./p.N)
	    p.y=sol.u[end][N+1]
	    p.ϕ=sol.u[end][end]
		p.t=sol.t
		p.t_u=[sol.u[t][i] for t in 1:length(sol.t), i in 1:p.N]#[u[1:N] for u in sol.u]
	    p.t_y=[u[N+1] for u in sol.u]
	    p.t_ϕ=[u[end] for u in sol.u]
        
		p.t_U=[sum(u[id]./(p.ū[id].*p.aū[id])./p.N) for u in sol.u]
		c̃=0 
		
		revenues!(p)
		#=
		p.wage_revenue = (p.ū.*p.aū .- p.u) .* p.w̃.*p.aw̃.*p.r.*p.p.*p.K; 
        p.resource_revenue = p.u.*((p.y.*(1-p.protected)) .- c̃).*p.r.*p.p.*p.K;
        p.trade_revenue=(p.value./(p.y.*(1-p.protected))./p.N.-p.u).*p.ϕ.*p.r.*p.p.*p.K
        #R̃ₕᵣ= S.u.*(S.y .- S.w̃);
        p.total_revenue = p.wage_revenue .+  p.resource_revenue=#
		p.gini=gini(p.total_revenue)
        #p.sim=sol.retcode
	return p

end