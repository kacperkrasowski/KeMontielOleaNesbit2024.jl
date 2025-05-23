using Test
using XLSX
using JSON
using LinearAlgebra
using JLD2

include(abspath(joinpath(@__DIR__, "..", "src","preprocessing", "estimation_and_nmf.jl")))


@testset "Estimation and NMF Tests" begin

    @testset "NMF Solver" begin
        B_init = rand(3, 3)
        Theta_init = rand(3, 5)
        beta = 0.5
        T = 10
        eps = 1e-3

        B_list, Theta_list = find_NMF_given_solution(B_init, Theta_init, beta, T, eps; maxit=50, verbose=false)

        @test length(B_list) >= 2
        @test size(B_list[end]) == size(B_init)
        @test !any(isnan, B_list[end])
        @test !any(isnan, Theta_list[end])
    end

    @testset "Posterior Sampling" begin
        K, D, V = 5, 4, 6
        gamma1 = rand(D, K)
        gamma2 = rand(D, K)
        lam1 = rand(K, V)
        lam2 = rand(K, V)
        temp_dir = mktempdir()

        algo1_only_store_draws(gamma1, lam1, gamma2, lam2, 1e-2, 5, temp_dir; post_draw_num=2, beta=0.5)

        @test isdir(joinpath(temp_dir, "FOMC1", "NMF_B"))
        @test isfile(joinpath(temp_dir, "FOMC1", "NMF_B", "NMF_sec1_B_draw1.jld2"))
    end

end
