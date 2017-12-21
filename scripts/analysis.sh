#!/bin/bash


# Examine how the transcripts compare with the reference annotation
for pipeline in $work_dir/*
    pipeline_name=$(echo "$(basename $pipeline)")
    if [[ $pipeline_name == hisat* || $pipeline_name == star* ]]; then
    for paper_dir in $pipeline_dir/*; do
        paper_name=$(echo "$(basename $paper_dir")
        if [[ -d $paper_dir && $paper_dir != $work_dir/$pipeline/final_output ]]; then 
        for gtf_file in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
            output=$(echo "$(basename $gtf_file)"| sed s/stringtie_merged.gtf//)
            gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $work_dir/$pipeline_name/final_output/$paper_name/$output $gtf_file
        done
        fi
    done
    fi
done


for pipeline in $work_dir/*; do
    pipeline_name=$(echo "$(basename $pipeline)")
    if [[ -d $pipeline && $pipeline_name == hisat* || $pipeline_name == star* ]]; then
    for paper_dir in $pipeline_dir/final_output/*; do   if [[ -d $paper_dir ]]; do
        paper_name=$(echo "$(basename $paper_dir")
        if [[ -d $paper_dir ]]; then 
        for gtf_file in $paper_dir/*.gtf; do 
            output=$(echo "$(basename $gtf_file)"| sed s/.gtf/.bed/)
            cat $gtf_file| 
            awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
            sortBed | > $work_dir/$pipeline_name/final_output/$paper_name/$output
        done
        fi
    done
    fi
done

for pipeline in $work_dir/*; do
    pipeline_name=$(echo "$(basename $pipeline)")
    if [[ -d $pipeline && $pipeline_name == hisat* || $pipeline_name == star* ]]; then
    for paper_dir in $pipeline_dir/final_output/*; do
        paper_name=$(echo "$(basename $paper_dir")
        if [[ -d $paper_dir ]]; then 
        for bed_file in $paper_dir/*.bed; do 
            output=$(echo "$(basename $dir)"| sed s/.bed/_intersect_/)
            intersectBed -a $work_dir/bedtools/hg38_exons.bed -b $bed_file > $work_dir/$pipeline/final_output/$paper_name/$output"exons.bed"
            intersectBed -a $work_dir/bedtools/hg38_introns.bed -b $bed_file > $work_dir/$pipeline/final_output/$paper_name/$output"introns.bed"
            intersectBed -a $work_dir/bedtools/hg38_intergenic.bed -b $bed_file > $work_dir/$pipeline/final_output/$paper_name/$output"intergenic.bed"
        done
        fi
    done
    fi
done


