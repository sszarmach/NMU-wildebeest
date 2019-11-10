####################################################################################################
#
# DemultiplexSummary.R
#
# 29 July 2019
#
# Created by Steph Szarmach
# Northern Michigan University
#
# This script summarizes results from the ddRADparser.py program in the DaCosta and Sorenson (2014) 
# ddRAD-seq pipeline. DemultiplexSummary.R can be used to calculate summary statistics describing
# how many sequence reads were assigned to each individual after barcodes were parsed.
#
####################################################################################################

library(tidyverse)

#Set working directory to folder containing ddRADparser.py output files
setwd("~/WildebeestProject/DataAnalysis/DaCostaSorensonPipeline/ddRADparserSummaries")

#Read *summary.out file generated from ddRADparser.py (converted to .csv format in Excel)
summary = read.csv("ddRADparser_Summary_IC.csv")

#Calculate summary statistics describing number of reads assigned to each individual
sumstats = summary %>%
  summarize(total_reads = sum(Seq_count),
            avg_reads = mean(Seq_count), 
            sd_reads = sd(Seq_count),
            max_reads = max(Seq_count), 
            min_reads = min(Seq_count))
View(sumstats)

#Create histogram of number of sequences per wildebeest
ggplot(data = summary) +
  geom_histogram(mapping=aes(Seq_count), binwidth = 200000)

#Create bar chart of number of sequences per wildebeest
#Order individuals by decreasing number of reads
summary$SampleID = factor(summary$SampleID, levels = summary$SampleID[order(-summary$Seq_count)])
options(scipen=10000)
ggplot(data=summary) +
  geom_col(mapping=aes(x=SampleID, y=Seq_count)) +
  xlab("Sample ID") +
  ylab("No. Reads") +
  theme_bw() +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  theme(axis.title.x = element_text(face="bold", size=14)) +
  theme(axis.title.y = element_text(face="bold", size=14))
  
