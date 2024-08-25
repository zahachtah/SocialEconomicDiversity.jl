s2=scenario(
		w=sed(min=0.4,max=0.9,normalize=true),
		q=sed(mean=2.5,sigma=3.5,normalize=true),
		label="Moderate income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case2.png",
		institution=[Dynamic_permit_allocation(criteria=:w, reverse=true, value=0.24
		)]
	)
      # issues up to value=0.44

    #####
    # * make sure the right arrays get sent to all abstract institutional_analysis
    # * dynamic_permit reverse=true for some reason overfishes at low U. Focus on that!
    # * seem to only occur with positive sigma for q! doesthe phaseplot not match the actual simulation for q?
    # * suspiciously little curvature for q.sigma>0


    # make sure phaseplot matches with distributions in q/ū also for inst target!
  

    du=zeros(s2.N+3)
    SocialEconomicDiversity.dudt(du,vcat(s2.u,s2.y,0.0,s2.ϕ),s2,0.0)

    du


    s3=scenario(
		w=sed(min=0.4,max=0.9,normalize=true),
		q=sed(mean=2.5,sigma=0,normalize=true),
		label="Moderate income opportunities, and high impact",
		image="http://zahachtah.github.io/CAS/images/case2.png",
		institution=[Equal_share_allocation(target=:yield, value=0.5)]
	)