# Embedding-JMP-2.0
Credit goes to Meijian Guan for the original script, which included UMAP and t-SNE dimensionality reduction algorithms. This is a multipurpose JMP script allowing allowing user to run tSpace, UMAP, t-SNE, Wanderlust, and Leiden algorithms on gene-cell data by interfacing with R and Matlab, in the form of an easy-to-access add-in on the JMP toolbar. Modifications include addition of 3 new algorithms and the ability to reintegrate resultant data matrices back into original datasets, as well as cosmetic improvements and addition of row numbers, run date, and parameters to the results for user convenience.
# Getting Started
Attached is a file called Embedding Instructions, V3. Start by opening this file, which will walk you through the steps and installations necessary to get these algorithms up and running on your computer.
# Credits
The R implementation of the t-SNE algorithm is derived from jkrijthe/Rtsne. UMAP is derived from tkonopka/umap. The t-Space and Wanderlust algorithms are derived from their respective MATLAB packages, and the r-to-MATLAB interface code is derived from kbrulois/MATLABfuncs. The Leiden implementation is derived from scfurl/SeqGlue and cole-trapnell-lab/leidenbase.
# Notes
-Compatible only with JMP Pro 15 or higher
