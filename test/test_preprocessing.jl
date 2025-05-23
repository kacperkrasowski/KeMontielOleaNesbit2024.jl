import StopWords: stopwords
using Test
using DataFrames
using XLSX

include(abspath(joinpath(@__DIR__, "..", "src","preprocessing", "raw_docs.jl")))
include(abspath(joinpath(@__DIR__, "..", "src","preprocessing", "data_preprocess.jl")))
include(abspath(joinpath(@__DIR__, "..", "src","preprocessing", "preprocess_data.jl")))
include(abspath(joinpath(@__DIR__, "..", "src","preprocessing", "utils.jl")))

@testset "Preprocessing Tests" begin

    @testset "RawDocs Functionality" begin
        doc = RawDocs(["I can’t believe it’s not butter."]; sw = "short")
        token_clean!(doc, 2)
        @test all(length.(doc.tokens[1]) .> 2)

        stem2!(doc)
        @test length(doc.stems) == 1

        stopword_remove!(doc, "stems")
        @test all(w ∉ doc.sw_set for w in doc.stems[1])

        bigram!(doc, "stems")
        @test isa(doc.bigrams, Vector{Vector{String}})
    end

    @testset "Term Ranking and Filtering" begin
        doc = RawDocs(["this is a test test document test test"]; sw = "short") 
        token_clean!(doc, 2)
        term_rank!(doc, "tokens", false)
        @test !isempty(doc.df_ranking)
        @test !isempty(doc.tfidf_ranking)

        old_tokens = copy(doc.tokens)
        rank_remove!(doc, "df", "tokens", 2)
        @test length(doc.tokens[1]) <= length(old_tokens[1])
    end

    @testset "Stopword and Contraction Handling" begin
        test_str = "I can’t believe it’s already June."
        for (pat, repl) in contractions
            test_str = replace(test_str, pat => repl)
        end
        @test occursin("cannot", test_str) || occursin("is", test_str)

        @test length(stp_long) > 0
        @test length(stp_short) > 0
    end

    @testset "Utils Functions" begin
        input = [["the", "quick", "brown", "fox"]]
        bi = bigrams(input, freq=1)
        @test "quick brown" in bi

        tri = trigrams(input, freq=1)
        @test "quick brown fox" in tri

        s = "the quick brown fox"
        dict = Dict("quick brown" => "quick_brown")
        s2 = replace_collocation(s, dict)
        @test s2 == "the quick_brown fox"
    end

    @testset "Integration Tests" begin
        # Skip PDF parsing - test from raw_text.xlsx forward
        raw_text = DataFrame(Date = [202001], Speaker = ["CHAIRMAN"], content = ["The economy won’t recover until confidence returns."])

        separated = separation(raw_text)
        @test "Section" in names(separated)

        tokenized = tokenize(separated.content)
        @test typeof(tokenized) == Vector{Any}

        separated.content = tokenized
        collocated = find_collocation(separated)
        @test typeof(collocated.content) == Vector{String}
    end
end
