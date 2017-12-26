#!/bin/bash
#implementing HISAT2 and Stringtie 

paper_dir="$1"
hisat_dir="$2"
index_dir_path="$3"
paper_name=$(echo "$(basename $paper_dir)")

# loop over the paired reads from each sample to map them to the reference genome:
for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
       for tissue_dir in $lib_dir/*; do
	   if [ -d $tissue_dir ]; then
	      tissue_name=$(echo "$(basename $tissue_dir)")
	      output_dir_path=$hisat_dir/$paper_name/$lib_name/$tissue_name
	      for sample in $tissue_dir/trimmed_merged_reads/*_1.fastq.gz; do #excute the loop for paired read
		  input1=$sample
		  input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
		  hisat_output=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/.sam/)
		  hisat2 -p 8 --dta -x $index_dir_path/hisat_index/hg38 -1 $input1 -2 $input2 -S $output_dir_path/$hisat_output
	      done
	    fi	    
	done  
     fi
done 


