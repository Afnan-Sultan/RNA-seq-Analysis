#!/bin/bash

for paper_dir in $work_dir/data/*; do
    for lib_dir in $paper_dir/* ; do #if lib_dir -d #check if folder
        if [ -d $lib_dir && $lib_name == poly* || $lib_dir == ribo* ]; then
        for sample_dir in $lib_dir/*; do
            sample_name=$(echo "$(basename $sample_dir)")
            if [ -d $sample_dir ]; then
            for read in $sample_dir/*.fastq.gz ; do #excute the loop for paired read
                if [[ $(echo "$(basename $read )") == *_1.fast.gz ]]; then
                   zcat $read > $sample_name"_1.fatq.gz"
                elif [[ $(echo "$(basename $read )") == *_2.fast.gz ]]; then 
                   zcat $read > $sample_name"_2.fatq.gz"
                fi
            done
            fi
        done  
        fi
    done
    fi
done


