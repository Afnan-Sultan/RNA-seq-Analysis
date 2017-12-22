!/bin/bash
#implementing HISAT2 and Stringtie 


#hisat genome indexing without gtf annotation
hisat2-build -p 8 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa $work_dir/hg38_data/hisat_index/hg38

# loop over the paired reads from each sample to map them to the reference genome:
for paper_dir in $work_dir/data/*; do
    for lib_dir in $paper_dir/* ; do #if lib_dir -d #check if folder
        lib_name=$(echo "$(basename $lib_dir)")
        if [ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]; then
        for gb_dir in $lib_dir/*; do
            if [ -d $gb_dir ]; then
            for read in $gb_dir/*_1.fastq.gz ; do #excute the loop for paired read
                input1=$read
                input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
                output_dir_path= $(echo $gb_dir | sed s/data/hisat-stringtie/)
                hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 $input1 -2 $input2 -S $output_dir_path
            done
            fi
        done  
        fi
    done
    fi
done

# Sort and convert the SAM files to BAM:
for paper_dir in $work_dir/hisat-stringtie/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for gb_dir in $lib_dir/*; do
            if [ -d $gb_dir ]; then
    	    for sam in $gb_dir/*.sam; do    
                output=$(echo "$(basename $sam)"| sed s/.sam/.bam/)
                samtools sort -o $gb_dir/$output $sam
            done
            fi
        done
        fi
    done
    fi      
done

# Assemble transcripts for each sample:
for paper_dir in $work_dir/hisat-stringtie/*; do
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for gb_dir in $lib_dir/*; do
            if [ -d $gb_dir ]; then
    	    for bam in $gb_dir/*.bam; do    
                output=$(echo "$(basename $bam)"| sed s/.bam/.gtf/)
                label=$(echo "$(basename $bam)"| sed s/.bam//)
                stringtie -o $gb_dir/$output -l $label $bam
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


# Merge transcripts from all samples:
for paper_dir in $work_dir/hisat-stringtie/*; do
    paper_name=$(echo "$(basename $paper_dir"")")
    if [ -d $paper_dir ]; then
    for lib_dir in $paper_dir/*; do
        if [ -d $lib_dir ]; then
        for gb_dir in $lib_dir/*; do
            output=$(echo "$(basename $gb_dir"_stringtie_merged.gtf")") 
            if [ -d $gb_dir ]; then
            stringtie --merge $gb_dir/*.gtf -o $work_dir/hisat-stringtie/final_output/$paper_name/$output
            done
            fi
        done
        fi
    done
    fi      
done
