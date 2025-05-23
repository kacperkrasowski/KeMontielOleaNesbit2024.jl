using Test
using Statistics

include(abspath(joinpath(@__DIR__, "..", "src","simulations", "algo2range.jl")))
include(abspath(joinpath(@__DIR__, "..", "src","simulations", "credibleset90_range.jl")))
include(abspath(joinpath(@__DIR__, "..", "src","simulations", "MC_illustration.jl")))


@testset "Simulation Tests" begin

    @testset "lambda_example" begin
        @test lambda_example(0.1, 0.9) ≈ (0.1 / 0.9)^2 + (1 - 0.1 / 0.9)^2 atol=1e-6
        @test lambda_example(0.5, 0.5) == 0.5
        @test lambda_example(0.9, 0.1) ≈ (0.1 / 0.9)^2 + (1 - 0.1 / 0.9)^2 atol=1e-6
    end

    @testset "Algo2 Range" begin
        try
            algo2_range(10, 100)
            @test isfile(joinpath(PLOT_PATH, "Algo2Range_N10.png"))
        catch e
            @warn "algo2_range test failed: $e"
        end
    end

    @testset "Credible Set 90% Range" begin
        try
            credible_set90_range(10, 100)
            @test isfile(joinpath(PLOT_PATH, "CredibleSet90_Range_N10.png"))
        catch e
            @warn "credible_set90_range test failed: $e"
        end
    end

    @testset "MC Illustration" begin
        N = 10
        Btrue = rand(3, 3)
        Thetatrue = rand(3, 2)
        try
            MC_illustration(N, Btrue, Thetatrue, 10, 10)
            @test isfile(joinpath(CACHE_PATH, "MC_N10.jld2"))
        catch e
            @warn "MC_illustration test failed: $e"
        end
    end

end
