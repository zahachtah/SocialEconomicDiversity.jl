using Distributions

# Include the SED definition and dist! function here
# (assuming the previous code block is included here)

# Define a helper function to create an SED instance and call dist!
function create_sed_and_dist!(; kwargs...)
    sed_obj = sed(; kwargs...)
    dist!(sed_obj, 100)
    return sed_obj
end

# Test cases
@testset "SED Tests" begin
    # Test LogNormal distribution with min and max
    sed = create_sed_and_dist!(min=0.1, max=1.0, distribution=LogNormal)
    @test length(sed.data) == 100
    @test minimum(sed.data) >= 0.1
    @test maximum(sed.data) <= 1.0

    # Test Dirac distribution with min and max where min == max
    sed = create_sed_and_dist!(min=0.5, max=0.5, distribution=LogNormal)
    @test length(sed.data) == 100
    @test all(x -> x == 0.5, sed.data)

    # Test LogNormal distribution with mean and sigma
    sed = create_sed_and_dist!(mean=1.0, sigma=0.5, distribution=LogNormal)
    @test length(sed.data) == 100
    @test isapprox(mean(sed.data), 1.0, atol=0.1)
    @test isapprox(std(sed.data), 0.5, atol=0.1)

    # Test Dirac distribution with mean and zero sigma
    sed = create_sed_and_dist!(mean=1.0, sigma=0.0, distribution=LogNormal)
    @test length(sed.data) == 100
    @test all(x -> x == 1.0, sed.data)

    # Test Uniform distribution with min and max
    sed = create_sed_and_dist!(min=0.0, max=1.0, distribution=Uniform)
    @test length(sed.data) == 100
    @test minimum(sed.data) >= 0.0
    @test maximum(sed.data) <= 1.0

    # Test Dirac distribution with random sampling
    sed = SED(min=1.0, distribution=Dirac, random=true)
    dist!(sed, 100)
    @test length(sed.data) == 100
    @test all(x -> x == 1.0, sed.data)

    # Test normalization
    sed = create_sed_and_dist!(min=0.0, max=1.0, distribution=Uniform, normalize=true)
    @test length(sed.data) == 100
    @test isapprox(sum(sed.data), 1.0, atol=0.01)
end
