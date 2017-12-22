#!/bin/bash

work_dir="$(pwd)"

#create the directories for storing human genome relative data, and a directory for stroing the requiered programs
mkdir $work_dir/hg38_data
mkdir $work_dir/hg38_data/hisat_index
mkdir $work_dir/hg38_data/star_index
mkdir $work_dir/programs_workDir
bash $work_dir/scripts/required_downloads.sh   #download/install the needed data and programs
bash $work_dir/scripts/set_path.sh             #setting the needed binary/scripts to PATH 

#download the RNA-seq data 
module load SRAToolkit/2.3.4.2
for paper_dir in $work_dir/data/*; do          #creating the structure for the downloaded data
    if [ -d $paper_dir ]; then
       mkdir $paper_dir/poly_A
       mkdir $paper_dir/ribo_depleted
    fi
    paper_name=$(echo "$(basename $paper_dir)")
    for acc_list in $work_dir/data/$paper_name/acc_lists/*.txt; do 
        if [[ $(echo "$(basename $acc_list)") == poly* || $(echo "$(basename $acc_list)") == ribo* ]]; then
           sample_name=$(echo "$(basename $acc_list)")
           if [[ $(echo "$(basename $acc_list)") == poly* ]]; then
              mkdir $paper_dir/poly_A/$sample_name
              cat $acc_list| 
	      while read acc_num ; do 
                    fastq-dump --outdir $paper_dir/poly_A/$out_dir_name --gzip --split-files $acc_num       #download and convert data into fastq.gz format
              done
           else
              mkdir $paper_dir/ribo_depleted/$sample_name
              cat $acc_list| 
              while read acc_num ; do 
                    fastq-dump --outdir $paper_dir/ribo_depleted/$out_dir_name --gzip --split-files $acc_num #download and convert data into fastq.gz format
              done         
           fi
        fi
    done  
done
bash $work_dir/scripts/concatenate_trim.sh      #merge and trim reads 


#create hisat-stringtie folser for storing all relevant work done by these programs 
mkdir $work_dir/hisat-stringtie
cd $work_dir/data && find -type d -exec mkdir -p $work_dir/hisat-stringtie/{} \; #copy the same folder structure from data folder into hisat-stringtie folder
cd $work_dir 
bash $work_dir/scripts/hisat-stringtie.sh 


#create star-scallop folser for storing all relevant work done by these programs 
mkdir $work_dir/star-scallop
cd $work_dir/data && find -type d -exec mkdir -p $work_dir/star-scallop/{} \;    #copy the same folder structure from data folder into hisat-stringtie folder
cd $work_dir
bash $work_dir/scripts/star-scallop.sh 

#create bedtools folder to stor the genomic regions in bed format
mkdir $work_dir/bedtools
bash $work_dir/scripts/bedtools.sh


#apply the requiered analysis on the resulted merged gtf files 
bash $work_dir/scripts/analysis.sh



 

