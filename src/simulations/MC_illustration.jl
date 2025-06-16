using Distributions, Random, Statistics, JLD2
include(abspath(joinpath(@__DIR__, "..", "CONSTANT.jl")))


function lambda_example(p1::Float64, p2::Float64)
    @assert 0 ≤ p1 ≤ 1 "p1 must be in [0, 1]"
    @assert 0 ≤ p2 ≤ 1 "p2 must be in [0, 1]"

    if p2 > 2 * p1
        aux = p1 / p2
        return aux^2 + (1 - aux)^2
    elseif p2 < (2 * p1) - 1
        aux = (1 - p1) / (1 - p2)
        return aux^2 + (1 - aux)^2
    else
        return 0.5
    end
end

function MC_illustration(N::Int, Btrue::Matrix{Float64}, Thetatrue::Matrix{Float64},
                         MC_draws::Int, Posterior_draws::Int)

    # True parameters
    Ptrue = Btrue * Thetatrue
    p1_true = Ptrue[1, 1]
    p2_true = Ptrue[1, 2]
    H_true = sum(Thetatrue[:, 1].^2)

    # Identified set bounds
    upper_bound_true = 1.0
    lower_bound_true = lambda_example(p1_true, p2_true)

    # Monte Carlo setup
    Random.seed!(1234)
    n1 = rand.(Binomial(N, p1_true), MC_draws)
    n2 = N .- rand.(Binomial(N, p2_true), MC_draws)

    frequentist_estimator = zeros(MC_draws)
    robust_bayesian_estimator = zeros(MC_draws)

    for i in 1:MC_draws
        p1_hat = n1[i] / N
        p2_hat = 1 - (n2[i] / N)
        frequentist_estimator[i] = lambda_example(p1_hat, p2_hat)

        # Bayesian estimator
        p1post = rand(Beta(n1[i] + 1, N - n1[i] + 1), Posterior_draws)
        p2post = rand(Beta(N - n2[i] + 1, n2[i] + 1), Posterior_draws)

        lambda_post = lambda_example.(p1post, p2post)
        robust_bayesian_estimator[i] = mean(lambda_post)
    end



    # Save variables using JLD2
    file_name = joinpath(CACHE_PATH, "MC_N$(N).jld2")
    @save file_name frequentist_estimator robust_bayesian_estimator N lower_bound_true
end