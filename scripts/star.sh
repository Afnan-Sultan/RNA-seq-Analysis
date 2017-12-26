#!/bin/bash
#impeleminting STAR 

paper_dir="$1"
star_dir="$2"
index_dir_path="$3"
paper_name=$(echo "$(basename $paper_dir)")

for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
       for tissue_dir in $lib_dir/*; do
	   if [ -d $tissue_dir ]; then
	      tissue_name=$(echo "$(basename $tissue_dir)")
	      output_dir_path=$star_dir/$paper_name/$lib_name/$tissue_name
	      for sample in $tissue_dir/trimmed_merged_reads/*_1.fastq.gz; do #excute the loop for paired sample
                  input1=$sample
                  input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
                  star_output_sam_prefix=$(echo "$(basename $sample)" | sed s/1.fastq.gz//)
		  echo $star_output_sam_prefix 
                  STAR --runThreadN 1 --genomeDir $index_dir_path/star_index --readFilesIn $input1 $input2 --readFilesCommand zcat --outSAMattributes XS --outFileNamePrefix $output_dir_path/$star_output_sam_prefix
	      done
	    fi	    
	done  
     fi
done 

