using SocialEconomicDiversity
using Test

@testset "SocialEconomicDiversity.jl" begin
    # Run individual test modules
    include("diversity.jl")
    include("sed_test.jl")
end
