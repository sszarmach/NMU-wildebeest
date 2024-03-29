####################################################################################################
#
# BLASTsummary.R
#
# 14 August 2019
#
# Created by Steph Szarmach
# Northern Michigan University
#
# This script summarizes results from the runBLAST.py program in the DaCosta and Sorenson (2014) 
# ddRAD-seq pipeline. BLASTsummary.R can be used to calculate summary statistics describing how 
# many hits each cluster generated to the reference genome, the length of the alignments, 
# and the percent similarity between the sequences and the BLAST hits.
#
####################################################################################################

library(tidyverse)

#Set working directory to folder containing runBLAST.py output files
setwd("~/WildebeestProject/DataAnalysis/DaCostaSorensonPipeline/BLAST/BLASTtoWBgenome")

#Read *BLASTsummary.out file generated by runBLAST.py (converted to .csv format in Excel)
#No headings are included in raw *BLASTsummary.out file
#In Excel add the following heading row: Clstr	num_hits	result_code	sub_acc_ver	align_start	align_dir	query_len	align_len	percent_id	evalue	sub_acc_ver_2	align_start_2	align_dir_2	query_len_2	align_len_2	percent_id_2	evalue_2
summary = read.csv("wbBlasted_wbBLASTsummary.csv")
#Change Clstr from integer to character
summary$Clstr = as.character(summary$Clstr)

### HOW MANY CLUSTERS WERE ASSIGNED EACH RESULT CODE? ############################################################
# DaCosta & Sorenson Pipleline outputs result codes for each cluster
# one: one hit, one+: one hit with good match, other inferior matches, tied: two top hits equally matched
# best: multiple hits, but one is the best match, multiple: multiple high-quality hits

summary %>%
  group_by(result_code) %>%
  summarise(count = n())

#Create bar plot of number of clusters assigned to each result code
ggplot(summary) +
  geom_bar(mapping = aes(result_code, fill=result_code)) +
  labs(x = "Result Code", y = "Count") +
  scale_fill_discrete(name = "Result Codes")

### BLAST HITS PER CLUSTER SUMMARY STATISTICS ######################################################################

options(scipen=10000)

summary %>%
  summarise(Min_Hits = min(num_hits),
              Max_Hits = max(num_hits),
              Med_Hits = median(num_hits),
              Mean_Hits = mean(num_hits))

#Create histogram of number of hits per cluster
ggplot(summary) +
  geom_histogram(mapping = aes(num_hits))

### NUMBER OF HITS TO EACH ACCESSION NUMBER #############################################################################
# Calculate how many clusters aligned to each chromosome or scaffold of the reference genome

#Create a .csv file with the following columns: sub_acc_ver (accession #), chromosome (or scaffold ID), length (length of chrom. or scaffold in bp)
#Read chromosome/scaffold file and join to summary data set
scaffolds = read.csv("wb_scaffolds.csv")
summary = summary %>%
  left_join(scaffolds, by="sub_acc_ver")

#Optional: If scaffold length is included in the scaffold ID, this code can place the length into a new column
scaffolds = separate(scaffolds, sub_acc_ver, into = c("scaffold", "length"), sep = "_size", remove=TRUE)
scaffolds$length = as.numeric(scaffolds$length)

#How many clusters aligned to each scaffold or chromosome?
scaffoldhits = summary %>%
  filter(!is.na(sub_acc_ver)) %>%
  group_by(sub_acc_ver) %>%
  tally()
View(scaffoldhits)

#Scatterplot of number of hits vs. scaffold/chromosome length
ggplot(scaffoldhits) +
  geom_point(mapping=aes(length, n)) +
  geom_smooth(mapping=aes(length, n), method = "lm", se=FALSE, color="red") +
  xlab("Scaffold Length (bp)")+
  ylab("Number of BLAST Hits") +
  theme_bw() +
  theme(axis.title.x = element_text(face="bold", size=14)) +
  theme(axis.title.y = element_text(face="bold", size=14)) 

#Is there a significant correlation between the length of a scaffold and the number of clusters with 
#BLAST hits to that scaffold? Reflects whether RAD-tags are evenly spaced throughout genome

cor(scaffoldhits$length, scaffoldhits$n, method='spearman') #cor(xvar,yvar,method='') method=pearson, spearman, or kendall
cor.test(scaffoldhits$length, scaffoldhits$n, method= 'spearman')

#Create bar plot of number of hits per chromosome or scaffold

#Optional: If there are small scaffolds with very low numbers of hits, remove from dataset
large_scaffoldhits = scaffoldhits %>%
  filter(n>10) %>%
  left_join(scaffolds, by = "sub_acc_ver")

ggplot(large_scaffoldhits) +
  geom_col(mapping=aes(x = reorder(chromosome, sort(as.numeric(chromosome))), y = n)) +
  labs(x = "Chromosome", y = "Count")

#Standardize hits per chromosome/scaffold by dividing number of hits by scaffold length
standardized = large_scaffoldhits %>%
  mutate(std = n/length)

ggplot(standardized) +
  geom_col(mapping=aes(x = reorder(chromosome, sort(as.numeric(chromosome))), y = std)) +
  labs(x = "Chromosome", y = "Count adjusted by chromosome length")

### ALIGNMENT LENGTH ###########################################################################################
# Calculate summary statistics for the lengths of each alignment to the reference genome

options(digits=3)

#Length of query sequences
queries = summary %>%
  summarise(min_query = min(query_len, na.rm = TRUE), 
            max_query = max(query_len, na.rm = TRUE),
            med_query = median(query_len, na.rm = TRUE), 
            mean_query = mean(query_len, na.rm = TRUE))

#Length of alignments
alignments = summary %>%
  summarise(min_align = min(align_len, na.rm = TRUE), 
            max_align = max(align_len, na.rm = TRUE),
            med_align = median(align_len, na.rm = TRUE), 
            mean_align = mean(align_len, na.rm = TRUE))

### PERCENT ID #################################################################################################
#Calculate summary statistics for the percent identity between query sequences and reference genome

percentIDs = summary %>%
  summarise(min_percent = min(percent_id, na.rm = TRUE), 
            max_percent = max(percent_id, na.rm = TRUE),
            med_percent = median(percent_id, na.rm = TRUE), 
            mean_percent = mean(percent_id, na.rm = TRUE))

#Create histogram of percent IDs per cluster
ggplot(summary) +
  geom_histogram(mapping=aes(percent_id))
