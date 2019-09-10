#!/bin/bash
                   
bed_files_dir="$1"

echo "performing intersection ....... "      
#applying bedtools analysis
for bed in $bed_files_dir/$paper_name/*.bed; do 
    bedtools_output=$(echo "$(basename $bed)"| sed s/.bed/_intersect_/)
    intersectBed -a $bed_files_dir/hg38_exons.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $bed_files_dir/$bedtools_output"exons.bed"
    intersectBed -a $bed_files_dir/hg38_introns.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $bed_files_dir/$bedtools_output"introns.bed"
    intersectBed -a $bed_files_dir/hg38_intergenic.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $bed_files_dir/$bedtools_output"intergenic.bed"
done

echo "calculating jaccard ... " 
#calculating intersection using bedtools jaccard 
for mergedBed in $bed_files_dir/*.bed; do
    mBed=$(echo "$(basename $mergedBed)")
    temp=${mBed%_merged.bed}
    for intersect_bed in $bed_files_dir/$temp*.bed; do
        iBed=$(echo "$(basename $intersect_bed)")
	echo $mBed" jaccard "$iBed
	bedtools jaccard -nonamecheck -a $intersect_bed -b $mergedBed
    done >> $bed_files_dir/jaccard_mBed.txt
done 
