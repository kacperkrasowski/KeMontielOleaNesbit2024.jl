using KernelDensity
using Plots
using Statistics

function plot_result(H_diff_percent, lambda_lower_percent, lambda_upper_percent,
                     density_type::String, x_lims::Tuple, y_lims::Tuple,
                     x_label::String, save_fig_name::String)

    # Estimate kernel density
    kde_H_diff     = kde(H_diff_percent)
    kde_lambda_low = kde(lambda_lower_percent)
    kde_lambda_up  = kde(lambda_upper_percent)

    # Compute quantiles for robust credible set markers
    q025 = quantile(lambda_lower_percent, 0.025)
    q975 = quantile(lambda_upper_percent, 0.975)

    # Create legend labels based on density_type
    if density_type == "Posterior"
        label1 = "Posterior density"
        label2 = "Posterior density of lower and upper bounds"
        label3 = "95% robust credible set"
    else
        label1 = "Prior density"
        label2 = "Alternative prior density"
        label3 = "95% credible set"
    end

    # Build the plot
    p = plot(kde_H_diff.x, kde_H_diff.density,
             color=:blue, linewidth=1, label=label1)
    vline!(p, [mean(H_diff_percent)], linestyle=:dash, color=:blue, label="")

    plot!(p, kde_lambda_low.x, kde_lambda_low.density,
          color=:red, linewidth=1, label=label2)
    vline!(p, [mean(lambda_lower_percent)], linestyle=:dot, linewidth=0.5, color=:red, label="")

    plot!(p, kde_lambda_up.x, kde_lambda_up.density,
          color=:red, linewidth=1, label="")
    vline!(p, [mean(lambda_upper_percent)], linestyle=:dot, linewidth=0.5, color=:red, label="")

    scatter!([q025, q975], [0, 0],
             marker=:pentagon, color=:red, markersize=6, markerstrokewidth=0,
             label=label3)

    # Set plot limits and labels
    #xlims!(p, x_lims)
    #ylims!(p, y_lims)
    xlabel!(p, x_label)
    ylabel!(p, "$(density_type) Density")

    # Configure legend without a box (turn off the legend border)
    plot!(p, legend=:topleft, legendfontsize=10, legend_border=false, foreground_color_legend = nothing, background_color_legend = nothing)

    savefig(p, joinpath(PLOT_PATH, "$(save_fig_name).png"))
end
