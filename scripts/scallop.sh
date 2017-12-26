#!/bin/bash
#impeleminting scallop 

tissue_dir="$1"
prog_path="$2"

# Sort and convert the SAM file to BAM:

# Sort and convert the SAM file to BAM:
for sam in $tissue_dir/*.sam; do #excute the loop for paired read  
    samtools_output=$(echo "$(basename $sam)" | sed s/.sam/.bam/)
    samtools sort -o $tissue_dir/$samtools_output $sam
done

# Assemble transcripts:
export LD_LIBRARY_PATH=$prog_path/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries 
for bam in $tissue_dir/*.bam; do #excute the loop for paired read
    scallop_output=$(echo "$(basename $bam)"| sed s/.bam/.gtf/)
    scallop -i $bam -o $tissue_dir/$scallop_output
done
                 		       
