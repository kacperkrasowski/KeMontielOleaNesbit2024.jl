config_path = abspath(joinpath(@__DIR__, "..", "CONSTANT.jl"))
include(config_path)

using DataFrames
using PDFIO
using XLSX

function generate_raw_data()
    error_count = 0
    raw_doc = readdir(PDF_PATH)
    filelist = sort(raw_doc)

    raw_text = DataFrame(Date = Int[], Speaker = String[], content = String[])
    start = time()
    for (i, file) in enumerate(filelist)
        date = parse(Int, file[5:10])
        n = length(filelist)
        println("Document $i of $n: $file")
        doc = pdDocOpen(joinpath(cwd,"src", "FOMC_pdf", file))
        npage = pdDocGetPageCount(doc)
        parsed = ""

        for j in 1:npage
            page = pdDocGetPage(doc,j)
            io = IOBuffer()    
            try
                pdPageExtractText(io,page)
                parsed *= String(take!(io))
            catch e
                error_count+=1
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
    println(nrow(raw_text))
    println("Documents processed. Time: $elapsed seconds")
    println("Cache Location: $xlsx_path")
    println("error count = ",error_count)
end

generate_raw_data()
function separation(raw_text)
    separation_rule = DataFrame(XLSX.readtable(joinpath(UTILFILE_PATH, "separation_rules.xlsx"),"Sheet1"))
    FOMC_separation = DataFrame(Date = Int[], Speaker = String[], content = String[], Section = String[])

    #println(separation_rule)
    error_count1 = 0
    error_count2 = 0
    for i in 1:nrow(separation_rule)
        println("Running document $i out of 148")
        temp = filter(row -> row.Date == separation_rule[i,:Date], raw_text)
        println(temp)
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

