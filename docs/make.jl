using KeMontielOleaNesbit2024
using Documenter

DocMeta.setdocmeta!(KeMontielOleaNesbit2024, :DocTestSetup, :(using KeMontielOleaNesbit2024); recursive=true)

makedocs(;
    modules=[KeMontielOleaNesbit2024],
    authors="Kacper Krasowski, Stefano Fusinato",
    sitename="KeMontielOleaNesbit2024.jl",
    format=Documenter.HTML(;
        canonical="https://kacperkrasowski.github.io/KeMontielOleaNesbit2024.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kacperkrasowski/KeMontielOleaNesbit2024.jl",
    devbranch="main",
    devurl = "dev",
)
