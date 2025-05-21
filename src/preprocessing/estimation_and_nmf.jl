using Random
using Distributions
using XLSX
using JSON
using LinearAlgebra
using MAT

config_path = abspath(joinpath(@__DIR__, "..", "CONSTANT.jl"))
config_path2 = abspath(joinpath(@__DIR__, "..", "onlineldavb.jl"))
include(config_path)
include(config_path2)
function read_json(file)
    open(file,"r") do f
        return JSON.parse(f)
    end
end
function  sample_dirichlet(alpha::Matrix{Float64})
    n,k = size(alpha)
    res = Matrix{Float64}(undef,n,k)
    for i in 1:n
        res[i,:] = rand(Dirichlet(alpha[i,:]))
    end
    res
end

function vb_estimate(section::String; onlyTF::Bool=true, K::Int=40, alpha::Float64=0.025,
    eta::Float64=0.025, tau::Float64=1024.0, kappa::Float64=0.7,
    docs_idx_list::Union{Nothing, Vector{Int}}=nothing, random_seed::Int=0)

    println("VB Estimation for $section")
    suffix = onlyTF ? "_onlyTF" : ""
    dict_path = joinpath(MATRIX_PATH, section * "_dictionary_meeting$(suffix).xlsx")
    vocab_11 = XLSX.readxlsx(dict_path) #[:,1] might be necessery
    words = vocab_11["Sheet1"][2:end,1]
    vocab_1 = collect(String.(words)) # might be a problem with the Int motherfucker
    println(vocab_1)

    text_path = joinpath(MATRIX_PATH, section * "_text$(suffix).json")
    text = read_json(text_path)


    text1 = [join(doc, " ") for doc in text] 
    
    if docs_idx_list !== nothing
        text1 = [text1[i] for i in 1:length(text1) if i in docs_idx_list]
    end
    
    D = length(text1)
    olda = OnlineLDA(vocab_1, K, D, alpha, eta, tau, kappa,1)
    gamma, bound = update_lambda(olda, text1)

    posterior_mean = gamma ./ sum(gamma, dims=1)
    herfindahl = sum(posterior_mean .^ 2, dims=1)
    return herfindahl, posterior_mean, gamma, olda.lambda, olda, text1

end
vb_estimate("FOMC1")

function find_NMF_given_solution(B_init::Matrix{Float64}, Theta_init::Matrix{Float64}, 
    beta::Float64, T::Int, eps::Float64; 
    maxit::Int=100000, verbose::Bool=false, random_seed::Int=0)
    function A(i::Int, j::Int, λ::Float64, K::Int)
        a = Matrix{Float64}(I,K,K)
        a[i,i] = 1 - λ
        a[j,i] = λ
        return a
    end

    K = size(B_init, 2)

    B_store = [B_init]
    Theta_store = [Theta_init]

    for s in 1:maxit
        B = B_store[s]
        Theta = Theta_store[s]

        for i in 1:K
            idx = setdiff(1:K, [1])
            j = rand(idx)

            denom = Theta[i, :] .+ Theta[j, :]
            valid = denom .> 0
           
            λ_max_arr = (Theta[j, :] ./ denom)
            λ_max_arr[.!valid] .= Inf
            λ_max_arr = (Theta[j, :] ./ denom)

            λ_max = minimum(λ_max_arr)

            denom2 = B[:, i] .- B[:, j]
            valid2 = B[:, j] .> B[:, i]
            λ_min_arr = (B[:, i] ./ denom2)
            λ_min_arr[.!valid2] .= -Inf
            λ_min = maximum(λ_min_arr)

            x = rand(Beta(beta))
            λ = x * λ_max + (1 - x) * λ_min
            
            A_mat = A(i, j, λ, K)
            B = B * A_mat
            Theta = A(i, j, -λ / (1 - λ), K) * Theta
        end

        push!(B_store, B)
        push!(Theta_store, Theta)

        if s > T
            B_stack = cat(B_store..., dims=3)
            B_max_S = maximum(B_stack, dims=3)[:, :]
            B_min_S = minimum(B_stack, dims=3)[:, :]
            avg_B_chg_S = mean(B_max_S .- B_min_S)

            B_stack_T = cat(B_store[1:end-T]..., dims=3)
            B_max_T = maximum(B_stack_T, dims=3)[:, :]
            B_min_T = minimum(B_stack_T, dims=3)[:, :]
            avg_B_chg_T = mean(B_max_T .- B_min_T)

            if verbose
                println("Iteration $s: avg_B_chg_S - avg_B_chg_T = $(avg_B_chg_S - avg_B_chg_T)")
            end

            if avg_B_chg_S - avg_B_chg_T < eps
                break
            end 
        end
    end
    return B_store, Theta_store
