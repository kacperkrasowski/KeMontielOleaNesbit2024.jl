include("preprocess_data.jl")
using SnowballStemmer 

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


    function RawDocs(doc_data; sw = "none", contraction_split = true)
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

        new(docs, tokens , [], stopwords, N, [], []) 
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
        function clean2(tokens, length) 
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

    
