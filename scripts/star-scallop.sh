#!/bin/bash
#impeleminting STAR and scallop

#genome indexing without gtf annotation
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $work_dir/hg38_data/star_index/ --genomeFastaFiles $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa 


# loop over the paired reads from each sample to map them to the reference genome:
for paper_dir in $work_dir/data/*; do
    for lib_dir in $paper_dir/* ; do #if lib_dir -d #check if folder
        lib_name=$(echo "$(basename $lib_dir)")
        if [ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]; then
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then
            for read in $sample_dir/*_1.fastq.gz ; do #excute the loop for paired read
                input1=$read
                input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
                output_dir_path= $(echo $sample_dir | sed s/data/star-scallop/)
                outpu_sam_prefix= $(echo "$(basename $read"_")") 
                STAR --runThreadN 1 --genomeDir /home/afnan/RNA-seq/star-scallop/genome --readFilesIn $input1 $input2 --readFilesCommand zcat --outSAMattributes XS --outFileNamePrefix $output_dir_path/$output_sam_prefix   
            done
            fi
        done  
        fi
    done
    fi
done

# Sort and convert the SAM files to BAM:
for paper_dir in $work_dir/star-scallop/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then
    	    for sam in $sample_dir/*.sam; do    
                output=$(echo "$(basename $sam)"| sed s/.sam/.bam/)
                samtools sort -o $sample_dir/$output $sam
            done
            fi
        done
        fi
    done
    fi      
done

# Assemble transcripts for each sample:
export LD_LIBRARY_PATH=$work_dir/programs_WorkDir/coin-Clp/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries
for paper_dir in $work_dir/star-scallop/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then
    	    for bam in $sample_dir/*.bam; do    
                output=$(echo "$(basename $bam)"| sed s/.bam/.gtf/)
                scallop -i $bam -o $sample_dir/$output
            done
            fi
        done
        fi
    done
    fi      
done

#creat final_output folder and create a folder for each paper_data
mkdir $work_dir/hisat-stringtie/final_output
for paper_dir in $work_dir/hisat-stringtie/* ;do
    if [[ -d $paper_dir && $paper_dir != $work_dir/hisat-stringtie/final_output ]]
    paper_name=$(echo "$(basename $paper_dir)")
    mkdir $work_dir/hisat-stringtie/final_output/$paper_name 
    fi
done


#stor gtf paths for each sample in a txt file to pass it to cufflinks
for paper_dir in $work_dir/star-scallop/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then       
            for gtf_file in $sample_dir/*.gtf; do
                echo $c 
            done > $sample_dir/gtf_list.txt
            fi
        done
        fi
    done
    fi
done


# Merge transcripts from all samples:
for paper_dir in $work_dir/star-scallop/*; do
    paper_name=$(echo "$(basename $paper_dir"")")
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for sample_dir in $lib_dir/*; do
            output=$(echo "$(basename $sample_dir"_scallop_merged.gtf")") 
            if [ -d $sample_dir ]; then
            cuffmerge $sample_dir/gtf_list.txt -o $sample_dir
            cp $sample_dir/merged_asm/merged.gtf $work_dir/star-scallop/final_output/$paper_name/$output
            fi 
        done
        fi
    done
    fi      
done

