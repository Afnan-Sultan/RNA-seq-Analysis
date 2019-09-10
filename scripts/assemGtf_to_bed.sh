#!/bin/bash

paper_dir="$1"
in_dir="$2"
out_dir="$3"
paper_name=$(echo "$(basename $paper_dir)")

echo "converting assembled gtf to bed ....... "
#convert merged gtf file to bed file
for gtf in $in_dir/$paper_name/*.gtf; do            
    bed_output=$(echo "$(basename $gtf)"| sed s/.gtf/.bed/)
    cat $gtf| 
    awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' |
    sort -k1,1 -k2,2n |
    sortBed |
    mergeBed -i - > $out_dir/$paper_name/$bed_output
done 
