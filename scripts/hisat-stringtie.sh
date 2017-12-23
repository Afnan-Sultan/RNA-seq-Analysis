!/bin/bash
#implementing HISAT2 and Stringtie 


#hisat genome indexing without gtf annotation
hisat2-build -p 8 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa $work_dir/hg38_data/hisat_index/hg38


#creat final_output folder and create a folder for each paper_data
mkdir $work_dir/hisat-stringtie/final_output
for paper_dir in $work_dir/hisat-stringtie/*;do
    if [[ -d $paper_dir && $paper_dir != $work_dir/hisat-stringtie/final_output ]]; then
    paper_name=$(echo "$(basename $paper_dir)")
    mkdir $work_dir/hisat-stringtie/final_output/$paper_name 
    fi
done


# loop over the paired reads from each sample to map them to the reference genome:
for paper_dir in $work_dir/data/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/* ; do #if lib_dir -d #check if folder
        if [ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]; then
        lib_name=$(echo "$(basename $lib_dir)")
        for sample_dir in $lib_dir/*; do
            if [ -d $sample_dir ]; then
            for read in $sample_dir/trimmed_reads/$sample_name_1* ; do #excute the loop for paired read
                input1=$read
                input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
                hisat_output=$(echo "$(basename $read)" | sed s/_1.fastq.gz/.sam/)
                output_dir_path= $(echo $sample_dir | sed s/data/hisat-stringtie/)
                hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 $input1 -2 $input2 -S $output_dir_path/$hisat_output
                
                # Sort and convert the SAM file to BAM:
                samtools_output=$(echo $hisat_output| sed s/.sam/.bam/)
                samtools sort -o $output_dir_path/$samtools_output $output_dir_path/$hisat_output
                
                # Assemble transcript:
                stringtie_output=$(echo "$(basename $samtools_output)"| sed s/.bam/.gtf/)
                label=$(echo "$(basename $samtools_output)"| sed s/.bam//)
                stringtie -o $output_dir_path/$stringtie_output -l $label $sample_dir/$samtools_output
            done
            fi
            #merge all transcripts from this sample into one gtf file and store at final_output
            stringtieMerge_output=$(echo "$(basename $sample_dir"_stringtie_merged.gtf")")
            stringtie --merge $output_dir_path/*.gtf -o $work_dir/hisat-stringtie/final_output/$paper_name/$stringtieMerge_output
        done  
        fi
    done
    fi
done
