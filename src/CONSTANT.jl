cd("C:\\Users\\Kacper\\.julia\\dev\\KeMontielOleaNesbit2024.jl")
cwd = pwd()

PDF_PATH = joinpath(cwd, "src","FOMC_pdf")
PDF_PATH_TEST = joinpath(cwd, "src","FOMC_pdf_test")
CACHE_PATH = joinpath(cwd, "src","preprocessing", "cache")
MATRIX_PATH = joinpath(cwd, "src","preprocessing", "term-document matrix")
UTILFILE_PATH = joinpath(cwd, "src","preprocessing", "util_files")
PLOT_PATH = joinpath(cwd, "src","preprocessing", "plots")
NMF_draws_folder = joinpath(cwd, "src","preprocessing", "NMF")

mkpath(PDF_PATH)
mkpath(PDF_PATH_TEST)
mkpath(CACHE_PATH)
mkpath(MATRIX_PATH)
mkpath(UTILFILE_PATH)
mkpath(PLOT_PATH)
mkpath(NMF_draws_folder)

random_seed = 0