#!/bin/bash

work_dir="$(pwd)"
echo $work_dir


#create the directories for storing human genome relative data, and a directory for stroing the requiered programs
mkdir $work_dir/hg38_data
mkdir $work_dir/hg38_data/hisat_index
mkdir $work_dir/hg38_data/star_index
mkdir $work_dir/programs
bash $work_dir/scripts/required_downloads.sh   #download/install the needed data and programs
bash $work_dir/scripts/set_path.sh             #setting the needed binary/scripts to PATH 


#download the RNA-seq data 
module load SRAToolkit/2.3.4.2 		       #if you already have it	

## define a list of paper directories
for paper_dir in $work_dir/data/*; do if [ -d $paper_dir ];then
  echo $paper_dir;
fi;done > paper_dirs.txt      

## download the data
while read paper_dir; do          
    ##creating the structure for the downloaded data
    mkdir $paper_dir/poly_A
    mkdir $paper_dir/ribo_depleted
    ##download the data according to the accession list
    paper_name=$(echo "$(basename $paper_dir)")
    for acc_list in $work_dir/data/$paper_name/acc_lists/*.txt; do 
        if [[ $(echo "$(basename $acc_list)") == poly* || $(echo "$(basename $acc_list)") == ribo* ]]; then
           tissue_name=$(echo "$(basename $acc_list)" | sed s/.txt//)
           if [[ $(echo "$(basename $acc_list)") == poly* ]]; then
             tissue_dir=$paper_dir/poly_A/$tissue_name;
           else
             tissue_dir=$paper_dir/ribo_depleted/$tissue_name;
           fi   
           mkdir $tissue_dir
	   mkdir $tissue_dir/fastq
           cat $acc_list| 
	   while read acc_num ; do 
             ##download and convert data into fastq.gz format
             echo $acc_num $tissue_dir;
             fastq-dump -X 10 --outdir $tissue_dir/fastq --gzip --split-files $acc_num   
           done
        fi
    done  
done < paper_dirs.txt


##merge reads coming from one sample
while read paper_dir;do
  bash $work_dir/scripts/concatenate.sh "$paper_dir"  
done < paper_dirs.txt


##trim merged reads
#prog_path=$work_dir/programs/Trimmomatic-0.36
prog_path="HPC" ## in case we use MSU HPC
while read paper_dir;do
  bash $work_dir/scripts/trim.sh "$paper_dir" "$prog_path" 
done < paper_dirs.txt


#create hisat-stringtie folder for storing all relevant work done by these programs 
mkdir $work_dir/hisat-stringtie
cd $work_dir/data && find -type d -not -name "acc_lists" -exec mkdir -p $work_dir/hisat-stringtie/{} \; #copy the same folder structure from data folder into hisat-stringtie folder
cd $work_dir 
bash $work_dir/scripts/hisat-stringtie.sh 


#create star-scallop folser for storing all relevant work done by these programs 
mkdir $work_dir/star-scallop
cd $work_dir/data && find -type d -not -name "acc_lists" -exec mkdir -p $work_dir/star-scallop/{} \;    #copy the same folder structure from data folder into hisat-stringtie folder
cd $work_dir
bash $work_dir/scripts/star-scallop.sh 


#create bedtools folder to stor the genomic regions in bed format
mkdir $work_dir/bedtools
bash $work_dir/scripts/bedtools.sh


#apply the requiered analysis on the resulted merged gtf files 
bash $work_dir/scripts/analysis.sh



 

