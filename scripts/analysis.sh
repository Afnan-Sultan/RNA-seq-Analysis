#!/bin/bash
                   
paper_dir="$1"
index_dir_path="$2"
bedtools_dir="$3"
paper_name=$(echo "$(basename $paper_dir)")

# Examine how the transcripts compare with the reference annotation 
mkdir -p $paper_dir/gffCompare       
for gtf in $paper_dir/GTFs/*merged.gtf; do 
    gff_output_prefix=$(echo "$(basename $gtf)"| sed s/merged.gtf//)
    gffcompare -r $index_dir_path/gencode.v27.annotation.gtf -o $paper_dir/gffCompare/$gff_output_prefix $gtf 
done

#convert merged gtf file to bed file
for gtf in $paper_dir/*merged.gtf; do            
    bed_output=$(echo "$(basename $gtf)"| sed s/.gtf/.bed/)
    cat $gtf| 
    awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
    sortBed > $bedtools_dir/$bed_output
done  
         
#applying bedtools analysis
for bed in $bedtools_dir/*merged.bed; do 
    bedtools_output=$(echo "$(basename $bed)"| sed s/.bed/_intersect_/)
    intersectBed -a $bedtools_dir/hg38_exons.bed -b $bed > $paper_dir/$bedtools_output"exons.bed"
    intersectBed -a $bedtools_dir/hg38_introns.bed -b $bed > $paper_dir/$bedtools_output"introns.bed"
    intersectBed -a $bedtools_dir/hg38_intergenic.bed -b $bed > $paper_dir/$bedtools_output"intergenic.bed"
done
