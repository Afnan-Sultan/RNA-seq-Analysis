#!/bin/bash

tissue_dir="$1"
paper_dir="$2"

echo $paper_dir 
echo $tissue_dir


#stor gtf paths for each sample in a txt file to pass it to cufflinks
#for gtf in $tissue_dir/*.gtf; do
#    echo $gtf 
#done > $tissue_dir/gtf_list.txt

cd $tissue_dir
cuffMerge_output=$(echo "$(basename $tissue_dir"_scallop_merged.gtf")")
cuffmerge $tissue_dir/gtf_list.txt 
cp $tissue_dir/merged_asm/merged.gtf $paper_dir/$cuffMerge_output
cd $work_dir
