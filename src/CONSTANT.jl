cd("C:\\Users\\Kacper\\.julia\\dev\\KeMontielOleaNesbit2024.jl\\src")
cwd = pwd()

PDF_PATH = joinpath(cwd, "FOMC_pdf")
PDF_PATH_TEST = joinpath(cwd, "FOMC_pdf_test")
CACHE_PATH = joinpath(cwd, "preprocessing", "cache")
MATRIX_PATH = joinpath(cwd, "preprocessing", "term-document matrix")
UTILFILE_PATH = joinpath(cwd, "preprocessing", "util_files")
PLOT_PATH = joinpath(cwd, "preprocessing", "plots")
#NMF_draws_folder = raw"D:\Robust_LDA_data\NMF_draws"

mkpath(PDF_PATH)
mkpath(PDF_PATH_TEST)
mkpath(CACHE_PATH)
mkpath(MATRIX_PATH)
mkpath(UTILFILE_PATH)
mkpath(PLOT_PATH)
#mkpath(NMF_draws_folder)