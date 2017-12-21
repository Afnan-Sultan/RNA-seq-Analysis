#!/bin/bash
#implementing HISAT2 and Stringtie 

#work_dir="$(pwd)"

#copying samtools, Hisat, Stringtie & gffcompare to $PATH
#sudo cp $work_dir/programs_WorkDir/samtools-01.6/samtools /usr/bin
#sudo cp $work_dir/programs_WorkDir/hisat2/hisat2* hisat2/*.py /usr/bin
#sudo cp $work_dir/programs_WorkDir/stringtie/stringtie /usr/bin
#sudo cp $work_dir/programs_WorkDir/gffcompare/gffcompare /usr/bin

# loop over the paired reads from each sample to map them to the reference genome:
for paper_dir in $work_dir/data/*; do
    for lib_dir in $paper_dir/* ; do #if lib_dir -d #check if folder
        lib_name=$(echo "$(basename $lib_dir)")
        if [ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]; then
        for gb_dir in $lib_dir/*; do
            if [ -d $gb_dir ]; then
            for read in $gb_dir/*_1.fastq.gz ; do #excute the loop for paired read
                input1=$read
                input2=$(echo "$(basename $read)"| sed s/_1.fastq.gz/_2.fastq.gz/)
                output= $(echo "$(basename $gb_dir)"| sed s/data/hisat-stringtie/)
                hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 $input1 -2 $input2 -S $output
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
                samtools sort -o $gb_dir/$output ${arr[$i]}
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
    	    for sam in $gb_dir/*.bam; do    
                output=$(echo "$(basename $s)"| sed s/.bam/.gtf/)
                label=$(echo "$(basename $s)"| sed s/.bam//)
                stringtie -o $bam/$output -l $label $bam
            done
            fi
        done
        fi
    done
    fi      
done


for paper_dir in $work_dir/hisat-stringtie/* ;do
    if [[ -d $paper_dir && $paper_dir != $work_dir/hisat-stringtie/final_output ]]
    dir_name=$(echo "$(basename $paper_dir")
    mkdir $work_dir/hisat-stringtie/final_output/$dir_name 
    fi
done



mkdir $work_dir/hisat-stringtie/final_output
for paper_dir in $work_dir/hisat-stringtie/* ;do
    if [[ -d $paper_dir && $paper_dir != $work_dir/hisat-stringtie/final_output ]]
    paper_name=$(echo "$(basename $paper_dir")
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


