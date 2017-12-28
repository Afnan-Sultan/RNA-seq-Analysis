#!/bin/bash
#implementing Stringtie 

paper_dir="$1"
hisat_dir="$2"
plateform="$3"
paper_name=$(echo "$(basename $paper_dir)")
script_path=$(dirname "${BASH_SOURCE[0]}")

# Sort and convert the SAM file to BAM:
while read tissue;do
   tissue_dir=$hisat_dir/$paper_name/$tissue
   for sam in $tissue_dir/*.sam; do #excute the loop for paired read  
     label=${sam%.sam}
     if [ "$plateform" == "HPC" ];then
       qsub -v label="$label" $script_path/run_getBAM.sh
     else
       samtools view -u -o $label.bam $label.sam
       samtools sort -O bam -T $label -o $label.sorted.bam $label.bam
     fi
   done
done < $paper_dir/tissues.txt

