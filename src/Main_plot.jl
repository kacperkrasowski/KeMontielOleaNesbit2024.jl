include(joinpath(@__DIR__, "CONSTANT.jl"))
include(joinpath(@__DIR__, "plotting", "compute_functional_from_nmf_draws.jl"))
include(joinpath(@__DIR__, "plotting", "plot_results.jl"))
"""
    do_plots()

Generates all plots related to NMF posterior means and functional measures.
Assumes that NMF output has already been generated and saved.
"""
function do_plots()
    FOMC_sec = 1
    func = HHI_percent_diff  # no @ needed unless using anonymous functions or macros
    prior_posterior_spec = "prior_alpha_1.25_beta_0.025"

    # Construct paths
    prior_post_draw_name = joinpath(NMF_draws_folder, prior_posterior_spec, "B_Theta_post_draws_sec1.jld2")
    NMF_draw_folder_name = joinpath(NMF_draws_folder, prior_posterior_spec, "FOMC1", "NMF_Theta")

    # Plot settings
    x_lims = (15.0, 45.0)
    y_lims = (0.0, 0.45)
    x_label = "%"
    density_type = "Prior"
    save_fig_name = "$(prior_posterior_spec)_percent_diff"

    println(save_fig_name)

    # Compute functional
    H_diff_percent, lambda_lower_percent, lambda_upper_percent = compute_functional_from_nmf_draws(
        FOMC_sec,
        func,
        prior_post_draw_name,
        NMF_draw_folder_name
    )

    # Plot the result
    plot_result(H_diff_percent, lambda_lower_percent, lambda_upper_percent,
                density_type, x_lims, y_lims, x_label, save_fig_name)



    FOMC_sec = 1
    func = HHI_percent_diff  # no @ needed unless using anonymous functions or macros
    prior_posterior_spec = "posterior_alpha_1.25_beta_0.025"

    # Construct paths
    prior_post_draw_name = joinpath(NMF_draws_folder, prior_posterior_spec, "B_Theta_post_draws_sec1.jld2")
    NMF_draw_folder_name = joinpath(NMF_draws_folder, prior_posterior_spec, "FOMC1", "NMF_Theta")

    # Plot settings
    x_lims = (15.0, 45.0)
    y_lims = (0.0, 0.45)
    x_label = "%"
    density_type = "Posterior"
    save_fig_name = "$(prior_posterior_spec)_percent_diff"

    println(save_fig_name)

    # Compute functional
    H_diff_percent, lambda_lower_percent, lambda_upper_percent = compute_functional_from_nmf_draws(
        FOMC_sec,
        func,
        prior_post_draw_name,
        NMF_draw_folder_name
    )
    plot_result(H_diff_percent, lambda_lower_percent, lambda_upper_percent,
                density_type, x_lims, y_lims, x_label, save_fig_name)
end
