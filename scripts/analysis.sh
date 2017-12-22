#!/bin/bash

for pipeline in $work_dir/*
    pipeline_name=$(echo "$(basename $pipeline)")
    if [[ $pipeline_name == hisat* || $pipeline_name == star* ]]; then
    for paper_dir in $pipeline_dir/final_output/*; do
        if [ -d $paper_dir ]; then
        paper_name=$(echo "$(basename $paper_dir)")
        for gtf_file in $paper_dir/*.gtf; do 
        
            # Examine how the transcripts compare with the reference annotation
            gff_output_prefix=$(echo "$(basename $gtf_file)"| sed s/stringtie_merged.gtf//)
            gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $work_dir/$pipeline_name/final_output/$paper_name/$gff_output_prefix $gtf_file
        
            #convert merged gtf file to bed file
            bed_output=$(echo "$(basename $gtf_file)"| sed s/.gtf/.bed/)
            cat $gtf_file| 
            awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
            sortBed | > $work_dir/$pipeline_name/final_output/$paper_name/$bed_output
            
            #applying bedtools analysis
            bedtools_input=$work_dir/$pipeline_name/final_output/$paper_name/$bed_output
            bedtools_output=$(echo "$(basename $gtf_file)"| sed s/.gtf/_intersect_/)
            intersectBed -a $work_dir/bedtools/hg38_exons.bed -b $bedtools_input > $work_dir/$pipeline/final_output/$paper_name/$bedtools_output"exons.bed"
            intersectBed -a $work_dir/bedtools/hg38_introns.bed -b $bedtools_input > $work_dir/$pipeline/final_output/$paper_name/$bedtools_output"introns.bed"
            intersectBed -a $work_dir/bedtools/hg38_intergenic.bed -b $bedtools_input > $work_dir/$pipeline/final_output/$paper_name/$bedtools_output"intergenic.bed"

        done
        fi
    done
    fi
done
