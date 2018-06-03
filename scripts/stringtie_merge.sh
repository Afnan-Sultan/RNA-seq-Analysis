#!/bin/bash

paper_dir="$1"
hisat_dir="$2"
merged_gtf_dir="$3"
plateform="$4"
paper_name=$(echo "$(basename $paper_dir)")

if [ "$plateform" == "HPC" ];then module swap GNU GNU/4.4.5; module load stringtie/1.3.3b; echo "module loading done";fi
while read tissue;do
    tissue_dir=$hisat_dir/$paper_name/$tissue
    stringtieMerge_output=$(echo "$(basename $tissue_dir"_stringtie_merged.gtf")")
    stringtie --merge $tissue_dir/*.gtf -o $merged_gtf_dir/$paper_name/$stringtieMerge_output
done < $paper_dir/tissues.txt

