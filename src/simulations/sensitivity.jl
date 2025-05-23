include(joinpath(@__DIR__, "..", "CONSTANT.JL"))

using Plots
using LaTeXStrings

function plot_sensitivity(N)
    n11 = 0:N
    aux = (n11 .+ 1) ./ (N + 2)
    post_mean_h = 1 .- (2 .* aux .* (1 .- aux) .* (1 .- (1 / (N + 3))))

    π1 = fill(1.0, length(n11))

    p = plot(n11 ./ N, π1,
        linestyle = :dash, marker = :x, color = :red, label = L"\pi_1")
    plot!(p, n11 ./ N, post_mean_h,
        linestyle = :dot, marker = :star5, color = :blue, label = L"\pi_2")

    xlims!(0, 1)
    ylims!(0.5, 1)
    xticks!(0:0.1:1)
    yticks!(0.5:0.1:1)

    xlabel!(L"n_{11}/N")
    ylabel!(L"E[ \lambda(B,\Theta) \: | \: C]")
    plot!(legend = :top, legendfontsize = 12, legendtitle = nothing)

    savefig(p, joinpath(PLOT_PATH,"Sensitivity_N$(N).png"))
    return p
end

