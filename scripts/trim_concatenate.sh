#!/bin/bash

#apply trimming and then mrging for the reads
for paper_dir in $work_dir/data/*; do                                               #loop over the papers
    if [ -d $lib_dir ]; then                                                        
    for lib_dir in $paper_dir/* ; do                                                #loop over libraries 
        if [[ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]]; then
        for sample_dir in $lib_dir/*; do                                            #loop over samples
            sample_name=$(echo "$(basename $sample_dir)")
            if [ -d $sample_dir ]; then
            mkdir $sample_dir/trimmed_reads                                         #create folder to stor trimmed reads
            cd $sample_dir/trimmed_reads/
            for read in $sample_dir/*_1.fastq.gz ; do                               #loop over the reads
                trim_path=$work_dir/programs/Trimmomatic-0.36 
                input1=$read
                input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
                outpu_pe1=$(echo "$(basename $input1)")
                output_pe2=$(echo "$(basename $input2)")
                output_se1=$(echo "$(basename $read)" | sed s/_1.fastq.gz/_fSE.fastq/)
                output_se2=$(echo "$(basename $read)" | sed s/_2.fastq.gz/_rSE.fastq/)
                
                #use trimmomatic to perform trimming on the reads
                java -jar $trim/trimmomatic-0.36.jar PE -phred33 $input1 $input2 $output_pe1 $output_se1 $output_pe2 $output_se2 ILLUMINACLIP:$trim/adapters/TruSeq2-PE.fa:2:30:10 SLIDINGWINDOW:4:2 MINLEN:20 
            done
            cd $work_dir/
            for trimmed_read in $sample_dir/trimmed_reads/*.fastq.gz;              #loop over the trimmed reads  
                if [[ $(echo "$(basename $trimmed_read )") == *_1.fastq.gz ]]; then
                   zcat $trimmed_read > $sample_name"_1.fatq.gz"                   #store the forward reads in one file
                elif [[ $(echo "$(basename $read )") == *_2.fastq.gz ]]; then 
                   zcat $trimmed_read > $sample_name"_2.fatq.gz"                   #store the reverse reads in one file
                fi
            done
            fi
        done  
        fi
    done
    fi
done


