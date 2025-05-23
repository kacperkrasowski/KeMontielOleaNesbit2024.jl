using Distributions
using Plots
using LaTeXStrings

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
"""
    algo2_range(N, I_sim)

Simulates and plots the approximation quality of Algorithm 2 over a range of possible `n11` values.
"""
function algo2_range(N::Int, I_sim::Int)
    n11 = 0:N
    n22 = N ÷ 2

    post_mean_h = zeros(Float64, N + 1)
    algo2 = zeros(Float64, N + 1)

    for (idx, n1) in enumerate(n11)
        p1_dist = Beta(n1 + 1, N - n1 + 1)
        p2_dist = Beta(N - n22 + 1, n22 + 1)

        p1_samples = rand(p1_dist, I_sim)
        p2_samples = rand(p2_dist, I_sim)

        λs = [lambda_example(p1_samples[i], p2_samples[i]) for i in 1:I_sim]
        post_mean_h[idx] = mean(λs)

        algo2[idx] = lambda_example(n1 / N, n22 / N)
    end

    # Plotting
    plot(n11 ./ N, algo2, linestyle=:dash, marker=:circle, color=:blue, label="Approximation (Algorithm 2)")
    plot!(n11 ./ N, fill(1.0, N + 1), linestyle=:dash, marker=:^, color=:red, label="Largest Posterior Mean")
    plot!(n11 ./ N, post_mean_h, linestyle=:solid, marker=:v, color=:blue, label="Smallest Posterior Mean")

    xlims!(0, 1)
    ylims!(0.5, 1)
    xticks!(0:0.1:1)
    yticks!(0.5:0.1:1)

    xlabel!(L"n_{11}/N")
    ylabel!(L"E[ \lambda(B,\Theta) \: | \: C]")

    plot!(legend=:top, legendfontsize=10, legendtitle="", grid=false, foreground_color_legend = nothing, background_color_legend = nothing)

    # Save plot
    savefig(joinpath(PLOT_PATH, "Algo2Range_N$(N).png"))
end