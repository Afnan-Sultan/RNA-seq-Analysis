#!/bin/bash

paper_dir="$1"
trinity_dir="$2"
index_dir_path="$3"
merged_gtf_dir="$4"
plateform="$5"
bed_files_dir="$6"
paper_name=$(echo "$(basename $paper_dir)")
pipeline_name=$(echo "$(basename $trinity_dir)")

while read tissue;do
	tissue_dir=$trinity_dir/$paper_name/$tissue
	for fasta in $tissue_dir/*.fasta; do 
		outputName=$(echo "$(basename $fasta)" | sed s/.fasta/.psl/)
		blat -t=dna -q=rna $indext_dir_path/GRCh38.primary_assembly.genome.fa $fasta $tissue_dir/$output
	done	   
done < $paper_dir/tissues.txt

while read tissue;do
	tissue_dir=$trinity_dir/$paper_name/$tissue
	for psl in $tissue_dir/*.psl; do 
		outputName=$(echo "$(basename $psl)" | sed s/.psl/.bed/)
		pslToBed $psl $tissue_dir/$output
		cp $tissue_dir/$output $bed_files_dir/$tissue"_"$pipeline_name"_bamToBed.bed" #the name is for the sake of uniformity
	done	   
done < $paper_dir/tissues.txt

while read tissue;do
	tissue_dir=$trinity_dir/$paper_name/$tissue
	for bed in $tissue_dir/*.bed; do 
		outputName=$(echo "$(basename $psl)" | sed s/.bed/.GenePred/)
		bedToGenePred $bed $tissue_dir/$output
	done	   
done < $paper_dir/tissues.txt

while read tissue;do
	tissue_dir=$trinity_dir/$paper_name/$tissue
	for GenePred in $tissue_dir/*.GenePred; do 
		outputName=$(echo "$(basename $psl)" | sed s/.GenePred/.gtf/)
		genePredToGtf $GenePred $merged_gtf_dir/$paper_name/$output
	done	   
done < $paper_dir/tissues.txt

