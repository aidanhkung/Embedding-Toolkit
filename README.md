# Embedding-Toolkit
Credit goes to Meijian Guan for the original script, which included UMAP and t-SNE dimensionality reduction algorithms. This is a multipurpose JMP script allowing allowing user to run tSpace, UMAP, t-SNE, Wanderlust, and Leiden algorithms on gene-cell data by interfacing with R and Matlab, in the form of an easy-to-access add-in on the JMP toolbar. Modifications include addition of 3 new algorithms and the ability to reintegrate resultant data matrices back into original datasets, as well as cosmetic improvements and addition of row numbers, run date, and parameters to the results for user convenience.
# Getting Started
Attached is a file called Embedding Instructions, V3. Start by opening this file, which will walk you through the steps and installations necessary to get these algorithms up and running on your computer.
# Credits
The R implementation of the t-SNE algorithm is derived from jkrijthe/Rtsne. UMAP is derived from tkonopka/umap. The t-Space and Wanderlust algorithms are derived from their respective MATLAB packages, and the r-to-MATLAB interface code is derived from kbrulois/MATLABfuncs. The Leiden implementation is derived from scfurl/SeqGlue and cole-trapnell-lab/leidenbase. Wanderlust is described in detail in "viSNE and Wanderlust, two algorithms for the visualization and analysis of high-dimensional single-cell data", by El-ad David Amir, et. al. (2014). The tSpace algorithm is described in a paper by Dermadi, D. et. al., "Exploration of Cell Development Pathways through High-Dimensional Single Cell Analysis in Trajectory Space"(2020).

Dermadi D, Bscheider M, Bjegovic K, Lazarus NH, Szade A, Hadeiba H, Butcher EC. Exploration of Cell Development Pathways through
  High-Dimensional Single Cell Analysis in Trajectory Space. iScience. 2020;23(2):100842. Epub 2020/02/15. doi:
  10.1016/j.isci.2020.100842. PubMed PMID: 32058956; PMCID: PMC6997593.
   
Bendall SC, Davis KL, Amir el-AD, et al. Single-cell trajectory detection uncovers progression and regulatory coordination in
  human B cell development. Cell. 2014;157(3):714-725. doi:10.1016/j.cell.2014.04.005

# Notes
-Compatible only with JMP Pro 15 or higher
