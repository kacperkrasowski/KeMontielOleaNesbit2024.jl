module KeMontielOleaNesbit2024
"""
    KeMontielOleaNesbit2024

Main module for running the preprocessing, estimation, and simulation pipeline for FOMC data using OnlineLDA and NMF methods.
"""

include(joinpath(@__DIR__, "Main_preprocess.jl"))
include(joinpath(@__DIR__, "Main_generate_NMF_draws.jl"))
include(joinpath(@__DIR__, "Main_plot.jl"))
include(joinpath(@__DIR__, "Main_simulations.jl"))


export run, run_tests,
       generate_raw_data, preprocess, generate_tf_only_matrix,
       plot_word_cloud, gen_NMF, do_plots, simulation_plots,
       vb_estimate, find_NMF_given_solution,
       compute_functional_from_nmf_draws

"""
    run()

Runs the full project pipeline:
- Extracts and preprocesses FOMC meeting transcripts,
- Generates TF-only matrices,
- Creates word clouds,
- Performs variational Bayes topic modeling using OnlineLDA,
- Generates and saves NMF posterior draws,
- Plots results and simulation outputs.

Outputs are saved to configured `CACHE_PATH`, `MATRIX_PATH`, and `PLOT_PATH`.
"""
function run()
    start_running = time()

    generate_raw_data()
    preprocess()

    # Define or import your stopword list from Main_preprocess or CONSTANT.jl
    text1, text2 = generate_tf_only_matrix([200, 150], stop_words, "text")
    plot_word_cloud(text1, "WordCloud_FOMC1_onlyTF.png")
    plot_word_cloud(text2, "WordCloud_FOMC2_onlyTF.png")

    gen_NMF()
    do_plots()
    simulation_plots()

    println("Total time for the whole Project: $(time() - start_running) seconds")
end

"""
    run_tests()

Executes the complete test suite from the `/test` directory using included unit and integration tests.
"""
function run_tests()
    include(abspath(joinpath(@__DIR__, "..", "test", "runtests.jl")))
end

end # module
