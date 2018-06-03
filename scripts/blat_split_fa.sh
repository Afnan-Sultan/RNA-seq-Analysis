#!/bin/bash

paper_dir="$1"
trinity_dir="$2"
index_dir_path="$3"
paper_name=$(echo "$(basename $paper_dir)")
genome=$index_dir_path/GRCh38.primary_assembly.genome.fa
while read tissue;do
	tissue_dir=$trinity_dir/$paper_name/$tissue
	for fasta in $tissue_dir/*.fasta; do
		fasta_name=$(echo "$(basename $fasta)" | sed 's/.fasta//')
		mkdir $tissue_dir/$fasta_name
		transcript_count=0
		file_count=0
		cat $fasta|
		while read line; do
			if [[ $line == *TRINITY_* ]]; then
				transcript_count=$(($transcript_count + 1))
			fi
			if [[ $transcript_count -gt 1000 ]]; then
				file_count=$(($file_count + 1))
				transcript_count=0
			fi
			echo $line >> $tissue_dir/$fasta_name/$fasta_name$file_count.fasta				
		done
		for file in $tissue_dir/$fasta_name/*; do
			output=$(echo $(basename $file) | sed 's/.fasta//')
			blat -t=dna -q=rna -fine $genome $tissue_dir/$fasta_name/$output.fasta $tissue_dir/$fasta_name/$output.psl
		done 
		for psl in $tissue_dir/$fasta_name/*.psl; do
			output=$(echo $fasta_name)
			cat $psl >> $tissue_dir/$output.psl
		done
	done	   
done < $paper_dir/tissues.txt

