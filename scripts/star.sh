#!/bin/bash
#impeleminting STAR 

paper_dir="$1"
star_dir="$2"
index_dir_path="$3"
plateform="$4"
paper_name=$(echo "$(basename $paper_dir)")

# loop over the paired reads from each sample to map them to the reference genome:
while read tissue;do
   output_dir_path=$star_dir/$paper_name/$tissue
   mkdir -p $output_dir_path;
   for sample in $paper_dir/$tissue/trimmed_reads/*_1.fastq.gz; do #excute the loop for paired read
     input1=$sample
     input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
     star_output_sam_prefix=$(echo "$(basename $sample)" | sed s/1.fastq.gz//)
     if [ "$plateform" == "HPC" ];then
       script_path=$(dirname "${BASH_SOURCE[0]}")
       qsub -v index="$index_dir_path/star_index",input1="$input1",input2="$input2",output="$output_dir_path/$star_output_sam_prefix" $script_path/run_star.sh
     else
       STAR --runThreadN 1 --genomeDir $index_dir_path/star_index --readFilesIn $input1 $input2 --readFilesCommand zcat --outSAMattributes XS --outFileNamePrefix $output_dir_path/$star_output_sam_prefix
     fi
   done
done < $paper_dir/tissues.txt

