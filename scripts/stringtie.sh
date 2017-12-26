#!/bin/bash
#implementing Stringtie 

tissue_dir="$1"

# Sort and convert the SAM file to BAM:
for sam in $tissue_dir/*.sam; do #excute the loop for paired read  
    samtools_output=$(echo "$(basename $sam)" | sed s/.sam/.bam/)
    samtools sort -o $tissue_dir/$samtools_output $sam
done

# Assemble transcript:
for bam in $tissue_dir/*.bam; do #excute the loop for paired read
    stringtie_output=$(echo "$(basename $bam)"| sed s/.bam/.gtf/)
    label=$(echo "$(basename $bam)"| sed s/.bam//)
    stringtie -o $tissue_dir/$stringtie_output -l $label $bam
done                
		        





