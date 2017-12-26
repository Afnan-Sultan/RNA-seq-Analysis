#!/bin/bash

index_dir_path="$1"
bedtools_dir="$2"

#extract exons, introns and intergenic coordinates, convert them to bed, sorting them and storing the result in separate files
cat $index_dir_path/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > $bedtools_dir/hg38_exons.bed

cat $index_dir_path/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b hg38_exons.bed > $bedtools_dir/hg38_introns.bed

cat $index_dir_path/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g $work_dir/hg38_data/hg38.genome > $bedtools_dir/hg38_intergenic.bed
  
