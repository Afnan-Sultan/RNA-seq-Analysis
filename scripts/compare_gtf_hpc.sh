#!/bin/bash
                   
gtf_dir="$1"
index_dir_path="$2"
bedtools_dir="$3"
path_To_gffcompare="$4"
paper_name=$(echo "$(basename $gtf_dir)")

# Examine how the transcripts compare with the reference annotation 

## install gffcompre
#python -m virtualenv PythonENV && source PythonENV/bin/activate
#git clone https://github.com/gpertea/gclib #installing dependancy of gffcompare
#git clone https://github.com/gpertea/gffcompare #installing gffcompare-0.10.1
#cd gffcompare
#make release

source PythonENV/bin/activate

mkdir -p $gtf_dir/gffCompare       
for gtf in $gtf_dir/*merged.gtf; do 
    gff_output_prefix=$(echo "$(basename $gtf)"| sed s/_merged.gtf//)
    $path_To_gffcompare/gffcompare -r $index_dir_path/gencode.v27.primary_assembly.annotation.gtf -o $gtf_dir/gffCompare/$gff_output_prefix $gtf 
done

module swap GNU GNU/4.4.5; module load BEDTools/2.24.0;
#convert merged gtf file to bed file
for gtf in $gtf_dir/*merged.gtf; do            
    bed_output=$(echo "$(basename $gtf)"| sed s/.gtf/.bed/)
    cat $gtf| 
    awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
    sortBed |
    mergeBed -i - > $bedtools_dir/$bed_output
done  
         
#applying bedtools analysis
for bed in $bedtools_dir/*merged.bed; do 
    bedtools_output=$(echo "$(basename $bed)"| sed s/.bed/_intersect_/)
    intersectBed -a $bedtools_dir/hg38_exons.bed -b $bed > $gtf_dir/$bedtools_output"exons.bed"
    intersectBed -a $bedtools_dir/hg38_introns.bed -b $bed > $gtf_dir/$bedtools_output"introns.bed"
    intersectBed -a $bedtools_dir/hg38_intergenic.bed -b $bed > $gtf_dir/$bedtools_output"intergenic.bed"
done
