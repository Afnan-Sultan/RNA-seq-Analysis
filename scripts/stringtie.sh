#!/bin/bash
#implementing Stringtie 

paper_dir="$1"
hisat_dir="$2"
plateform="$3"
paper_name=$(echo "$(basename $paper_dir)")
script_path=$(dirname "${BASH_SOURCE[0]}")

# Assemble transcript:
while read tissue;do
   tissue_dir=$hisat_dir/$paper_name/$tissue
   for bam in $tissue_dir/*.sorted.bam; do #excute the loop for paired read
      stringtie_output=$(echo "$(basename $bam)"| sed s/.sorted.bam/.gtf/)
      label=$(echo "$(basename $bam)"| sed s/.sorted.bam//)
     if [ "$plateform" == "HPC" ];then
       qsub -v output="$tissue_dir/$stringtie_output",label="$label",bam="$bam" $script_path/run_stringtie.sh
     else
       stringtie -o $tissue_dir/$stringtie_output -l $label $bam
     fi
   done                
done < $paper_dir/tissues.txt

