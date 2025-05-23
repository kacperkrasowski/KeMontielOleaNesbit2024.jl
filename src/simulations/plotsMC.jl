using Plots
using LaTeXStrings
using Statistics

function PlotsMC(data10::Dict, data1000::Dict)

    f10 = data10["frequentist_estimator"]
    f1000 = data1000["frequentist_estimator"]
    r10 = data10["robust_bayesian_estimator"]
    r1000 = data1000["robust_bayesian_estimator"]
    lower_bound = data1000["lower_bound_true"]

    bins = 20
    #xrange = (0.5, 1.0)
    #ylims = (0.0, 0.5)

    ## Plot 1: Frequentist estimators
    p1 = plot(legend=:topright)
    vline!(p1, [lower_bound], linestyle=:dot, linewidth=2, color=:red, label=L"\lambda^*(p^0_1, p^0_2)")
    histogram!(p1, f10, bins=bins, alpha=0.5, color=:blue, label=L"N=10")
    histogram!(p1, f1000, bins=bins, alpha=0.6, color=:orange, label=L"N=1000")
    xlabel!(p1, L"\lambda^*(\hat{P}_{ML})")

    ## Plot 2: Robust Bayes estimators
    p2 = plot(legend=:topright)
    vline!(p2, [lower_bound], linestyle=:dot, linewidth=2, color=:red, label=L"\lambda^*(p^0_1, p^0_2)")
    
    histogram!(p2, r10, bins=bins, alpha=0.5, color=:blue, label=L"N=10")
    histogram!(p2, r1000, bins=bins, alpha=0.6, color=:orange, label=L"N=1000")
    xlabel!(p2, L"E[\lambda^*(P) | C]")


    savefig(p2, joinpath(PLOT_PATH,"Robust_MC.png"))
    savefig(p1, joinpath(PLOT_PATH,"Freq_MC.png"))

end
