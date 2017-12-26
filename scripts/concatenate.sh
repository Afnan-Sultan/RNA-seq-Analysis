#!/bin/bash

paper_dir="$1"

for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")                                              #loop over libraries 
    if [[ -d $lib_dir && $lib_name == poly* || $lib_name == ribo* ]]; then
       for tissue_dir in $lib_dir/*; do
           echo $tissue_dir                                                   #loop over samples
           tissue_name=$(echo "$(basename $tissue_dir)")
           if [ -d $tissue_dir ]; then
	      mkdir $tissue_dir/merged_reads
	      for read in $tissue_dir/fastq/*_1.fastq.gz; do
	          temp=$(echo "$(basename $read)")
		  read_name=${temp:0:-11}
                  cat $paper_dir/acc_lists/SraRunTable.txt |
                  while read line; do 	
		        sample_id=$(echo $line | awk 'BEGIN{FS=",";} {print $3}')
		        read_id=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
		        if [[ $read_id == $read_name ]]; then
                           zcat $tissue_dir/fastq/$read_id"_1.fastq.gz" >> $tissue_dir/merged_reads/$sample_id"_1.fastq" 
		           zcat $tissue_dir/fastq/$read_id"_2.fastq.gz" >> $tissue_dir/merged_reads/$sample_id"_2.fastq" 
		        fi
	          done
	       done
	       for read in $tissue_dir/merged_reads/*; do 
		   gzip $read
	       done
	    fi
        done
    fi
done

			 

