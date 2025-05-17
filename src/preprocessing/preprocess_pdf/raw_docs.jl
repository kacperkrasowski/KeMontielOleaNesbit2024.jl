include("preprocess_data.jl")
using TextAnalysis 
using DataStructures
using DataFrames
using CSV
function my_tokenize(text::String)
    return split(text, r"\W"; keepempty=false)
end

mutable struct RawDocs
    docs::Vector{String}
    tokens::Vector{Vector{String}}
    stems::Vector{Vector{String}}
    stopwords::Set{String}
    N::Int
    df_ranking::Vector{Tuple{String,Int}}
    tfidf_ranking::Vector{Tuple{String,Float64}}
    bigrams::Vector{Vector{String}}


    function RawDocs(doc_data; sw::String = "none", contraction_split = true)
        docs = String[]

        if isa(doc_data, String) && isfile(doc_data) # Checks if doc_data is a String path to a file
            try
                raw = read(doc_data, String)
            catch e
                println("File does not have utf-8 encoding")
            end
            docs = split(raw,'\n')
        elseif isa(doc_data, AbstractVector)
            try
                docs = String.(doc_data)
            catch e
                println("Can not be converted to a String")
                docs = [" "]
            end
        else
            error("doc_data must be a valid path or vector of strings")
        end

        docs = lowercase.(docs) # Lowercases everything in the string

        if sw == "long"
            stopwords = stp_long
        elseif sw == "short"
            stopwords = stp_short
        end

        if contraction_split # replaces don't with do not etc
            for (pattern, replacement) in contractions
                docs = [replace(doc, pattern => replacement) for doc in docs]
            end
        else
            docs = [replace(doc, r"[’']" => "") for doc in docs]
        end
        N = length(docs)
        tokens = [split(doc, r"\W+"; keepempty=false) for doc in docs]

        new(docs, tokens , [], stopwords, N, [], [], []) 
    end
end
        function phrase_replace!(self::RawDocs, replace_dict::Dict{String, String})
            r(tokens) = begin
                text = " " * join(tokens, " ") * " "
                for (k, v) in replace_dict
                    text = replace(text, " " * k * " " => " " * v * " ")
                end
                split(strip(text))
            end
            self.stems = map(r, self.stems)
        end

        function token_clean!(self::RawDocs, len::Int; numbers::Bool=true)
            
            if numbers
                self.tokens = map(x -> clean1(x, len),self.tokens)
            else
                self.tokens = map(x -> clean2(x, len),self.tokens)
            end
        end
        function clean1(tokens, len) 
            return [t for t in tokens if all(isletter, t) && length(t) > len]
        end
        function clean2(tokens, len) 
            return [t for t in tokens if (all(isletter, t) || all(isnumeric, t)) && length(t) > len]
        end
        function stem2!(self::RawDocs)
           self.stems = q(self.tokens)
        end
        function q(tokens)
            stemmed = []
            for ts in tokens
                stemmed2 = []
                for t in ts
                    a = StringDocument(t)
                    stem!(a)
                    push!(stemmed2,text(a))
                end
                push!(stemmed,stemmed2)
            end
            return stemmed
        end
        function bigram!(self::RawDocs, items::String)
            function bigram_join(tok_list::Vector{String})
                text = []
                for i in 1:length(tok_list)-1
                    push!(text, tok_list[i]*"."*tok_list[i+1])
                end
                text
            end
            if items == "tokens"
                self.bigrams = map(x -> bigram_join(x), self.tokens)
            elseif items == "stems"
                self.bigrams = map(x -> bigram_join(x), self.stems)
            else 
                error("Must be token or stem")
            end

        end

        function stopword_remove!(self::RawDocs, items::String, threshold::Bool = false)
            function remove(tokens)
                return [t for t in tokens if t ∉ self.stopwords]
            end
            if items == "tokens"
                self.tokens = map(x -> remove(x), self.tokens)
            elseif items == "stems"
                self.stems = map(x -> remove(x), self.stems)
            else 
                error("Must be token or stem")
            end
        end

        function term_rank!(self::RawDocs, items::String, print_output::Bool=true)
            if items == "stems"
                v = self.stems
            elseif items == "tokens"
                v = self.tokens
            elseif items == "bigrams"
                v = self.bigrams
            else
                error("Items must be either \'tokens\' , \'bigrams\' or \'stems\'.")
            end
            agg = []
            for el in v
                for l in el
                    push!(agg, l)
                end
            end
            counts = counter(agg)

            v_unique = [unique(doc) for doc in v]
            agg_d = []
            for el in v_unique
                for l in el
                    push!(agg_d, l)
                end
            end
            counts_d = counter(agg_d)

            unique_tokens = keys(counts)

            tfidf(t) = (1 + log(counts[t])) * log(self.N / counts_d[t])
            unsorted_df = [(t, counts[t]) for t in unique_tokens]
            unsorted_tf_idf = [(t, tfidf(t)) for t in unique_tokens]
            println(unsorted_df)
            self.df_ranking = sort(unsorted_df, by = x -> x[2], rev = true)
            self.tfidf_ranking = sort(unsorted_tf_idf, by = x -> x[2], rev = true)
            if print_output
                df_df = DataFrame(term = first.(self.df_ranking), df = last.(self.df_ranking))
                tfidf_df = DataFrame(term = first.(self.tfidf_ranking), tfidf = last.(self.tfidf_ranking))
                CSV.write("df_ranking.csv", df_df)
                CSV.write("tfidf_ranking.csv", tfidf_df)
            end
        end
    
        function rank_remove!(self::RawDocs, rank::String, items::String, cutoff::Int)
            function remove(tokens)
                return [t for t in tokens if t ∉ to_remove]
            end
            if rank == "df"
                to_remove = [t[1] for t in self.df_ranking if t[2] <= cutoff]
            elseif rank == "tfidf"
                to_remove = [t[1] for t in self.tfidf_ranking if t[2] <= cutoff]
            else
                error("Wrong rank specified")
            end

            if items == "tokens"
                self.tokens = map(x -> remove(x), self.tokens)
            elseif items == "bigrams"
                self.bigrams = map(x -> remove(x), self.bigrams)
            elseif items == "stems"
                self.stems = map(x -> remove(x), self.stems)
            else
                error("Items must be either \'tokens\', \'bigrams\' or \'stems\'.")
            end

        end