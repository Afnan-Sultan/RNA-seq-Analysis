#!/bin/bash
                   
paper_dir="$1"
index_dir_path="$2"
bedtools_dir="$3"
paper_name=$(echo "$(basename $paper_dir)")

# Examine how the transcripts compare with the reference annotation        
for gtf in $paper_dir/*.gtf; do 
    gff_output_prefix=$(echo "$(basename $gtf_file)"| sed s/stringtie_merged.gtf//)
    gffcompare -r $index_dir_path/gencode.v27.annotation.gtf -o $paper_dir/$gff_output_prefix $gtf 
done

#convert merged gtf file to bed file
for gtf in $paper_dir/*.gtf; do            
    bed_output=$(echo "$(basename $gtf)"| sed s/.gtf/.bed/)
    cat $gtf_file| 
    awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
    sortBed | > $paper_dir/$bed_output
done  
         
#applying bedtools analysis
for bed in $paper_dir/*.bed; do 
    bedtools_output=$(echo "$(basename $bed)"| sed s/.bed/_intersect_/)
    intersectBed -a $bedtools_dir/hg38_exons.bed -b $bedtools_input > $paper_dir/$bedtools_output"exons.bed"
    intersectBed -a $bedtools_dir/hg38_introns.bed -b $bedtools_input > $paper_dir/$bedtools_output"introns.bed"
    intersectBed -a $bedtools_dir/hg38_intergenic.bed -b $bedtools_input > $paper_dir/$bedtools_output"intergenic.bed"
done
