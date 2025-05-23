include(joinpath(@__DIR__, "preprocessing", "estimation_and_nmf.jl"))
include("CONSTANT.jl")

const K = 40
const D = 148
const V1 = 200
const V2 = 150
const eps = 1e-2
const T = 120
"""
    gen_NMF()

Runs the full NMF draw generation pipeline. It:
- Estimates OnlineLDA for FOMC1 and FOMC2
- Draws posterior B and Θ samples
- Applies NMF
- Saves all outputs into the `NMF_draws_folder`

Includes both posterior and prior-based NMF draw scenarios.
"""
function gen_NMF()
    save_folder = joinpath(NMF_draws_folder, "posterior_alpha_1.25_beta_0.025") #nmf folder needs to be specified
    _, _, gamma1, lam1, _, _ = vb_estimate("FOMC1"; onlyTF=true, K=K, alpha=1.25, eta=0.025, random_seed=random_seed)
    _, _, gamma2, lam2, _, _ = vb_estimate("FOMC2"; onlyTF=true, K=K, alpha=1.25, eta=0.025, random_seed=random_seed)
    algo1_only_store_draws(gamma1, lam1, gamma2, lam2, eps, T, save_folder; post_draw_num=5, beta=0.5, random_seed=random_seed)

    save_folder = joinpath(NMF_draws_folder, "prior_alpha_1.25_beta_0.025")
    gamma1 = ones(D, K) .* 1.0
    lam1 = ones(K, V1) .* 0.025
    gamma2 = ones(D, K) .* 1.25
    lam2 = ones(K, V2) .* 0.025
    algo1_only_store_draws(gamma1, lam1, gamma2, lam2, eps, 200, save_folder; post_draw_num=5, beta=0.5, random_seed=random_seed)

    #save_folder = joinpath(NMF_draws_folder, "posterior_alpha_1_beta_1")
    #_, _, gamma1, lam1, _, _ = vb_estimate("FOMC1"; onlyTF=true, K=K, alpha=1.0, eta=1.0, random_seed=random_seed)
    #_, _, gamma2, lam2, _, _ = vb_estimate("FOMC2"; onlyTF=true, K=K, alpha=1.0, eta=1.0, random_seed=random_seed)
    #algo1_only_store_draws(gamma1, lam1, gamma2, lam2, eps, T, save_folder; post_draw_num=200, beta=0.5, random_seed=random_seed)

    #save_folder = joinpath(NMF_draws_folder, "prior_alpha_1_beta_1")
    #gamma1 = ones(D, K)
    #lam1 = ones(K, V1)
    #gamma2 = ones(D, K)
    #lam2 = ones(K, V2)
    #algo1_only_store_draws(gamma1, lam1, gamma2, lam2, eps, 200, save_folder; post_draw_num=200, beta=0.5, random_seed=random_seed)
end


