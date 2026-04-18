# Test Layers.jl

include("../src/model/params/Layers.jl")

using Test

import .Layers

# Helpers

function default_layers()
    return Layers.LayerScheme([5.0, 5.0, 10.0])
end

@testset "Layers" begin
    l = default_layers()

    # Basic Construction tests
    @testset "Construction" begin
        
        @testset "Valid layers build" begin
            @test l.nlayers == 3
            @test l.z1[1] == 0.0
            @test l.z2[1] == 5.0
            @test l.zmid[1] == 2.5
            @test l.dz[1] == 5.0
            
            @test l.z1[2] == 5.0
            @test l.z2[2] == 10.0
            @test l.zmid[2] == 7.5
            @test l.dz[2] == 5.0

            @test l.z1[3] == 10.0
            @test l.z2[3] == 20.0
            @test l.zmid[3] == 15.0
            @test l.dz[3] == 10.0
        end

        @testset "Reject non-positive layer depths" begin           
            @test_throws DomainError Layers.LayerScheme([0.0, 5.0, 10.0])
            @test_throws DomainError Layers.LayerScheme([5.0, 5.0, 0.0])
            @test_throws DomainError Layers.LayerScheme([5.0, -1.0, 5.0])
        end   
    end
    @testset "Functions" begin
        @testset "index_from_depth()" begin
            @test Layers.index_from_depth(l, 0) == 1
            @test Layers.index_from_depth(l, 2.5) == 1
            @test Layers.index_from_depth(l, 5.0) == 1
            @test Layers.index_from_depth(l, 5.0001) == 2
            @test Layers.index_from_depth(l, 10.0) == 2
            @test Layers.index_from_depth(l, 20) == 3
        end

        @testset "Reject non-positive layer depths" begin           
            @test_throws DomainError Layers.index_from_depth(l, -1)
            @test_throws DomainError Layers.index_from_depth(l, 20.001)
        end
    end

end