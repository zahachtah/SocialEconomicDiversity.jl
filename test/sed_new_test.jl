using Test
using Distributions
using SocialEconomicDiversity
include("../src/sed_new.jl")

@testset "New SED Implementation" begin
    @testset "Basic Distribution Creation" begin
        # Test LogNormal with min/max
        s1 = sed(distribution=LogNormal, min=0.5, max=2.0)
        dist!(s1, 100)
        @test length(s1) == 100
        @test all(0.5 .<= s1 .<= 2.0)
        
        # Test Uniform with mean/sigma
        s2 = sed(distribution=Uniform, mean=1.0, sigma=0.5)
        dist!(s2, 100)
        @test length(s2) == 100
        @test isapprox(mean(s2), 1.0, atol=0.1)
        @test isapprox(std(s2), 0.5, atol=0.1)
        
        # Test Dirac (constant)
        s3 = sed(distribution=Dirac, value=1.5)
        dist!(s3, 100)
        @test length(s3) == 100
        @test all(s3 .≈ 1.5)
        
        # Test Bernoulli
        s4 = sed(distribution=Bernoulli, probability=0.7)
        dist!(s4, 1000)
        @test length(s4) == 1000
        @test isapprox(mean(s4), 0.7, atol=0.05)
    end
    
    @testset "Random vs Deterministic" begin
        # Test deterministic (default)
        s1 = sed(distribution=Uniform, min=0.0, max=1.0)
        dist!(s1, 5)
        expected = [0.1, 0.3, 0.5, 0.7, 0.9]
        @test isapprox(s1.data, expected, atol=0.05)
        
        # Test random (should give different results each time)
        s2 = sed(distribution=Uniform, min=0.0, max=1.0, random=true)
        dist!(s2, 100)
        dist!(s1, 100)
        @test s1.data != s2.data  # Very unlikely to be the same
    end
    
    @testset "Normalization" begin
        s = sed(distribution=Uniform, min=1.0, max=2.0, normalize=true)
        dist!(s, 10)
        @test sum(s) ≈ 1.0
    end
    
    @testset "Simple Dependencies" begin
        # Create a context with base variables
        x = sed(distribution=Uniform, min=1.0, max=2.0)
        y = sed(distribution=Uniform, min=0.5, max=1.5)
        context = (N=10, x=x, y=y)
        
        # Create a dependent SED (z = 2*x + 3*y)
        z = sed(
            distribution=Uniform, 
            min=0.0, 
            max=1.0,
            dependent=(x=2.0, y=3.0)
        )
        
        # Generate distributions
        dist!(context, 10)
        
        # Verify dependency calculation
        expected_z = 2.0 .* x.data .+ 3.0 .* y.data
        @test z.data ≈ expected_z .+ z.data
    end
    
    @testset "Complex Dependencies" begin
        # Create base variables
        x = sed(distribution=Uniform, min=1.0, max=2.0)
        y = sed(distribution=Uniform, min=0.5, max=1.5)
        context = (N=10, x=x, y=y)
        
        # Create a complex dependency with custom function
        z = sed(
            distribution=Uniform, 
            min=0.0, 
            max=1.0,
            dependent=(
                x=1.0, 
                y=1.0, 
                fun=(dep -> dep.x .* dep.y ./ (dep.x .+ dep.y))
            )
        )
        
        # Generate distributions
        dist!(context, 10)
        
        # Verify calculation
        expected_contrib = x.data .* y.data ./ (x.data .+ y.data)
        @test z.data ≈ z.data .+ expected_contrib
    end
    
    @testset "Context-based Generation" begin
        # Create a context with multiple SEDs
        context = (
            N = 100,
            x = sed(distribution=LogNormal, median=1.0, sigma=0.5),
            y = sed(distribution=Uniform, min=0.5, max=1.5),
            z = sed(
                distribution=Uniform, 
                min=0.0, 
                max=1.0,
                dependent=(x=2.0, y=0.5)
            )
        )
        
        # Generate all distributions
        dist!(context, 100)
        
        # Check that all distributions were generated
        @test length(context.x) == 100
        @test length(context.y) == 100
        @test length(context.z) == 100
        
        # Verify dependencies were applied
        expected_z_contrib = 2.0 .* context.x.data .+ 0.5 .* context.y.data
        base_z = context.z.data .- expected_z_contrib
        @test all(0.0 .<= base_z .<= 1.0)
        
        # Generate for specific parameter
        new_x = sed(distribution=LogNormal, median=2.0, sigma=0.3)
        new_context = merge_contexts(context, (x=new_x,))
        dist!(new_context, :x)
        @test length(new_context.x) == 100
        @test isapprox(median(new_context.x), 2.0, atol=0.1)
    end
end