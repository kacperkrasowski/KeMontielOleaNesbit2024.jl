using DataFrames
using PDFIO
using XLSX

function generate_raw_data()
    raw_doc = readdir(PDF_PATH_TEST)
    filelist = sort(raw_doc)
    onlyfiles = [f for f in raw_doc if isfile(joinpath(PDF_PATH, f))]
    #date = [f[5:10] for f in onlyfiles] 

    raw_text = DataFrame(Date = String[], Speaker = String[], content = String[])
    start = time()
    for (i, file) in enumerate(filelist)
        date = file[5:10]
        n = length(filelist)
        println("Document $i of $n: $file")
        doc = pdDocOpen(joinpath(cwd, "FOMC_pdf_test", file))
        npage = pdDocGetPageCount(doc)
        parsed = ""
        for j in 1:npage
            page = pdDocGetPage(doc,j)
            io = IOBuffer()
            pdPageExtractText(io, page)  
            parsed *= String(take!(io))    
        end
        interjections = split(parsed, r"MR. |MS. |CHAIRMAN |VICE CHAIRMAN") #r"\nMR\. |\nMS\. |\nCHAIRMAN |\nVICE CHAIRMAN ")
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
        temp_df = DataFrame(Date = date, Speaker = speaker, content = content)     
        println(temp_df)
        raw_text = vcat(raw_text,temp_df)
    end
    xlsx_path = joinpath(CACHE_PATH, "raw_text.xlsx")
    XLSX.writetable(xlsx_path, raw_text, overwrite=true)
    elapsed = time() - start  # Assuming you used `start_time = time()` earlier

    println("Documents processed. Time: $elapsed seconds")
    println("Cache Location: $xlsx_path")
end
generate_raw_data()
