import("SED_selfcontained.jl")
    
    # QUICKEST WAY:
    # Lets make q and w arrays
    N=100 # set number of actors

   # set min and max for q
   qmin=0.0001
   qmax=0.01
   # set min and max for w
   wmin=0.005
   wmax=0.0001

    #Initiate the distributions
    q=sed(min=qmin,max=qmax, distribution=Uniform)
    w=sed(min=wmin, max=wmax, distribution=LogNormal)#range(wmin,stop=wmax,length=N)
   
    # Need to instantiate it
    dist!(q,N)
    dist!(w,N)

   

    # NOTE: I changed plot_policies to take q and w instead of w̃ and ū
    f=plot_policies(w,q, order=false,goal=:oRR)
    # order=true orderes incomes according to total income, instead of index/w̃
    # goal: choose :oRR for resource revenue optima, :oToR for total optima or :oGI for gini

    regscan(s=scenario(base(),w̃=sed(data=w./q),ū=sed(data=q)), u=true)
    #IF you want to have a look at how the impact of regulations look

