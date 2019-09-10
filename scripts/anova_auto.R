#!/usr/bin/env Rscript

#catch the file directory
args = commandArgs(trailingOnly=TRUE)
dir = args[1]
data_type = args[2]

files = list.files(dir, pattern=paste('*',data_type,'_split.csv',sep='')
for(csv in files){
  print(csv)
  samples = read.csv(csv)
  anova_test = aov(region ~ aligner, data = samples)
  print(summary(anova_test)[[1]][["Pr(>F)"]][1])
  cat('\n-----------------------------------------------------------\n')
}
