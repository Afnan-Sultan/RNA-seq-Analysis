#!/bin/bash
                   
gtf_dir="$1"
index_dir_path="$2"
bedtools_dir="$3"
paper_name=$(echo "$(basename $gtf_dir)")

echo "performing gffCompare ....... "
# Examine how the transcripts compare with the reference annotation 
mkdir -p $gtf_dir/gffCompare       
for gtf in $gtf_dir/*merged.gtf; do 
    gff_output_prefix=$(echo "$(basename $gtf)"| sed s/_merged.gtf//)
    gffcompare -r $index_dir_path/gencode.v27.primary_assembly.annotation.gtf -o $gtf_dir/gffCompare/$gff_output_prefix $gtf 
done

echo "converting gtf to bed ....... "
#convert merged gtf file to bed file
for gtf in $gtf_dir/*merged.gtf; do            
    bed_output=$(echo "$(basename $gtf)"| sed s/.gtf/.bed/)
    cat $gtf| 
    awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' |
    sort -k1,1 -k2,2n |
    sortBed |
    mergeBed -i - > $bedtools_dir/$bed_output
done 

echo "performing intersection ....... "      
#applying bedtools analysis
for bed in $bedtools_dir/*merged.bed; do 
    bedtools_output=$(echo "$(basename $bed)"| sed s/.bed/_intersect_/)
    intersectBed -a $bedtools_dir/hg38_exons.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $gtf_dir/$bedtools_output"exons.bed"
    intersectBed -a $bedtools_dir/hg38_introns.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $gtf_dir/$bedtools_output"introns.bed"
    intersectBed -a $bedtools_dir/hg38_intergenic.bed -b $bed |sort -k1,1 -k2,2n | sortBed | mergeBed -i - > $gtf_dir/$bedtools_output"intergenic.bed"
done

##echo "calculating jaccard ... " 
#calculating intersection between the outputed genomic intersected bed files and reference genomic bed files using bedtools jaccard 
##for hgBed in $bedtools_dir/hg38_*.bed; do
##    regionName=$(echo "$(basename $hgBed)")
##    temp=$(echo $regionName | sed s/hg38_//)
##    for mergedBed in $paper_dir/*$temp; do
##        mBed=$(echo "$(basename $mergedBed)")
##	echo $regionName" jaccard "$mBed
##	bedtools jaccard -nonamecheck -a $hgBed -b $mergedBed
##    done >> $gtf_dir/jaccard.ods
##done 

echo "calculating jaccard ... " 
#calculating ntersection using bedtools jaccard 
for mergedBed in $bedtools_dir/*merged.bed; do
    mBed=$(echo "$(basename $mergedBed)")
    temp=${mBed%_merged.bed}
    for intersect_bed in $paper_dir/$temp*.bed; do
        iBed=$(echo "$(basename $intersect_bed)")
	echo $mBed" jaccard "$iBed
	bedtools jaccard -nonamecheck -a $intersect_bed -b $mergedBed
    done >> $gtf_dir/jaccard_mBed.ods
done 
