#!/bin/bash

prog_path="$1"
paper_dir="$2"
trinity_dir="$3"
plateform="$4"
paper_name=$(echo "$(basename $paper_dir)")

while read tissue;do
      tissue_dir=$trinity_dir/$paper_name/$tissue
      for sample in $paper_dir/$tissue/trimmed_reads/*_1.fastq.gz; do #excute the loop for paired read
	  input1=$sample
	  input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
	  sampleDirName=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_output/)
	  outputName=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/.fasta/)
	  $prog_path/Trinity --seqType fq --max_memory 2G --output $tissue_dir/$sampleDirName \
		      	     --left $input1 \
		     	     --right $input2 \
		             --SS_lib_type RF \
		      	     --no_bowtie
          cp $tissue_dir/$sampleDirName/Trinity.fasta $tissue_dir/$outputName 
      done 
done < $paper_dir/tissues.txt


