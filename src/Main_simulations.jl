using LinearAlgebra
include(joinpath(@__DIR__, "CONSTANT.jl"))
include(joinpath(@__DIR__, "simulations", "sensitivity.jl"))
include(joinpath(@__DIR__, "simulations", "range.jl"))
include(joinpath(@__DIR__, "simulations", "algo2range.jl"))
include(joinpath(@__DIR__, "simulations", "credibleset90_range.jl"))
include(joinpath(@__DIR__, "simulations", "MC_illustration.jl"))
include(joinpath(@__DIR__, "simulations", "plotsMC.jl"))
"""
    simulation_plots()

Runs all simulation visualizations:
- Algorithm 2 range plots
- Robust credible set plots
- Monte Carlo illustrations

Each plot is saved as a PNG in `PLOT_PATH`.
"""
function simulation_plots()
    plot_sensitivity(10)
    plot_sensitivity(100)

    range_posterior_means(10, 1000)
    algo2_range(10, 1000)
    credible_set90_range(10, 1000)

    range_posterior_means(100, 1000)
    algo2_range(100, 1000)
    credible_set90_range(100, 1000)

    Btrue = Matrix{Float64}(I, 2, 2)
    Thetatrue = [0.2 0.8; 0.8 0.2]

    MC_draws = 1000
    Posterior_draws = 1000

    N = 10
    MC_illustration(N, Btrue, Thetatrue, MC_draws, Posterior_draws)

    N = 1000
    MC_illustration(N, Btrue, Thetatrue, MC_draws, Posterior_draws)

    N10 = load(joinpath(CACHE_PATH,"MC_N10.jld2"))
    N1000 = load(joinpath(CACHE_PATH,"MC_N1000.jld2"))

    PlotsMC(N10, N1000)
end

simulation_plots()