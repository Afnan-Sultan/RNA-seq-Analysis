#!/bin/bash

paper_dir="$1"                   
merged_gtf_dir="$2"
index_dir_path="$3"
paper_name=$(echo "$(basename $gtf_dir)")

echo "performing gffCompare ....... "
# Examine how the transcripts compare with the reference annotation 
mkdir -p $merged_gtf_dir/$paper_name/gffCompare      
for gtf in $merged_gtf_dir/$paper_name/*merged.gtf; do 
    gff_output_prefix=$(echo "$(basename $gtf)"| sed s/_merged.gtf//)
    gffcompare -r $index_dir_path/gencode.v27.primary_assembly.annotation.gtf -o $merged_gtf_dir/$paper_name/gffCompare/$gff_output_prefix $gtf 
done


