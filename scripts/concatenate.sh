#!/bin/bash

paper_dir="$1"

##loop over libraries 
for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
       ## loop over tissues
       for tissue_dir in $lib_dir/*; do
           echo $tissue_dir
           tissue_name=$(echo "$(basename $tissue_dir)")
           if [ -d $tissue_dir ]; then
	      mkdir -p $tissue_dir/merged_reads
	      for read in $tissue_dir/RS_reads/*_1.fastq; do
	          temp=$(echo "$(basename $read)")
		  read_name=${temp%_RS_1.fastq}
                  cat $paper_dir/acc_lists/SraRunTable.txt |
                  while read line; do 	
		        sample_id=$(echo $line | awk 'BEGIN{FS=",";} {print $3}')
		        read_id=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
		        if [[ $read_id == $read_name ]]; then
                           echo "Add $read_id to $sample_id"
                           cat $tissue_dir/RS_reads/$read_id"_RS_1.fastq" >> $tissue_dir/merged_reads/$sample_id"_1.fastq" 
		           cat $tissue_dir/RS_reads/$read_id"_RS_2.fastq" >> $tissue_dir/merged_reads/$sample_id"_2.fastq" 
		        fi
	          done
	       done
	       for read in $tissue_dir/merged_reads/*; do 
                   echo "gzipping $read"
		   gzip $read
	       done
	    fi
        done
    fi
done
