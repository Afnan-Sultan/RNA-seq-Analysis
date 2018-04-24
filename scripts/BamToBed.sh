#!/bin/bash

paper_dir="$1"
pipeline_dir="$2"
platform="$3"
bed_files_dir="$4"
assembler="$5"
paper_name=$(echo "$(basename $paper_dir)")

while read tissue;do
	tissue_dir=$pipeline_dir/$paper_name/$tissue
	for bam in $tissue_dir/*.bam; do
		bamToBed -i $bam |sort -k1,1 -k2,2n | sortBed >> $bed_files_dir/$tissue"_"$assembler"_bamToBed.bed"
	done
done < $paper_dir/tissues.txt