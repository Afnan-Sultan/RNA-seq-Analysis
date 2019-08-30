#!/usr/bin/env Rscript

#catch the file directory
args = commandArgs(trailingOnly=TRUE)
dir = args[1]

#download required libraries
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")
BiocManager::install("tximport")

#import required libraries
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(tximport)

#create transcript - gene index
txdb = TxDb.Hsapiens.UCSC.hg38.knownGene
k = keys(txdb, keytype = "TXNAME")
tx2gene = select(txdb, k, "GENEID", "TXNAME")

#store the samples quantification files to be used with tximport
files_names = list.files(dir)
files = file.path(dir,files_names, "quant.sf")
names(files) = files_names

#run tximport
txi = tximport(files, type = "salmon", tx2gene = tx2gene)

#export results
write.csv(txi$count, file.path(dir,"counts.csv"))
write.csv(txi$abundance, file.path(dir,"abundance.csv"))
write.csv(txi$length, file.path(dir,"length.csv"))
write.csv(txi$countsFromAbundance, file.path(dir,"countsFromAbundance.csv"))
