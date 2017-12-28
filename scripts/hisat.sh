#!/bin/bash
#implementing HISAT2 and Stringtie 

paper_dir="$1"
hisat_dir="$2"
index_dir_path="$3"
plateform="$4"
paper_name=$(echo "$(basename $paper_dir)")

# loop over the paired reads from each sample to map them to the reference genome:
while read tissue;do
   output_dir_path=$hisat_dir/$paper_name/$tissue
   mkdir -p $output_dir_path;
   for sample in $paper_dir/$tissue/trimmed_reads/*_1.fastq.gz; do #excute the loop for paired read
     input1=$sample
     input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
     hisat_output=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/.sam/)
     echo $input1 $input2 $hisat_output
     if [ "$plateform" == "HPC" ];then
       script_path=$(dirname "${BASH_SOURCE[0]}")
       qsub -v index="$index_dir_path/hisat_index/hg38",input1="$input1",input2="$input2",output="$output_dir_path/$hisat_output" $script_path/run_hisat.sh
     else
       hisat2 -p 8 --dta -x $index_dir_path/hisat_index/hg38 -1 $input1 -2 $input2 -S $output_dir_path/$hisat_output;
     fi
   done
done < $paper_dir/tissues.txt


