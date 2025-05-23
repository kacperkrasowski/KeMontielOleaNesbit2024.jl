using JLD2, CSV, DataFrames, Statistics
config_path = abspath(joinpath(@__DIR__, "..", "CONSTANT.jl"))
include(config_path)
function HHI_percent_diff(H_index_NMF::Vector{Float64}, dummy_transp::Vector{Int}, regressors)
    H_index_pre = mean(H_index_NMF[dummy_transp .== 0])
    H_index_post = mean(H_index_NMF[dummy_transp .== 1])
    return 100 * (H_index_post - H_index_pre) / H_index_pre
end
"""
    compute_functional_from_nmf_draws(FOMC_sec, func, prior_post_draw_name, NMF_draw_folder_name)

Computes a statistic over the posterior NMF draws for a specific FOMC section.

# Arguments
- `FOMC_sec`: 1 or 2
- `func`: a function (e.g. HHI_percent_diff) to apply on Herfindahl indices
- `prior_post_draw_name`: path to posterior draw `.jld2` file
- `NMF_draw_folder_name`: path to folder with NMF iteration draws

# Returns
- `H_diff_percent`: average percent change for each draw
- `lambda_lower_percent`, `lambda_upper_percent`: lower/upper bounds from NMF path draws
"""
function compute_functional_from_nmf_draws(FOMC_sec::Int, func, prior_post_draw_name::String, NMF_draw_folder_name::String)
    draws = JLD2.load(prior_post_draw_name)
    #println(draws_B_Theta)
    draws_B_Theta = draws["post_draws_B_Theta"]
    
    df = CSV.read(joinpath(UTILFILE_PATH,"covariates.csv"), DataFrame) # add the proper path

    dummy_transp = df.Transparency

    if FOMC_sec == 1
        regressors = select(df, Not(["Dates"])) |> Matrix
    else
        regressors = select(df, Not(["Dates"])) |> Matrix
    end

    H_diff_percent = zeros(length(draws_B_Theta))

    for i_draw in 1:length(draws_B_Theta)
        Theta_draw = draws_B_Theta[i_draw][2]  # second column of cell
        HHI_draw = sum(Theta_draw.^2, dims=1) |> vec
        H_diff_percent[i_draw] = func(HHI_draw, dummy_transp, regressors)
    end

    lambda_lower_percent = zeros(length(draws_B_Theta))
    lambda_upper_percent = zeros(length(draws_B_Theta))

    for i_draw in 1:length(draws_B_Theta)
        file_name = FOMC_sec == 1 ?
            joinpath(NMF_draw_folder_name, "NMF_sec1_Theta_draw$(i_draw).jld2") :
            joinpath(NMF_draw_folder_name, "NMF_sec2_Theta_draw$(i_draw).jld2")

        jld_obj = JLD2.load(file_name)
        ThetaNMF = jld_obj["Theta_list"]  # Vector{Matrix{Float64}}

        sizeNMF = min(120, length(ThetaNMF))
        H_index_robust_percent = zeros(sizeNMF)

        for j_NMF in 1:sizeNMF
            Theta_draw = ThetaNMF[j_NMF]  # already Matrix{Float64} of shape 40×148
            H_index_NMF = sum(Theta_draw.^2, dims=1) |> vec
            H_index_robust_percent[j_NMF] = func(H_index_NMF, dummy_transp, regressors)
        end

        lambda_lower_percent[i_draw] = minimum(H_index_robust_percent)
        lambda_upper_percent[i_draw] = maximum(H_index_robust_percent)
    end
    return H_diff_percent, lambda_lower_percent, lambda_upper_percent
end

