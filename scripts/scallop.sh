#!/bin/bash
#impeleminting scallop 

paper_dir="$1"
hisat_dir="$2"
plateform="$3"
paper_name=$(echo "$(basename $paper_dir)")
script_path=$(dirname "${BASH_SOURCE[0]}")

# Assemble transcript:
while read tissue;do
   tissue_dir=$hisat_dir/$paper_name/$tissue
   for bam in $tissue_dir/*.sorted.bam; do #excute the loop for paired read
     scallop_output=$(echo "$(basename $bam)"| sed s/.sorted.bam/.gtf/)
     if [ "$plateform" == "HPC" ];then
       qsub -v output="$tissue_dir/$scallio_output",bam="$bam" $script_path/run_scallop.sh
     else
       export LD_LIBRARY_PATH=$plateform/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries 
       scallop -i $bam -o $tissue_dir/$scallop_output
     fi
   done
done < $paper_dir/tissues.txt
                		       
