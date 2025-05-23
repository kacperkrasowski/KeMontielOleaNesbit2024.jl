#  Replication Package for: Robust Machine Learning Algorithms for Text Analysis

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kacperkrasowski.github.io/KeMontielOleaNesbit2024.jl/dev/)
[![Build Status](https://github.com/kacperkrasowski/KeMontielOleaNesbit2024.jl/actions/workflows/docs.yml/badge.svg?branch=main)](https://github.com/kacperkrasowski/KeMontielOleaNesbit2024.jl/actions/workflows/docs.yml)



This repository is dedicated for a replication package of Ke, Shikun, José Luis Montiel Olea, and James Nesbit. "Robust Machine Learning Algorithms for Text Analysis." Quantitative Economics, 15, .no 4, (Econometric Society: 2024), 939-970. https://doi.org/10.3982/QE1825. The original code was written in Matlab and Python and was translated by us to Julia.

This is a term project of the PhD in Economics in [Collegio Carlo ALberto](https://www.carloalberto.org/), for the class of [Computational Economics for PhDs](https://floswald.github.io/CompEcon/) taught by Professor [Florian Oswald](https://floswald.github.io/).

Some of the results differ due:
1. Differences between TextAnalysis.jl and nltk.py.
2. Our implementation of well established functions in python that had to be coded from scratch (probably with some mistakes).
3. Different dictionaries used in order to stem the text (PorterStemmer in case of the paper).
4. Some coding mistakes 

The Project was uploaded without the NMF matricies since they weight abouve 30GB.
<!---
Include as much detail in the article citation as you can.
-->

## Authors 

- Kacper Krasowski
- Stefano Fusinato

<!---
The replication package can have a different set of authors than the article.
-->
## Details on data source

<!---
rework the relevant examples from below
-->


- The pdf FOMC transcripts was dowloaded from a [Dropbox](https://www.dropbox.com/scl/fo/tdtyskrt9t0eiumoru6ng/h?rlkey=k05l6qtmq8m4n6ot5gtqtyuos&dl=0) provided by the Authors of the paper. 
- Rest of the data authors obtained from Hansen, Stephen & McMahon, Michael & Prat, Andrea. (2018). "Transparency and Deliberation Within the FOMC: A Computational Linguistics Approach". Quarterly Journal of Economics. 133. 801-870. 10.1093/qje/qjx045. The data includes the transparency indicator and the names of the members of FOMC meetings. 


# Computational requirements

<!---
In general, the specific computer code used to generate the results in the article will be within the repository that also contains this README. However, other computational requirements - shared libraries or code packages, required software, specific computing hardware - may be important, and is always useful, for the goal of replication. Some example text follows. 
-->
### Software requirements

<!---
List all of the software requirements, up to and including any operating system requirements, for the entire set of code. It is suggested to distribute most dependencies together with the replication package if allowed, in particular if sourced from unversioned code repositories, Github repos, and personal webpages. In all cases, list the version *you* used. 
-->

- Julia (1.11.3) 
  - CSV (0.10.15)  
  - DataFrames (1.7.0)  
  - DataStructures (0.18.22)  
  - Distributions (0.25.120)  
  - JLD2 (0.5.13)  
  - JSON (0.21.4)  
  - KernelDensity (0.6.9)  
  - LaTeXStrings (1.4.0)  
  - LinearAlgebra (1.11.0)  
  - PDFIO (0.1.15)  
  - Plots (1.40.13) 
  - Printf (1.11.0)
  - Random (1.11.0)  
  - SpecialFunctions (2.5.1)  
  - Statistics (1.11.1)  
  - StatsPlots (0.15.7)  
  - StopWords (1.0.1)  
  - Test (1.11.0)
  - TextAnalysis (0.8.2)  
  - WordCloud (1.3.2)  
  - XLSX (0.10.4)  


### Memory and runtime requirements
In order to run the replication one should have at least 50 GB of free storage in order to strore the results of Negative Matrix Factorization process.
<!---
Memory and compute-time requirements may also be relevant or even critical. Some example text follows. It may be useful to break this out by Table/Figure/section of processing. For instance, some estimation routines might run for weeks, but data prep and creating figures might only take a few minutes.
-->

#### Summary

The runtime depends on the eps parameter set in `src/Main_generate_NMF_draws.jl`. Approximate time needed to reproduce the analyses on a standard 2025 desktop machine: 
- 5 hours for eps = 2-e4
- 10 hours for eps = 1-e4


#### Details
The code was last run on **4-core Intel-based laptop with Windows 11 version 23H2** with **16 GB RAM**.


# Raw Dataset list

<!---
In some cases, authors will provide one dataset (file) per data source, and the code to combine them. In others, in particular when data access might be restrictive, the replication package may only include derived/analysis data. Every file should be described. This can be provided as a Excel/CSV table, or in the table below.
-->

| Data file | Source | Notes    |Provided |
|-----------|--------|----------|---------|
| `data/raw/FOMCdatemeeting.pdf` | Authors | 148 transcripts | Yes |
| `data/utils/covariates.csv` | Authors | Covariates used in  Hansen, McMahon, and Prat (2018) | Yes |
| `data/utils/firstnames.xlsx`| Authors | Names of meetings members | Yes |
| `data/utils/stopwords_long.xlsx`| Authors | Long stop words | Yes |
| `data/utils/stopwords_short.xlsx`| Authors | Short stop words | Yes |

# Clean Dataset list

<!---
In some cases, authors will provide one dataset (file) per data source, and the code to combine them. In others, in particular when data access might be restrictive, the replication package may only include derived/analysis data. Every file should be described. This can be provided as a Excel/CSV table, or in the table below.
-->

| Data file | Generating file | Function | 
|-----------|--------|-----|
| `data/clean/cache/raw_text.xlsx` | `src/preprocessing/data_preprocess.jl` | `generate_raw_data()` |
| `data/clean/cache/raw_text_separated.xlsx` | `src/preprocessing/data_preprocess.jl` | `separation()` |
| `data/clean/cache/FOMC_token_separated_col.xlsx` | `src/preprocessing/data_preprocess.jl` | `preprocess()` |
| `data/clean/cache/MC_N*.xlsx` | `src/simulations/MC_illustration.jl` | `MC_illustration()` |
| `data/clean/NMF/.../*.jld2` | `src/preprocessing/estimation_and_nmf.jl` | `find_NMF_given_solution()` |
| `data/clean/term-document matrix/...` | `src/preprocessing/generate_matrix.jl` | `generate_tf_only_matrix()` |



# List of tables and figures

<!---
Your programs should clearly identify the tables and figures as they appear in the manuscript, by number. Sometimes, this may be obvious, e.g. a program called "`table1.do`" generates a file called `table1.png`. Sometimes, mnemonics are used, and a mapping is necessary. In all circumstances, provide a list of tables and figures, identifying the program (and possibly the line number) where a figure is created.

If the public repository is incomplete, because not all data can be provided, as described in the data section, then the list of tables should clearly indicate which tables, figures, and in-text numbers can be reproduced with the public material provided.
-->



| Figure/Table #    | Program                  | Line Number | Output file                      | 
|-------------------|--------------------------|-------------|----------------------------------|
| Figure 3(a)  | `src/simulations/sensitivity.jl`    |     | `Sensitivity_N10.png`    |
| Figure 3(b)  | `src/simulations/sensitivity.jl`    |     | `Sensitivity_N100.png`    |
| Figure 4(a)  | `src/simulations/range.jl`    |     | `Range_N10.png`    |
| Figure 4(b)  | `src/simulations/range.jl`    |     | `Range_N10.png`    |
| Figure 5(a)  | `src/simulations/credibleset90_range.jl`    |     | `CredibleSet90_Range_N10.png`    |
| Figure 5(b)  | `src/simulations/credibleset90_range.jl`    |     | `CredibleSet90_Range_N10.png`    |
| Figure 6(a)  | `src/simulations/algo2range.jl`    |     | `Algo2Range_N10.png`    |
| Figure 6(b)  | `src/simulations/algo2range.jl`    |     | `Algo2Range_N10.png`    |
| Figure 7(a)  | `src/simulations/plotsMC.jl`    |     | `Freq_MC.png`    |
| Figure 7(b)  | `src/simulations/lotsMC.jl`    |     | `Robust_MC.png`    |
| Figure 8     | `src/preprocessing/utils.jl`    |  69   | `WordCloud_FOMC1_onlyTF.png`    |
| Figure 9(a)  | `src/plotting/plot_results.jl`    |     | `prior_alpha_1.25_beta_0.025_percent_diff.png.png`    |
| Figure 9(b)  | `src/plotting/plot_results.jl`    |     | `posterior_alpha_1.25_beta_0.025_percent_diff.png.png`    |


# Instructions to replicators

<!---
The first two sections ensure that the data and software necessary to conduct the replication have been collected. This section then describes a human-readable instruction to conduct the replication. This may be simple, or may involve many complicated steps. It should be a simple list, no excess prose. Strict linear sequence. If more than 4-5 manual steps, please wrap a master program/Makefile around them, in logical sequences. Examples follow.
-->


```
> git clone https://github.com/kacperkrasowski/KeMontielOleaNesbit2024.jl
> cd KeMontielOleaNesbit2024.jl
> julia 
```

Then, to replicate easily the outputs you can run the following commands in the Julia REPL:

```
julia > ]
julia > activate .

using KeMontielOleaNesbit2024

KeMontielOleaNesbit2024.run() # To replicate
KeMontielOleaNesbit2024.run_tests() #To run tests
```

### Pipeline of replication:

0. First the PDFs were flattened out of XObjects using ghostscript and substituted in the `data/raw/FOMC_PDF` 
1. `generate_raw_data()` Generates raw text from PDFS.
2. `preprocess()` Wraps: separating FOMC1 and FOMC2 by calling `separation()`, tokenizing the content by calling `tokenize()`, and finding collocations by calling `find_collocation()`. All of those functions use methods defined for a mutable structure `RawDocs` defined in `src/preprocessing/raw_docs.jl`.
3. `generate_tf_only_matrix()` Generates term document matricies, dictionary for meetings and merges all of the text for a given section together.
4. `plot_word_cloud()` Generates the figure 8.
5. `gen_NMF()` wraps: Variational Bayes Estimation by calling `vb_estimate()`, generates and stores all of the Negative Factorized Matricies by calling `algo1_only_store_draws()`, which uses `find_NMF_given_solution()` to factorize.  (around 30GB)
6. `do_plots()` generates figures 9(a) and 9(b) by calling `compute_functional_from_nmf_draws()` that computes a statistic over the posterior NMF draws for a specific FOMC section and plots them by using `plot_result()`.
7. Finally `simulation_plots()` wraps: generating figures: 3(a) and 3(b) by calling `plot_senitivity()`, generating figures: 4(a) and 4(b) by calling `range_posterior_means()`, generating figures: 5(a) and 5(b) by calling `credible_set90_range()`, generating figures: 6(a) and 6(b) by calling `algo2_range()`, generating figures: 7(a) and 7(b) by calling `PlotsMC()`.


# Description of programs/code

<!---
Give a high-level overview of the program files and their purpose. Remove redundant/ obsolete files from the Replication archive.
-->

The code consists of 3 main parts:
- Preprocessing and Drawing NMFs located in `src/preprocessing`. The files are:
  - `preprosses_data.jl` that defines stop words and a dictionary for regex contractions like
  ```
  r"couldn[’']t" => "could not",
  ``` 
  - `raw_docs.jl` that defines a mutable structure `RawDocs` and the following methods for text analysis: creating bigrams and trigrams (`bigram!()`,`trigram!()`), removing stopwords (`stopword_remove!()`), stemming the words (`stem2!()`), stripping text of non alphanumerical characters (`clean1()`, `clean2()`), deleting too short words such as "is" or "or" from a text (`token_clean!()`), replacing phrases (for example running, runners into run) (`phrase_replace!()`), and creatin tf and tf-idf ranking of words (`term_rank!`).
  - `utils.jl` that defines function for plotting word clouds (`plot_word_cloud`) and some helper functions.
  - `data_preprocess.jl` that defines the functions that: reads a PDF file and turns it into raw text (`generate_raw_text()`), splits raw FOMC meeting text into two labeled sections -FOMC1 and FOMC2 (`separation()`), tokenizes the text by using previously defined `RawDocs` structure (`tokenize()`),  identifies frequent bigrams and trigrams (`find_collocation()`) and and a function that wraps 3 above functions in order to generate a text ready for LDA analysis (`preprocess()`).
  - `generate_matrix.jl` defines function that processes tokenized FOMC meeting transcripts to create section-specific term-frequency (TF) matrices. It removes stopwords, builds a word dictionary, computes term frequencies, and filters the vocabulary to the top N most frequent words per section. It generates a TF-rank plot showing how word frequency drops off. This function helps prepare cleaned, size-limited matrices suitable for downstream analysis like topic modeling or visualization (`generate_tf_only_matrix.jl`). 
  - `onlineldavb.jl` that defines mutable structure `OnlineLDA` with the following methods used in Variational Bayes Estimation: estimating the document-topic distributions and sufficient statistics (`do_e_step()`), computes a variational lower bound on the log-likelihood (`approx_bound()`), applying a stochastic update to the global topic-word distributions (`update_lambda()`). Those are crucial for Latent Dirichlat Allocation analysis. This part was translated from a [function](https://github.com/blei-lab/onlineldavb) of Matthew D. Hoffman
  - `estimation_and_nmf.jl` that defines functions which use the `OnlineLDA` structure that: performs the VB estimation (`vb_estimate`), performs Negative Matrix Factorization (`find_NMF_given_solution`) and a function that stores the results (`algo1_only_store_draws`).
  - Those functions are wrapped into `Main_preprocess.jl` and `Main_generate_NMF_draws.jl` to preprocess all of the data and generate the NMF draws.
- Computing necessary statistics and plotting the results of the LDA analysis, located in `src/plotting`. The files are: 
  - `compute_functional_from_nmf_draws.jl` that defines a function `compute_functional_from_nmf_draws()` loads posterior draws of the topic distribution matrices (Theta) from a JLD2 file and retrieves covariate data (e.g. transparency dummies) for regression. Computes a functional (func) over the HHI derived from the Theta draws for each draw, storing the results in H_diff_percent. For each draw, it also loads corresponding Nonnegative Matrix Factorization (NMF) simulations of Theta, computes the same functional over these, and stores the minimum and maximum values across NMF runs as robustness bounds (lambda_lower_percent and lambda_upper_percent). Returns the main functional estimates along with lower and upper bounds from the NMF simulations, allowing one to assess sensitivity of the results to posterior sampling variability.
  - `plot_results.jl` that plots the results of Kernel Density Estimation for the primary posterior and prior estimates.
- Performing simulations, located in `src/simulations`. The files are:
  - `sensitivity.jl` with a function `plot_sensitivity()` that creates a visual sensitivity analysis for a posterior mean functional.
  - `range.jl` with afunction `range_posterior_means()` that creates a visual sensitivity analysis for a posterior functional based on Bayesian inference using Beta distributions.
  - `credibleset90_range.jl` with a function `credible_set90_range()` that estimates 90% robust credible intervals for a functional λ(p₁, p₂) using Bayesian simulation, and visualizes their variation across different values of the proportion.  
  - `algo2range.jl` with a function `algo2_range()` that evaluates the accuracy of Algorithm 2's approximation of a posterior mean functional over a range of sample proportions and visualizes the result.
  - `MC_illustration.jl` with a function `MC_illustration()` that simulates and compares frequentist and robust Bayesian estimators of a Herfindahl-type functional across repeated sampling experiments.
  -  `plotsMC.jl` with a function `PlotsMC()` that plotes the results of `MC_illustration.jl`

  

### License for Code

The code is licensed under a MIT/BSD/GPL/Creative Commons license. See [LICENSE.txt](LICENSE.txt) for details.


# References

Hansen, Stephen & McMahon, Michael & Prat, Andrea. (2018). "Transparency and Deliberation Within the FOMC: A Computational Linguistics Approach". Quarterly Journal of Economics. 133. 801-870. 10.1093/qje/qjx045.

 Ke, Shikun, José Luis Montiel Olea, and James Nesbit. "Robust Machine Learning Algorithms for Text Analysis." Quantitative Economics, 15, .no 4, (Econometric Society: 2024), 939-970. https://doi.org/10.3982/QE1825

Matthew D. Hoffman, ONLINE VARIATIONAL BAYES FOR LATENT DIRICHLET ALLOCATION, (2016),  https://github.com/charlespwd/project-title

## License

[MIT](https://choosealicense.com/licenses/mit/)