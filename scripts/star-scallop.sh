#!/bin/bash
#impeleminting STAR and scallop

#genome indexing without gtf annotation
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $work_dir/hg38_data/star_index/ --genomeFastaFiles $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa 


creat final_output folder and create a folder for each paper_data
mkdir $work_dir/star-scallop/final_output
for paper_dir in $work_dir/star-scallop/* ;do
    if [[ -d $paper_dir && $paper_dir != $work_dir/star-scallop/final_output ]]; then
    paper_name=$(echo "$(basename $paper_dir)")
    mkdir $work_dir/star-scallop/final_output/$paper_name 
    fi
done


# loop over the paired reads from each sample to map them to the reference genome:
for paper_dir in $work_dir/data/*; do
    if [ -d $paper_dir ]; then
       paper_name=$(echo "$(basename $paper_dir)")
    for lib_dir in $paper_dir/* ; do
        lib_name=$(echo "$(basename $lib_dir)")
        if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then
               sample_name=$(echo "$(basename $sample_dir)")
               output_dir_path=$work_dir/star-scallop/$paper_name/$lib_name/$sample_name
            for read in $sample_dir/trimmed_reads/$sample_name"_1"*; do #excute the loop for paired read
                input1=$read
                input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
                star_output_sam_prefix=$(echo "$(basename $read)" | sed s/1.fastq.gz//) 
                STAR --runThreadN 1 --genomeDir /home/afnan/RNA-seq/star-scallop/genome --readFilesIn $input1 $input2 --readFilesCommand zcat --outSAMattributes XS --outFileNamePrefix $output_dir_path/$star_output_sam_prefix   
                
                # Sort and convert the SAM file to BAM:
                temp=$star_output_sam_prefix"Aligned.out.sam"
                samtools_output=$(echo $temp | sed s/.sam/.bam/)
                samtools sort -o $output_dir_path/$samtools_output $output_dir_path/$star_output_sam_prefix"Aligned.out.sam"
                
                # Assemble transcript:
                scallop_output=$(echo $samtools_output | sed s/.bam/.gtf/)
                scallop -i $output_dir_path/$samtools_output -o $sample_dir/$scallop_output
            done
            fi
            
            #stor gtf paths for each sample in a txt file to pass it to cufflinks
            for gtf_file in $output_dir_path/*.gtf; do
                echo $gtf_file 
            done > $output_dir_path/gtf_list.txt
            
            # Merge transcripts from all samples and copy them to final_output
            cuffMerge_output=$(echo "$(basename $sample_dir"_scallop_merged.gtf")")
            cuffmerge $output_dir_path/gtf_list.txt -o $output_dir_path
            cp $output_dir_path/merged_asm/merged.gtf $work_dir/star-scallop/final_output/$paper_name/$cuffMerge_output
        done  
        fi
    done
    fi
done
