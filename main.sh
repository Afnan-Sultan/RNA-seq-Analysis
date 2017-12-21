#!/bin/bash

work_dir="$(pwd)"

mkdir $work_dir/hg38_data
mkdir $work_dir/hg38_data/hisat_index
mkdir $work_dir/hg38_data/star_index
mkdir $work_dir/programs_workDir
bash $work_dir/scripts/required_downloads.sh 
bash $work_dir/scripts/set_path.sh 

## load the SRA module 
module load SRAToolkit/2.3.4.2
for paper_dir in $work_dir/data/*; do 
    if [ -d $paper_dir ]; then
       mkdir $paper_dir/poly_A
       mkdir $paper_dir/ribo_depleted
    fi
    paper_name=$(echo "$(basename $paper_dir)")
    for acc_list in $work_dir/data/$paper_name/acc_lists/*.txt; do 
        if [[ acc_list == poly* || acc_list == ribo* ]]; then
           out_dir_name=$(echo "$(basename $acc_list)")
           if [[ acc_list == poly* ]]; then
              mkdir $paper_dir/poly_A/$out_dir_name
              cat $acc_list| 
	      while read acc_num ; do 
                    fastq-dump --outdir $paper_dir/poly_A/$out_dir_name --gzip --split-files $acc_num
              done
           else
              mkdir $paper_dir/ribo_depleted/$out_dir_name
              cat $acc_list| 
              while read acc_num ; do 
                    fastq-dump --outdir $paper_dir/ribo_depleted/$out_dir_name --gzip --split-files $acc_num
              done         
           fi
        fi
    done  
done


mkdir $work_dir/hisat-stringtie
cd $work_dir/data && find -type d -exec mkdir -p $work_dir/hisat-stringtie/{} \;
cd $work_dir 
bash $work_dir/scripts/hisat-stringtie.sh 


mkdir $work_dir/star-scallop
cd $work_dir/data && find -type d -exec mkdir -p $work_dir/star-scallop/{} \;
cd $work_dir
bash $work_dir/scripts/star-scallop.sh 



mkdir $work_dir/bedtools
bash $work_dir/scripts/bedtools.sh


 

