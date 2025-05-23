using Distributions, Statistics, Plots

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
    credible_set90_range(N, I_sim)

Generates 90% robust credible intervals for the function `lambda_example` using simulation draws.
"""
function credible_set90_range(N::Int, I_sim::Int)
    n11 = 0:N
    n22 = N ÷ 2
    alpha = 0.05

    post_mean_h = zeros(N + 1)
    quantile_alpha = zeros(N + 1)

    for n_1 in 1:(N+1)
        p1 = rand(Beta(n11[n_1]+1, N - n11[n_1] + 1), I_sim)
        p2 = rand(Beta(N - n22 + 1, n22 + 1), I_sim)

        lambda = [lambda_example(p1[i], p2[i]) for i in 1:I_sim]

        post_mean_h[n_1] = mean(lambda)
        quantile_alpha[n_1] = quantile(lambda, alpha)
    end

    x = n11 ./ N
    a = plot(
        x, quantile_alpha,
        linestyle = :dash, marker = :none, color = :blue, label = "Lower Bound of 90% Robust Credible Set"
    )
    plot!(x, ones(N + 1), linestyle = :dash, marker = :utriangle, color = :red, label = "Largest Posterior Mean")
    plot!(x, post_mean_h, linestyle = :solid, marker = :v, color = :blue, label = "Smallest Posterior Mean")

    xlims!(0, 1)
    ylims!(0.48, 1)
    xticks!(0:0.1:1)
    yticks!(0.5:0.1:1)

    xlabel!(L"$n_{11}/N$")
    ylabel!(L"$E[ \lambda(B,\Theta) \: | \: C]$")
    Plots.title!("Credible Set 90% Range, N = $N")
    plot!(legend =:top, foreground_color_legend = nothing, background_color_legend = nothing)

    savefig(joinpath(PLOT_PATH,"CredibleSet90_Range_N$(N).png"))
end
