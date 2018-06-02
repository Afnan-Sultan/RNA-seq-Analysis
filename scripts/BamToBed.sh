#!/bin/bash

paper_dir="$1"
pipeline_dir="$2"
plateform="$3"
bed_files_dir="$4"
assembler="$5"
paper_name=$(echo "$(basename $paper_dir)")

while read tissue;do
	tissue_dir=$pipeline_dir/$paper_name/$tissue
	for bam in $tissue_dir/*.bam; do
                if [ $plateform == "HPC" ];then
                  module load BEDTools/2.24.0;fi
		bamToBed -i $bam |sort -k1,1 -k2,2n | sortBed >> $bed_files_dir/$tissue"_"$assembler"_bamToBed.bed"
	done
done < $paper_dir/tissues.txt
