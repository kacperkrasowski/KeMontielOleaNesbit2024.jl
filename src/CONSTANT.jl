if Sys.iswindows()
    cd(abspath(joinpath(@__DIR__, "..")))
else
    cd(abspath(joinpath(@__DIR__, "..")))
end
cwd = pwd()

PDF_PATH = joinpath(cwd, "data", "raw", "FOMC_pdf")
PDF_PATH_TEST = joinpath(cwd, "data", "raw", "FOMC_pdf_test")
CACHE_PATH = joinpath(cwd, "data", "clean", "cache")
MATRIX_PATH = joinpath(cwd, "data", "clean", "term-document matrix")
UTILFILE_PATH = joinpath(cwd, "data", "utils")
PLOT_PATH = joinpath(cwd, "output")
NMF_draws_folder = joinpath(cwd, "data", "clean", "NMF")

mkpath(PDF_PATH)
mkpath(PDF_PATH_TEST)
mkpath(CACHE_PATH)
mkpath(MATRIX_PATH)
mkpath(UTILFILE_PATH)
mkpath(PLOT_PATH)
mkpath(NMF_draws_folder)

random_seed = 0