end

function safe_mkdir(path::String)
    isdir(path) || mkpath(path)
end

# Translate algo1_only_store_draws
function algo1_only_store_draws(gamma1::Matrix{Float64}, lam1::Matrix{Float64},
                                 gamma2::Matrix{Float64}, lam2::Matrix{Float64},
                                 eps::Float64, T::Int, save_folder::String;
                                 post_draw_num::Int=200, beta::Float64=0.5, random_seed::Int=0)
    B_Theta_sec1_post_draw_store = Vector{Tuple{Matrix{Float64}, Matrix{Float64}}}()
    B_Theta_sec2_post_draw_store = Vector{Tuple{Matrix{Float64}, Matrix{Float64}}}()

    folders = ["", "FOMC1", "FOMC2", joinpath("FOMC1","NMF_B"), joinpath("FOMC1", "NMF_Theta"), joinpath("FOMC2","NMF_B"), joinpath("FOMC2","NMF_Theta")]
    for sub in folders
        safe_mkdir(joinpath(save_folder, sub))
    end

    for i in 1:post_draw_num
        println("Drawing posterior number $i")
        start = time()

        # Sample B and Theta from Dirichlet
        B1 = sample_dirichlet(lam1)'
        B2 = sample_dirichlet(lam2)'
        
        Theta1 = sample_dirichlet(gamma1)'
        Theta2 = sample_dirichlet(gamma2)'

        B_list_1, Theta_list_1 = find_NMF_given_solution(B1, Theta1, beta, T, eps, random_seed=random_seed)
        B_list_2, Theta_list_2 = find_NMF_given_solution(B2, Theta2, beta, T, eps, random_seed=random_seed)

        push!(B_Theta_sec1_post_draw_store, (B1, Theta1))
        push!(B_Theta_sec2_post_draw_store, (B2, Theta2))

        # Save .mat files
        matwrite(joinpath(save_folder, "FOMC1", "NMF_B", "NMF_sec1_B_draw$(i).mat"), Dict("B_list" => B_list_1))
        matwrite(joinpath(save_folder, "FOMC2", "NMF_B", "NMF_sec2_B_draw$(i).mat"), Dict("B_list" => B_list_2))
        matwrite(joinpath(save_folder, "FOMC1", "NMF_Theta", "NMF_sec1_Theta_draw$(i).mat"), Dict("Theta_list" => Theta_list_1))
        matwrite(joinpath(save_folder, "FOMC2", "NMF_Theta", "NMF_sec2_Theta_draw$(i).mat"), Dict("Theta_list" => Theta_list_2))

        elapsed = time() - start
        println("Finished posterior draw $i. Time: $(elapsed)s")
    end

    matwrite(joinpath(save_folder, "B_Theta_post_draws_sec1.mat"), Dict("post_draws_B_Theta" => B_Theta_sec1_post_draw_store))
    matwrite(joinpath(save_folder, "B_Theta_post_draws_sec2.mat"), Dict("post_draws_B_Theta" => B_Theta_sec2_post_draw_store))
end

function store_posterior_draws(gamma::Matrix{Float64}, lam::Matrix{Float64},
    post_draw_num::Int, save_folder::String, cache_name::String)

    B_Theta_post_draw_store = Vector{Tuple{Matrix{Float64}, Matrix{Float64}}}()

    isdir(save_folder) || mkpath(save_folder)

    for i in 1:post_draw_num
        println("Drawing posterior number $i")
        B = sample_dirichlet(lam)'
        Theta = _ample_dirichlet(gamma)'
        push!(B_Theta_post_draw_store, (B, Theta))
    end
    post_draw_array = Any[B_Theta_post_draw_store[i] for i in 1:post_draw_num]

    matwrite(joinpath(save_folder, "$cache_name.mat"),
             Dict("post_draws_B_Theta" => post_draw_array))
end
