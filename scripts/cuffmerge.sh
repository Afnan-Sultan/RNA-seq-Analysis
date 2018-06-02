#!/bin/bash

paper_dir="$1"
star_dir="$2"
merged_gtf_dir="$3"
plateform="$4"
paper_name=$(echo "$(basename $paper_dir)")

if [ "$plateform" == "HPC" ];then 
  module load Python/2.7.2; module swap GNU GNU/4.4.5; module load cufflinks/2.2.1;echo "module loading done";fi
while read tissue;do
    tissue_dir=$star_dir/$paper_name/$tissue
    cuffMerge_output=$(echo "$(basename $tissue_dir"_scallop_merged.gtf")")
    cuffmerge -o $star_dir/$paper_name/ <(ls $tissue_dir/*.gtf)
    mv $star_dir/$paper_name/merged.gtf $merged_gtf_dir/$paper_name/$cuffMerge_output
done < $paper_dir/tissues.txt


