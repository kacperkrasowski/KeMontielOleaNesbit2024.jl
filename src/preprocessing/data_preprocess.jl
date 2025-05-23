config_path = abspath(joinpath(@__DIR__, "..", "CONSTANT.jl"))
include(config_path)
include(joinpath(@__DIR__,"raw_docs.jl")) 
include(joinpath(@__DIR__,"utils.jl"))
using DataFrames
using PDFIO
using XLSX

function extract_text_pdftotext(pdf_path::String)::String
    exe = joinpath(Poppler_jll.artifact_dir, "bin", "pdftotext.exe")
    txt_path = replace(pdf_path, ".pdf" => ".txt")
    run(`$exe -layout $pdf_path $txt_path`)
    return read(txt_path, String)
end
"""
    generate_raw_data()

Extracts raw text from pre-downloaded PDF transcripts and saves a `raw_text.xlsx` file in the cache folder.

This function assumes transcripts have already been downloaded and stored. It processes them into a basic structured format for further preprocessing.
"""

function generate_raw_data()
    error_count = 0
    raw_doc = readdir(PDF_PATH)
    filelist = sort(raw_doc)

    raw_text = DataFrame(Date = Int[], Speaker = String[], content = String[])
    start = time()
    notloaded = Set()
    for (i, file) in enumerate(filelist)
        date = parse(Int, file[5:10])
        n = length(filelist)
        println("Document $i of $n: $file")
        doc = pdDocOpen(joinpath(PDF_PATH, file))
        npage = pdDocGetPageCount(doc)
        parsed = ""

        for j in 1:npage
            page = pdDocGetPage(doc,j)
            io = IOBuffer()    
            try
                pdPageExtractText(io,page)
                parsed *= String(take!(io))
            catch e
                println("huj")
                error_count+=1
                push!(notloaded, file)
            end
   
        end
        parsed = replace(parsed, r"[\r\f]+" => "\n")
        parsed = replace(parsed, r"\n\s+" => "\n")
        parsed = replace(parsed, r"\(\?\)" => "")

        interjections = split(parsed, r"(?:MR.|MS.|CHAIRMAN|VICE CHAIRMAN)  |(?:MR.|MS.|CHAIRMAN|VICE CHAIRMAN) |(?:MR.|MS.|CHAIRMAN|VICE CHAIRMAN) (?) ")
        temp_df = DataFrame(Date = String[], Speaker = String[], content = String[])
        interjections = [replace(interjection, "\n" => " ") for interjection in interjections]
        #temp = [split(lstrip(interjection), r"(^\S*)") for interjection in interjections]
        temp = [match(r"^([A-Z]+)\.\s+(.*)", interjection) for interjection in interjections]
        speaker = []
        content = []
        for interjection in temp
            if interjection != nothing
                push!(speaker, strip(interjection.captures[1], Set(".,!?;:\"'()[]{}")))
                push!(content, strip(interjection.captures[2]))
            end
        end
        temp_df = DataFrame(Date = date, Speaker = ["FOMC", speaker...], content = [date, content...])     
        raw_text = vcat(raw_text,temp_df)
    end
    xlsx_path = joinpath(CACHE_PATH, "raw_text.xlsx")
    XLSX.writetable(xlsx_path, raw_text, overwrite=true)
    elapsed = time() - start  # Assuming you used `start_time = time()` earlier
    println("Documents processed. Time: $elapsed seconds")
    println("Cache Location: $xlsx_path")
    println("error count = ",error_count)
    println(notloaded)
end

function separation(raw_text)
    separation_rule = DataFrame(XLSX.readtable(joinpath(UTILFILE_PATH, "separation_rules.xlsx"),"Sheet1"))
    FOMC_separation = DataFrame(Date = Int[], Speaker = String[], content = String[], Section = String[])

    #println(separation_rule)
    error_count1 = 0
    error_count2 = 0
    for i in 1:nrow(separation_rule)
        println("Running document $i out of 148")
        temp = filter(row -> row.Date == separation_rule[i,:Date], raw_text)
        try
            temp1 = temp[separation_rule[i,"FOMC1_start"]+1:separation_rule[i,"FOMC1_end"]+1,:]
            temp1.Section .= 1 
            FOMC_separation = vcat(FOMC_separation, temp1)
        catch e
            error_count1+=1
        end
        
        try
            if separation_rule[i,"FOMC2_end"] == "end"

                temp2 = temp[separation_rule[i,"FOMC2_start"]+1:end,:]
                temp2.Section .= 2
                FOMC_separation = vcat(FOMC_separation, temp2)
            else
                temp2 = temp[separation_rule[i,"FOMC2_start"]+1:separation_rule[i,"FOMC2_end"]+1,:]
                temp2.Section .= 2 
                FOMC_separation = vcat(FOMC_separation, temp2)
            end
        catch e
            error_count2+=1
        end
        
        
    end
    println(error_count1, "  ", error_count2)
    xlsx_path = joinpath(CACHE_PATH, "raw_text_separated.xlsx")
    XLSX.writetable(xlsx_path, FOMC_separation, overwrite=true)
    return FOMC_separation
