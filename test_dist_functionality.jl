using SocialEconomicDiversity

# Create a scenario using base parameters
println("Creating scenario...")
s = scenario(base(N=100))

# Test 1: Generate distribution for parameter w̃
println("Testing dist!(s, :w)...")
dist!(s, :w)
println("w̃ length: ", length(s.w̃.data))

# Test 2: Generate distribution for parameter ū
println("Testing dist!(s, :u)...")
dist!(s, :u)
println("ū length: ", length(s.ū.data))

# Test 3: Generate distributions for all parameters
println("Creating new scenario...")
s2 = scenario(base(N=100))
println("Before dist!(s2): w̃ has data? ", !isempty(s2.w̃.data), ", ū has data? ", !isempty(s2.ū.data))

println("Testing dist!(s2)...")
dist!(s2)
println("After dist!(s2): w̃ has data? ", !isempty(s2.w̃.data), ", ū has data? ", !isempty(s2.ū.data))
println("w̃ length: ", length(s2.w̃.data), ", ū length: ", length(s2.ū.data))

# Test 4: Create a scenario with dependent parameters
println("Setting up dependency test...")
w_sed = sed(min=0.1, max=1.0, distribution=LogNormal)
u_sed = sed(mean=0.5, sigma=0.1, distribution=Uniform)
d_sed = sed(min=0.2, max=0.3, dependent=(w=1.0, u=0.5, fun=(dep -> dep.w .* dep.u)), distribution=LogNormal)
context = (w=w_sed, u=u_sed, d=d_sed, N=100)

println("Testing dist! on dependent parameters...")
# Generate distributions for independent parameters first
dist!(w_sed, 100)
dist!(u_sed, 100)

# Then apply to dependent parameter
dist!(d_sed, 100, context=context)
println("d length: ", length(d_sed.data))

println("All tests completed successfully!")