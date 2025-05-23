config_path = abspath(joinpath(@__DIR__, "..", "CONSTANT.jl"))
include(config_path)
using DataFrames
using XLSX
using Plots
using JSON

function corpus2dense(corpus::Vector{Vector{Pair{Int64, Int64}}}, num_terms::Int)
    num_docs = length(corpus)
    mat = zeros(Float64, num_terms, num_docs)
    for (j, doc) in enumerate(corpus)
        for (term_id, count) in doc
            mat[term_id, j] = count  # +1 for 1-based indexing
        end
    end
    return mat
end
function doc2bow(doc, word2id::Dict{String, Int})
    counts = Dict{Int, Int}()
    for word in doc
        if haskey(word2id, word)
            id = word2id[word]
            counts[id] = get(counts, id, 0) + 1
        end
    end
    return collect(sort(collect(counts), by = x -> x[1]))
end
"""
    generate_tf_only_matrix(tf_idf_threshold::Vector{Int}, additional_stop_words::Vector{String}, option)

Generates term-frequency-only matrices for each FOMC section and saves them as Excel and JSON files.

# Arguments
- `tf_idf_threshold`: max number of words to retain per section
- `additional_stop_words`: extra stopwords to exclude
- `option`: return \"matrix\", \"text\", or nothing

# Returns
- Depending on `option`, returns term-document matrices or tokenized meeting texts
"""
function generate_tf_only_matrix(tf_idf_threshold::Vector{Int} = [9000,6000], additional_stop_words::Vector{String} = [], option = nothing)
    data = DataFrame(XLSX.readtable(joinpath(CACHE_PATH, "FOMC_token_separated_col.xlsx"), "Sheet1"))
    filter!(row -> typeof(row[:content])!=Missing, data )

    meeting_text_both = []
    term_document_both = []
    for section in 1:2
        meeting_text = []
        for meeting in unique(data.Date)
            # Creating a vector of words for each meeting
            step1 = data[data.Date .== meeting, :]
            step2 = step1[step1.Section .== section, :]
            step3 = join(step2.content, " ")
            step4 = split(step3, ' ')
            push!(meeting_text, step4)
        end

        # Creating unique id for each word 
        id_counter = 1
        dictionary = Dict{String, Int}()
        dictionary_rev = Dict{Int, String}()
        for doc in meeting_text
            for word in doc
                if !haskey(dictionary, word)
                    dictionary[word] = id_counter
                    dictionary_rev[id_counter] = word
                    
                    id_counter += 1
                end
            end
        end
        bad_id = []

        for word in collect(keys(dictionary)) 
            if word in additional_stop_words
                push!(bad_id, dictionary[word])
            end
        end
        filter!(d -> d ∉ bad_id ,dictionary)
        corpus = [doc2bow(text, dictionary) for text in meeting_text]
        
        
        term_document = corpus2dense(corpus, length(dictionary))
        TF1 = sum(term_document, dims=2)
        TF = Dict()

        for (i, count) in enumerate(TF1)
            TF[dictionary_rev[i]] = count
        end
        #TF = Dict(zip(collect(keys(dictionary)), TF1))
        if section == 1
            N = tf_idf_threshold[1]
            color = :blue
            plot()
        elseif section == 2
            N = tf_idf_threshold[2]
            color = :red
        end

        keys_to_use1 = sort(collect(TF), by = x -> x.second, rev = true)[1:N]
        keys_to_use = [p.first for p in keys_to_use1]

        sorted_tfs = sort(collect(values(TF)), rev=true)

        maxlen = 2 * maximum(tf_idf_threshold)
        y_vals = sorted_tfs[1:min(maxlen, end)]
        x_vals = 1:length(y_vals)  # TF-IDF rank
        
        plot!(x_vals, y_vals, color=color, label="", xlabel="TF-IDF rank", ylabel="TF-IDF score")

        vline!([N], linestyle=:dash, color=color)

        filter!(d -> d.first in keys_to_use, dictionary)
        new_id = 1
        for (key,_) in dictionary
            dictionary[key] = new_id
            new_id += 1
        end
        df = DataFrame(token=collect(keys(dictionary)), id=collect(values(dictionary)))

        # Create filename
        filename = joinpath(MATRIX_PATH, "FOMC$(section)_dictionary_meeting_onlyTF.xlsx")

        # Save to Excel
        XLSX.writetable(filename, collect(eachcol(df)), names(df), overwrite = true)
        text2 = []
        for line in meeting_text
            t = [x for x in line if x in collect(keys(dictionary))]
            
            push!(text2, t)
        end
        new_corpus = [doc2bow(text, dictionary) for text in meeting_text] 
        

        new_term_document = corpus2dense(new_corpus, length(dictionary))
        
        matrix_path = joinpath(MATRIX_PATH, "FOMC$(section)_meeting_matrix_onlyTF.xlsx")
        pickle_path = joinpath(MATRIX_PATH, "FOMC$(section)_text_onlyTF.json")
        df = DataFrame(new_term_document, :auto)
        XLSX.writetable(matrix_path, collect(eachcol(df)), names(df),overwrite = true)
        write(pickle_path, JSON.json(text2))


        # Append results to the two collections
        push!(term_document_both, new_term_document)
        push!(meeting_text_both, text2)
    end

    savepath = joinpath(PLOT_PATH, "TF_IDF_meeting_onlyTF.png")
    savefig(savepath)
    if option == "text"
        return meeting_text_both
    elseif option == "matrix"
        return term_document_both
    else 
        return ""
    end
end
