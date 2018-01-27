#!/bin/bash

index_dir_path="$1"
bedtools_dir="$2"
plateform="$3"

if [ "$plateform" == "HPC" ];then module swap GNU GNU/4.4.5; module load BEDTools/2.24.0;fi

#extract exons, introns and intergenic coordinates, convert them to bed, sorting them and storing the result in separate files
cat $index_dir_path/gencode.v27.primary_assembly.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sort -k1,1 -k2,2n |
sortBed | 
mergeBed -i - > $bedtools_dir/hg38_exons.bed

cat $index_dir_path/gencode.v27.primary_assembly.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sort -k1,1 -k2,2n |
sortBed | 
mergeBed -i - |
subtractBed -nonamecheck -a stdin -b $bedtools_dir/hg38_exons.bed | 
sortBed > $bedtools_dir/hg38_introns.bed

cat $index_dir_path/gencode.v27.primary_assembly.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
#sortBed | 
complementBed -i stdin -g $index_dir_path/hg38.genome |
mergeBed |
sort -k1,1 -k2,2n |
sortBed > $bedtools_dir/hg38_intergenic.bed
  
  
