include(joinpath(@__DIR__,"preprocessing","data_preprocess.jl"))
include(joinpath(@__DIR__,"preprocessing","generate_matrix.jl"))
include(joinpath(@__DIR__,"preprocessing","utils.jl")) # For word cloud not implemented yet

stop_words = ["think", "chairman", "presid", "governor",
              "number", "question", "will", "may",
              "point", "right", "mr", "come", "go",
              "want", "thank", "continu", "percent",
              "seem", "dont", "im", "littl", "forecast",
              "look", "might", "chang", "reflect",
              "encourag", "cant", "aw",
              "small", "ad", "caus", "district",
              "best", "like", "guess", "across",
              "find", "substanti", "cours", "mayb",
              "recogn", "doesnt", "week", "timemost",
              "impress", "fraction", "awri", "depend",
              "last", "accumul", "line", "certainli",
              "wouldsayxx", "term", "analysi", "retailsalesxx",
              "productiondo", "time",
              "youd", "saw", "economi", "view", "know",
              "sort", "theyr", "talk", "give", "illustr",
              "try", "upward", "your", "kiss", "particularli",
              "can", "geograph", "revis", "chart", "possibl",
              "suppos", "today", "committee", "necessarili",
              "persian", "gyrat", "wonthat",
              "thing", "that", "realli", "weve",
              "peopl", "much", "lot", "year", "weakest", "affair",
              "what", "figur"]

generate_raw_data() # commented out to run the script using raw_text.xlsx directly
preprocess()
text1, text2 = generate_tf_only_matrix(option="text", tf_idf_threshold=[200, 150], additional_stop_words=stop_words)
                
