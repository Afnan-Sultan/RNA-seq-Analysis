#!/bin/bash

paper_dir="$1"
prog_path="$2"

if [ "$prog_path" == "HPC" ];then
 module load Trimmomatic/0.33 
else 
 TRim=$work_dir/programs/Trimmomatic-0.36
fi
	
#apply trimming and then mrging for the reads
for lib_dir in $paper_dir/* ; do
  lib_name=$(echo "$(basename $lib_dir)")                                     #loop over libraries 
  if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
    for sample_dir in $lib_dir/*; do                                            #loop over samples
      sample_name=$(echo "$(basename $sample_dir)")
      if [ -d $sample_dir ]; then
        mkdir $sample_dir/trimmed_reads                                      #create folder to stor trimmed reads
        cd $sample_dir/trimmed_reads/
        for read in $sample_dir/*_1.fastq.gz ; do                               #loop over the reads
          input1=$read
          input2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
          output_pe1=$(echo "$(basename $input1)")
          output_pe2=$(echo "$(basename $input2)")
          output_se1=$(echo "$(basename $read)" | sed s/_1.fastq.gz/_fSE.fastq/)
          output_se2=$(echo "$(basename $read)" | sed s/_1.fastq.gz/_rSE.fastq/)
                
          ##use trimmomatic to perform trimming on the reads
          java -jar $TRIM/trimmomatic PE -phred33 $input1 $input2 $output_pe1 $output_se1 $output_pe2 $output_se2 ILLUMINACLIP:$TRIM/adapters/TruSeq2-PE.fa:2:30:10 SLIDINGWINDOW:4:2 MINLEN:20 
        done
            
        for trimmed_read in $sample_dir/trimmed_reads/*; do              #loop over the trimmed reads 
          read_name=$(echo "$(basename $trimmed_read)")
          if [[ $read_name == *_1.fastq.gz ]]; then
            cat $trimmed_read >> $sample_dir/trimmed_reads/$sample_name"_1.fastq.gz"   #store the forward reads in one file
          elif [[ $read_name == *_2.fastq.gz ]]; then 
            cat $trimmed_read >> $sample_dir/trimmed_reads/$sample_name"_2.fastq.gz"   #store the reverse reads in one file
          fi
        done
      fi
    done  
  fi
done
