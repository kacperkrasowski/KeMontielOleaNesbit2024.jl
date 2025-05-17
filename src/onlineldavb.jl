using SpecialFunctions
using Random
using Distributions
using LinearAlgebra

meanchangethresh = 0.0001

# psi = digamma
function dirichlet_expectation(alpha::AbstractArray)
    if ndims(alpha) == 1
        return digamma.(alpha) .- digamma(sum(alpha))
    else
        row_sums = sum(alpha, dims=2)
        return digamma.(alpha) .- digamma.(row_sums)
    end
end

function parse_doc_list(docs, vocab)
    if isa(docs, String)
        docs = [docs]
    end
    D = length(docs)
    wordids = []
    wordcts = []
    for d in 1:D
        doc = lowercase(docs[d])
        doc = replace(doc, "-" => " ")
        doc = replace(doc, r"[^a-z ]" => "")
        doc = replace(doc, " +" => " ")
        words = split(doc)

        ddict = Dict()
        for word in words
            if haskey(vocab, word)
                wordtoken = vocab[word]
                ddict[wordtoken] = get(ddict, wordtoken, 0) + 1
            end
            
        end
        push!(wordids, collect(keys(ddict)))
        push!(wordcts, collect(values(ddict)))
        
    end
    return (wordids, wordcts)
end

mutable struct OnlineLDA
    vocab::Dict{String,Int}
    K::Int
    W::Int
    D::Int
    alpha::Float16
    eta::Float64
    tau0::Float64
    kappa::Float64
    updatect::Int
    seed::Int
    lambda::Matrix{Float64}
    Elogbeta::Matrix{Float64}
    expElogbeta::Matrix{Float64}
    rhot::Float64
    
    function OnlineLDA(vocab_raw, K::Int, D::Int, alpha::Float64, eta::Float64, tau0::Float64, kappa::Float64, seed::Int)
        vocab = Dict{String, Int}()
        for word in vocab_raw
            word = lowercase(word)
            word = replace(word, r"[^a-z]" => "")
            if !haskey(vocab, word)
                vocab[word] = length(vocab) + 1
            end
        end

        W = length(vocab)
        lambda = rand(Gamma(100.0, 1/100.0), K, W)
        Elogbeta = dirichlet_expectation(lambda)
        expElogbeta = exp.(Elogbeta)

        new(vocab, K, W, D, alpha, eta, tau0 + 1, kappa, 0, seed, lambda, Elogbeta, expElogbeta, 0.0)
    end

end

function  do_e_step(self::OnlineLDA, docs) # Might be wrong did somekind of random stuff here if the results are weird this is the first suspect
    wordids, wordcts = parse_doc_list(docs, self.vocab)
    batchD = length(docs)
    gamma = rand(Gamma(100.0, 1/100.0), batchD, self.K)
    Elogtheta = dirichlet_expectation(gamma)
    expElogtheta = exp.(Elogtheta)
    sstats = zeros(size(self.lambda))
    for d in 1:batchD
        ids = wordids[d]
        cts = wordcts[d]
        gammad = gamma[d, :]
        Elogthetad = Elogtheta[d, :]
        expElogthetad = expElogtheta[d, :]
        expElogbetad = self.expElogbeta[:, ids]
        phinorm = vec(expElogthetad' * expElogbetad) .+ 1e-100
        for it in 1:2000
            lastgamma = copy(gamma)
            gammad =  self.alpha .+ expElogthetad .* (expElogbetad * (cts ./ phinorm))
            Elogthetad = dirichlet_expectation(gammad)
            expElogthetad = exp.(Elogthetad)
            phinorm = vec(expElogthetad' * expElogbetad) .+ 1e-100

            meanchange = mean(abs.(gamma .- lastgamma))
            if meanchange < meanchangethresh
                break
            end
        end
        gamma[d, :] = gammad
        sstats[:, ids] += expElogthetad * transpose(cts ./ phinorm)

    end
    sstats .= sstats .* self.expElogbeta
    return ((gamma, sstats))
end
gammaln(x) = logabsgamma(x)[1]

function approx_bound(model::OnlineLDA, docs::Vector{String}, gamma::Matrix{Float64})
    wordids, wordcts = parse_doc_list(docs, model.vocab)
    batchD = length(docs)
    
    score = 0.0
    Elogtheta = dirichlet_expectation(gamma)
    expElogtheta = exp.(Elogtheta)

    for d in 1:batchD
        gammad = gamma[d, :]
        ids = wordids[d]
        cts = collect(wordcts[d])
        phinorm = zeros(length(ids))
        for i in 1:length(ids)
            temp = Elogtheta[d, :] .+ model.Elogbeta[:, ids[i]]
            tmax = maximum(temp)
            phinorm[i] = log(sum(exp.(temp .- tmax))) + tmax
        end
        score += sum(cts .* phinorm)
    end
    score += sum((model.alpha .- gamma) .* Elogtheta)
    score += sum(gammaln.(gamma)) - sum(gammaln.(model.alpha))
    score += sum(gammaln(model.alpha * model.K) .- gammaln.(sum(gamma, dims=2)))

    score *= model.D / length(docs)

    return score

end

function update_lambda(model::OnlineLDA, docs::Vector{String})
    rhot = (model.tau0 + model.updatect)^(-model.kappa)
    model.rhot = rhot
    (gamma, sstats) = do_e_step(model, docs)
    bound = approx_bound(model, docs, gamma)
    model.lambda = model.lambda * (1 - rhot) .+ rhot .* (model.eta .+ model.D .* sstats / length(docs))
    model.Elogbeta = dirichlet_expectation(model.lambda)
    model.expElogbeta = exp.(model.Elogbeta)
    model.updatect += 1
    return gamma, bound    
end
