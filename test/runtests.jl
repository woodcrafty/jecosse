# Unit tests for the ECOSSE module

using Test
using Random

Random.seed!(1234)  # Enable deterministic "random" generation of forcing data for testing expected outcomes

# Unit tests includes
include("test_layers.jl")

@testset "All Tests" begin
    @testset "Unit" begin
        test_layers()
    end
end


