using Distributions, Random, Statistics, JLD2
include(abspath(joinpath(@__DIR__, "..", "CONSTANT.jl")))
function lambda_example(p1::Float64, p2::Float64)::Float64
    if p2 > 2p1
        aux = p1 / p2
        return aux^2 + (1 - aux)^2
    elseif p2 < 2p1 - 1
        aux = (1 - p1) / (1 - p2)
        return aux^2 + (1 - aux)^2
    else
        return 0.5
    end
end
"""
    MC_illustration(N, Btrue, Thetatrue, MC_draws, Posterior_draws)

Simulates frequentist and robust Bayesian estimation over `MC_draws` using true model parameters.
"""
function MC_illustration(N::Int, Btrue::Matrix{Float64}, Thetatrue::Matrix{Float64}, MC_draws::Int, Posterior_draws::Int)
    # True parameters
    Ptrue = Btrue * Thetatrue
    p1_true = Ptrue[1, 1]
    p2_true = Ptrue[1, 2]
    H_true = sum(Thetatrue[:, 1].^2)

    # Identified set for the Herfindahl Index
    upper_bound_true = 1.0
    lower_bound_true = lambda_example(p1_true, p2_true)

    # Monte Carlo Draws
    Random.seed!(1234)  # Equivalent to rng('default')
    n1 = rand(Binomial(N, p1_true), MC_draws)
    n2 = N .- rand(Binomial(N, p2_true), MC_draws)

    frequentist_estimator = zeros(MC_draws)
    robust_bayesian_estimator = zeros(MC_draws)

    for i_MC in 1:MC_draws
        frequentist_estimator[i_MC] = lambda_example(n1[i_MC] / N, 1 - (n2[i_MC] / N))

        # Robust Bayesian Estimator
        p1post = rand(Beta(n1[i_MC] + 1, N - n1[i_MC] + 1), Posterior_draws)
        p2post = rand(Beta(N - n2[i_MC] + 1, n2[i_MC] + 1), Posterior_draws)

        lambda_post = [lambda_example(p1post[i], p2post[i]) for i in 1:Posterior_draws]
        robust_bayesian_estimator[i_MC] = mean(lambda_post)
    end

    # Save variables using JLD2
    file_name = joinpath(CACHE_PATH, "MC_N$(N).jld2")
    @save file_name frequentist_estimator robust_bayesian_estimator N lower_bound_true
end