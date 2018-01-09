#!/bin/bash

paper_dir="$1"
star_dir="$2"
plateform="$3"
paper_name=$(echo "$(basename $paper_dir)")

while read tissue;do
    tissue_dir=$star_dir/$paper_name/$tissue
    cuffMerge_output=$(echo "$(basename $tissue_dir"_scallop_merged.gtf")")
    if [ "$plateform" == "HPC" ];then module swap GNU GNU/4.4.5; module load cufflinks/2.2.1;fi
    cuffmerge -o $star_dir/$paper_name/ <(ls $tissue_dir/*.gtf)
    mv $star_dir/$paper_name/merged.gtf $star_dir/$paper_name/$cuffMerge_output
done < $paper_dir/tissues.txt