end

function tokenize(content)
    FOMC_token = []
    for (i, statement) in enumerate(content)
        println("Running content $i out of $(length(content))")
        if typeof(statement) == String
            statement = lowercase(statement)
        else
            println("Not lowercaseable")
        end
        docsobj = RawDocs([statement]; sw = "long")
        token_clean!(docsobj,1)
        additional_stopword = ["january", "february", "march", "april", "may", "june", "july", "august", "september","october", "november", "december", "unintelligible"]
        for word in additional_stopword
            push!(docsobj.stopwords, word)
        end
        firstname = DataFrame(XLSX.readtable(joinpath(UTILFILE_PATH, "firstnames.xlsx"),"Sheet1"))
        for name in eachrow(firstname)
            
            if typeof(name["First name"]) == "missing"
                println(typeof(name["First name"]))
                push!(docsobj.stopwords, name["First name"])
            end
        end
        stopword_remove!(docsobj,"tokens")
        stem2!(docsobj)
        stopword_remove!(docsobj,"stems")
        if length(docsobj.stems)>0
            push!(FOMC_token, join(docsobj.stems[1], " ")) # Here there might be a mistake
        else
            push!(FOMC_token, " ")
        end
    end

    return FOMC_token

end

function find_collocation(raw_text_separated::DataFrame)
    content = [replace(x, r"[^\w\s]" => "") for x in raw_text_separated.content]
    big_document = [split(x, ' ') for x in content]
    
    bigram_list = bigrams(big_document)
    trigram_list = trigrams(big_document)
    
    replace_word = [join(split(x, " "), "_") for x in bigram_list] 
    replace_word = vcat(replace_word, [join(split(x, " "), "_") for x in trigram_list])
   

    dict_collocation = Dict(zip(vcat(bigram_list, trigram_list), replace_word))

    raw_text_separated.content = [replace_collocation(x, dict_collocation) for x in raw_text_separated.content]

    #xlsx_path = joinpath(CACHE_PATH, "FOMC_separated_collocation.xlsx")
    #XLSX.writetable(xlsx_path, raw_text_separated; overwrite=true)

    return raw_text_separated

end
"""
    preprocess()

Runs the main preprocessing pipeline for FOMC data:
- Loads raw data
- Applies speaker-based separation
- Tokenizes and stems the content
- Finds collocations
- Outputs cleaned data to Excel
"""
function preprocess()
    println("Loading raw_text.xlsx...")
    text = DataFrame(XLSX.readtable(joinpath(CACHE_PATH, "raw_text.xlsx"), "Sheet1"))

    println("Separating FOMC1 and FOMC2...")
    start1 = time()
    text_separated = separation(text)
    println("Finished. Time: $(time() - start1) seconds")
    println("******************************************************************************")

    println("Tokenizing content...")
    start = time()

    # Drop rows where content is missing
    text_separated = filter(row -> !ismissing(row.content), text_separated)

    # Ensure content is string before passing to tokenize
    #content_vec = parse.(String, text_separated.content)

    # Apply tokenize function (should return a Vector{Vector{String}})
    text_separated.content = tokenize(text_separated.content)

    println("Finished. Time: $(time() - start) seconds")
    println("******************************************************************************")

    println("Finding collocations...")
    start = time()
    text_separated_col = find_collocation(text_separated)
    println("Finished. Time: $(time() - start) seconds")
    println("******************************************************************************")

    # Save the final result
    println("Total time: $(time() - start1)")
    xlsx_path = joinpath(CACHE_PATH, "FOMC_token_separated_col.xlsx")
    XLSX.writetable(xlsx_path, text_separated_col; overwrite=true)

    
end

#CONCATENATE THE BI/TRIGRAMS WITH "_" APRT FROM THAT IT WORKS WELL
