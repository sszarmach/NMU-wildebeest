# NMU-wildebeest
R Scripts written by Steph Szarmach for summarizing output from DaCosta and Sorenson's (2014) ddRAD-seq pipeline (https://github.com/BU-RAD-seq/ddRAD-seq-Pipeline) and quality filtering RAD-loci. These scripts were used to analyze RAD-seq data from Zambian blue wildebeest.

BLASTsummary.R summarizes results from the runBLAST.py program in the DaCosta and Sorenson pipeline, and can be used to calculate summary statistics describing how many hits each cluster generated to the reference genome, the length of the alignments, and the percent similarity between the query sequences and the BLAST hits.
