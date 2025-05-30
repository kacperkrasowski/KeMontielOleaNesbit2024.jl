import StopWords: stopwords
include(abspath(joinpath(@__DIR__, "..", "CONSTANT.jl")))
using StopWords
using DataStructures
using WordCloud

function ngramm(s,n) 
    [view(s,i:i+n-1) for i=1:length(s)-n+1]
end

function bigrams(big_document; freq::Int = 150) # for the whole document
    ignored_words = stopwords["eng"]
    push!(ignored_words, "percent")
    push!(ignored_words, "governor")
    push!(ignored_words, "dont")
    all_bigrams = String[]
    for doc in big_document
        filtered = [w for w in doc if length(w) ≥ 3 && lowercase(w) ∉ ignored_words]
        doc_bigrams = ngramm(filtered,2)
        
        append!(all_bigrams, [join(b, " ") for b in doc_bigrams])
    end
    
    freq_map = counter(all_bigrams)
    
    frequent_bigrams = [bigram for (bigram, count) in freq_map if count ≥ freq]
    
    return frequent_bigrams

end



function trigrams(big_document; freq::Int = 100) # for the whole document
    ignored_words = stopwords["eng"]
    push!(ignored_words, "percent")
    push!(ignored_words, "governor")
    push!(ignored_words, "dont")
    all_bigrams = String[]
    for doc in big_document
        filtered = [w for w in doc if length(w) ≥ 3 && lowercase(w) ∉ ignored_words]
        doc_bigrams = ngramm(filtered,3)

        append!(all_bigrams, [join(b, " ") for b in doc_bigrams])
    end
    freq_map = counter(all_bigrams)
    
    frequent_bigrams = [bigram for (bigram, count) in freq_map if count ≥ freq]

    return frequent_bigrams

end

function replace_collocation(s::String, dict_collocation::Dict{String, String})
    for (key, value) in dict_collocation
        s = replace(s, key => value)
    end
    return s
end
"""
    plot_word_cloud(text::Vector{Vector{String}}, filename::String)

Generates and saves a word cloud plot using all tokens from the provided text.

# Arguments
- `text`: nested vector of tokenized words (one subvector per document)
- `filename`: file name to save the output PNG plot under `PLOT_PATH`
"""
function plot_word_cloud(text, filename)
    meeting_string = join(Iterators.flatten(text), " ")
    wc = wordcloud(meeting_string) |> generate!
    paint(wc, joinpath(PLOT_PATH,filename))
end

