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
	for fasta in $tissue_dir/SAMN02205259.fasta; do 
	    output=$(echo $(basename $fasta) | sed 's/.fasta//')
            genome=$index_dir_path/GRCh38.primary_assembly.genome.fa
            if [ "$plateform" == "HPC" ];then
                script_path=$(dirname "${BASH_SOURCE[0]}");
                qsub -v tissue="$tissue",tissue_dir="$tissue_dir",genome="$genome",output="$output" "$script_path/run_faToGtf.sh";
            else
		blat -t=dna -q=rna -fine $genome $output.fasta $tissue_dir/$output.psl
                pslToBed $tissue_dir/$output.psl $tissue_dir/$output.bed
                #cp $tissue_dir/$output.bed $bed_files_dir/$tissue"_"$pipeline_name"_bamToBed.bed" #the name is for the sake of uniformity
                bedToGenePred $tissue_dir/$output.bed $tissue_dir/$output.GenePred
                genePredToGtf file $tissue_dir/$output.GenePred $tissue_dir/$output.gtf
                #genePredToGtf $tissue_dir/$output.GenePred $merged_gtf_dir/$paper_name/$output.gtf
            fi
	done	   
done < $paper_dir/tissues.txt
