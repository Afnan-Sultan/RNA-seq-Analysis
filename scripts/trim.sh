#!/bin/bash

paper_dir="$1"
prog_path="$2"
script_path=$(dirname "${BASH_SOURCE[0]}")  


##loop over libraries 	
for lib_dir in $paper_dir/* ; do
  lib_name=$(echo "$(basename $lib_dir)")
  if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
    ## loop over tissues
    for tissue_dir in $lib_dir/*; do   
      tissue_name=$(echo "$(basename $tissue_dir)")
      if [ -d $tissue_dir ]; then
         mkdir $tissue_dir/trimmed_reads
         cd $tissue_dir/trimmed_reads/
         for sample in $tissue_dir/merged_reads/*_1.fastq.gz;do
             input1=$sample
             input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
             output_pe1=$(echo "$(basename $input1)")
             output_pe2=$(echo "$(basename $input2)")
             output_se1=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_fSE.fastq/)
             output_se2=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_rSE.fastq/)
                
             ##use trimmomatic to perform trimming on the reads
             if [ "$prog_path" == "HPC" ];then
                 qsub -v R1_INPUT="$input1",R2_INPUT="$input2",output_pe1="$output_pe1",output_pe2="$output_pe2",output_se1="$output_se1",output_se2="$output_se2" $script_path/trim_job.sh
             else
                 TRIM=$prog_path/Trimmomatic-0.36
                 java -jar "$TRIM/trimmomatic" PE -phred33 $input1 $input2 $output_pe1 $output_se1 $output_pe2 $output_se2 ILLUMINACLIP:$TRIM/adapters/TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:2 MINLEN:20
            fi
         done
       fi
    done  
  fi
done
cd $work_dir
