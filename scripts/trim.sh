#!/bin/bash

paper_dir="$1"
prog_path="$2"

if [ "$prog_path" == "HPC" ];then
   module load Trimmomatic/0.33 
else 
   TRIM=$prog_path
fi
	
#apply trimming and then mrging for the reads
for lib_dir in $paper_dir/* ; do
  lib_name=$(echo "$(basename $lib_dir)")                                     #loop over libraries 
  if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
    for tissue_dir in $lib_dir/*; do                                            #loop over samples
      tissue_name=$(echo "$(basename $tissue_dir)")
      if [ -d $tissue_dir ]; then
         for sample in $tissue_dir/merged_reads/*_1.fastq.gz;do
             mkdir $tissue_dir/trimmed_merged_reads                                      #create folder to stor trimmed reads
             cd $tissue_dir/trimmed_merged_reads/
                 input1=$sample
                 input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
		 zcat $input2
                 output_pe1=$(echo "$(basename $input1)")
                 output_pe2=$(echo "$(basename $input2)")
                 output_se1=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_fSE.fastq/)
                 output_se2=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_rSE.fastq/)
                
                 ##use trimmomatic to perform trimming on the reads
                 java -jar "$TRIM/trimmomatic" PE -phred33 $input1 $input2 $output_pe1 $output_se1 $output_pe2 $output_se2 ILLUMINACLIP:$TRIM/adapters/TruSeq2-PE.fa:2:30:10 SLIDINGWINDOW:4:2 MINLEN:20
         done
       fi
    done  
  fi
done
cd $work_dir
