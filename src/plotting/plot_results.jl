using Plots
using KernelDensity
using Statistics
include(joinpath(@__DIR__, "compute_functional_from_nmf_draws.jl"))

function plot_result(H_diff_percent::Vector{Float64},
                     lambda_lower_percent::Vector{Float64},
                     lambda_upper_percent::Vector{Float64},
                     density_type::String,
                     x_lims::Tuple{Float64, Float64},
                     y_lims::Tuple{Float64, Float64},
                     x_label::String,
                     save_fig_name::String)

    # KDEs
    kde_H = kde(H_diff_percent)
    kde_lower = kde(lambda_lower_percent)
    kde_upper = kde(lambda_upper_percent)

    # Start plotting
    plt = plot(kde_H.x, kde_H.density, label="", linewidth=2, color=:blue)
    plot!(plt, kde_lower.x, kde_lower.density, label="", linewidth=2, color=:red)
    plot!(plt, kde_upper.x, kde_upper.density, label="", linewidth=2, color=:red)

    # Vertical lines at means
    vline!(plt, [mean(H_diff_percent)], linestyle=:dash, color=:blue)
    vline!(plt, [mean(lambda_lower_percent)], linestyle=:dot, color=:red, linewidth=1)
    vline!(plt, [mean(lambda_upper_percent)], linestyle=:dot, color=:red, linewidth=1)

    # Credible set markers (2.5% and 97.5% quantiles)
    scatter!(plt, [quantile(lambda_lower_percent, 0.025)], [0],
             marker=:pentagon, markersize=8, color=:red, label="")
    scatter!(plt, [quantile(lambda_upper_percent, 0.975)], [0],
             marker=:pentagon, markersize=8, color=:red, label="")

    # Set labels and limits
    xlabel!(plt, x_label)
    ylabel!(plt, "$density_type Density")
    #xlims!(plt, x_lims)
    #ylims!(plt, y_lims)

    # Legend
    if density_type == "Posterior"
        label1 = "Posterior density λ(B,Θ)"
        label2 = "Posterior density of λ̲*, λ̅*"
        label3 = "95% robust credible set"
    else
        label1 = "Prior density λ(B,Θ)"
        label2 = "Alternative prior density for λ(B,Θ)"
        label3 = "95% credible set"
    end

    plot!(plt, legend=:topleft, label=[label1 label2 label3])

    # Save figure as PNG
    savefig(plt, joinpath(PLOT_PATH, "$(save_fig_name).png"))
end
