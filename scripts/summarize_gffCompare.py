#!/usr/bin/python

import sys
import os

infile_dir = sys.argv[1]
outfile_dir = sys.argv[2]

stats_files = []
for file in os.listdir(infile_dir):
    if file.endswith(".stats") or file.endswith(".out"):
        stats_files.append(file)

outfile = open(outfile_dir + "/gffCompare_stats_summary.csv","w")
outfile.write("aligner,tissue,tissue_stat,lib_id,base,base,exon,exon,intron,intron,intron_chain,intron_chain,transcript,transcript,locus,locus\n,,,,sensitivity,specificity,sensitivity,specificity,sensitivity,specificity,sensitivity,specificity,sensitivity,specificity,sensitivity,specificity\n")
for stat_file in stats_files:        
    infile = open(infile_dir + "/" +stat_file).readlines()    
    command = infile[1].split("/")
    for part in command:
        if part.startswith("poly") or part.startswith("ribo"):
            name = part.split(".")[0]
            name_split = name.split("_")
            tissue = name_split[0]
            tissue_stat = name_split[1]
            aligner = name_split[2]

            for part in name_split:
                if part.isdigit():
                    cell_id = part
                    break
                else: 
                    cell_id = " "
            lib_data = aligner + "," + tissue + "," + tissue_stat + "," + cell_id 
    
    table = []
    for line in infile[10:16]:
        line = line.strip("\n").split(":")[1].split("|")[:2]
        table.append(",".join(line))
    
    values = ",".join(table)
    outfile.write(lib_data+','+values+'\n')
outfile.close()    
