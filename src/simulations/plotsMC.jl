using Plots
using LaTeXStrings
using StatsPlots
using JLD2
include(abspath(joinpath(@__DIR__, "..", "CONSTANT.jl")))
function PlotsMC(N10::Dict, N1000::Dict)
    ## Plot 1: Overlay Frequentist Estimators for N=10 and N=1000
    plt1 = plot(title="Frequentist Estimators", legend=:topright)
    vline!(plt1, [N1000["lower_bound_true"]], linestyle=:dot, color=:red, linewidth=2, label=L"\underline{\lambda}^*(p^0_1,p^0_2)")
    histogram!(plt1, N10["frequentist_estimator"], normalize=:pdf, label="N=10", alpha=0.5)
    histogram!(plt1, N1000["frequentist_estimator"], normalize=:pdf, label="N=1000", alpha=0.5)
    xlims!(plt1, 0.5, 1.0)
    ylims!(plt1, 0, 0.5)
    xlabel!(plt1, L"\underline{\lambda}^*(\widehat{p}_1,\widehat{p}_2)")
    savefig(plt1, joinpath(PLOT_PATH,"Freq_MC.png"))

    ## Plot 2: Robust Bayesian Estimators
    plt2 = plot(title="Robust Bayesian Estimators", legend=:topright)
    vline!(plt2, [N1000["lower_bound_true"]], linestyle=:dot, color=:red, linewidth=2, label=L"\underline{\lambda}^*(p^0_1,p^0_2)")
    histogram!(plt2, N10["robust_bayesian_estimator"], normalize=:pdf, label="N=10", alpha=0.5)
    histogram!(plt2, N1000["robust_bayesian_estimator"], normalize=:pdf, label="N=1000", alpha=0.5)
    xlims!(plt2, 0.5, 1.0)
    ylims!(plt2, 0, 0.5)
    xlabel!(plt2, L"E \left[ \: {\lambda}^*(p_1,p_2) \: | \: C \right]")
    savefig(plt2, joinpath(PLOT_PATH,"Robust_MC.png"))

end
