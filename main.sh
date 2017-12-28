#!/bin/bash

work_dir="$(pwd)"

#create the directories for storing human genome relative data, and a directory for stroing the requiered programs
mkdir $work_dir/programs
bash $work_dir/scripts/download_programs.sh "$work_dir"   #download/install the needed programs
bash $work_dir/scripts/set_path.sh "$work_dir"            #setting the needed binary/scripts to PATH 

#download human genome resources and generate indexes for HISAT and STAR
mkdir $work_dir/hg38_data
index_dir_path=$work_dir/hg38_data/
bash $work_dir/scripts/genomeResources.sh "$index_dir_path" "HPC" 

## define a list of paper directories inside data file
for paper_dir in $work_dir/data/*; do if [ -d $paper_dir ];then
  echo $paper_dir;
fi;done > paper_dirs.txt      

#download the RNA-seq data 
module load SRAToolkit/2.3.4.2                 #if you already have it  
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
                tissue_dir=poly_A/$tissue_name;
             else
                tissue_dir=ribo_depleted/$tissue_name;
             fi   
             mkdir -p $paper_dir/$tissue_dir/fastq
             echo $tissue_dir >> $paper_dir/tissues.txt;
             cat $acc_list| 
	     while read acc_num ; do 
                ##download and convert data into fastq.gz format
                echo $acc_num $paper_dir/$tissue_dir;
                fastq-dump --outdir $paper_dir/$tissue_dir/fastq --gzip --split-files $acc_num   
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

##create hisat-stringtie folder for storing all relevant work done by these programs 
#mkdir $work_dir/hisat-stringtie $work_dir/star-scallop

##copy the same folder structure from data folder into hisat-stringtie folder
#for pipeline in $work_dir/*; do
#    pipeline_name=$(echo "$(basename $pipeline)")
#    if [[ -d $pipeline && ($pipeline_name == hisat* || $pipeline_name == star*) ]]; then
#       cd $work_dir/data && find -type d -not -name "acc_lists" -not -name "fastq" -not -name "merged_reads" -not -name "trimmed_reads" -exec mkdir -p $pipeline/{} \; 
#       cd $work_dir
#       echo $pipeline
#    fi
#done > pipeline.txt


### define a list of tissues directories inside each pipeline to pass for the assemblers
#while read pipeline; do
#      pipeline_name=$(echo "$(basename $pipeline)")
#      if [[ $pipeline_name == hisat* ]]; then
#         list=hisat_tissue_dirs
#      else
#         list=star_tissue_dirs
#      fi          
#      for paper_dir in $pipeline/*; do
#	  if [ -d $paper_dir ]; then
#	     for lib_dir in $paper_dir/*; do
#		 if [ -d $lib_dir ]; then
#		    for tissue_dir in $lib_dir/*; do
#	   		if [ -d $tissue_dir ];then
#	     		   echo $tissue_dir
#	                fi  	
#                    done 
#		  fi
#	     done
# 	   fi
#       done > $list.txt
#done < pipeline.txt 


#map the trimmed merged reads using hisat
mkdir $work_dir/hisat-stringtie
hisat_dir=$work_dir/hisat-stringtie
while read paper_dir;do
      bash $work_dir/scripts/hisat.sh "$paper_dir" "$hisat_dir" "$index_dir_path" "HPC"
done < paper_dirs.txt 

#sort, convert to bam 
while read paper_dir;do
      bash $work_dir/scripts/getBAM.sh "$paper_dir" "$hisat_dir" "HPC"
done < paper_dirs.txt

#assemple the sam files using stringtie
while read paper_dir;do
      bash $work_dir/scripts/stringtie.sh "$paper_dir" "$hisat_dir" "HPC"
done < paper_dirs.txt

#map the trimmed merged reads using STAR
mkdir $work_dir/star-scallop
star_dir=$work_dir/star-scallop
while read paper_dir;do
      bash $work_dir/scripts/star.sh "$paper_dir" "$star_dir" "$index_dir_path"  "HPC"
done < paper_dirs.txt

#sort, convert to bam 
while read paper_dir;do
      bash $work_dir/scripts/getBAM.sh "$paper_dir" "$star_dir" "HPC"
done < paper_dirs.txt

#assemple the sam files using scallop
prog_path=$work_dir/programs/coin-Clp
while read tissue_dir;do
      bash $work_dir/scripts/scallop.sh "$paper_dir" "$star_dir" "HPC" ## use "$prog_path" instead of "HPC" for local analysis
done < star_tissue_dirs.txt  


#creat final output folder to store the most important outputs from the pipeline and the analysiss
while read pipeline; do
      mkdir $pipeline/final_output
      for paper_dir in $pipeline/*; do
          if [[ -d $paper_dir && $paper_dir != $pipeline/final_output ]]; then
	     paper_name=$(echo "$(basename $paper_dir)") 
	     mkdir $pipeline/final_output/$paper_name
          fi
      done
done < pipeline.txt 


#merge the assembled gtf files
while read pipeline; do
      for paper_dir in $pipeline/final_output/*; do  
	  #echo $paper_dir     
	  if [[ $pipeline_name == hisat* ]]; then 
	     tissue_list=hisat_tissue_dirs.txt
	     script=scripts/stringtie_merge.sh
	  elif [[ $pipeline_name == star* ]]; then 
	     tissue_list=star_tissue_dirs.txt
	     script=scripts/cuffmerge.sh
	  fi
	  cat $tissue_list |
 	  while read tissue_dir;do
      		bash $script "$tissue_dir" "$paper_dir"
		#echo $tissue_dir
                #echo $paper_dir 
	  done
      done 
done < pipeline.txt

#create bedtools folder to stor the genomic regions in bed format
mkdir $work_dir/bedtools
bedtools_dir=$work_dir/bedtools
bash $work_dir/scripts/bedtools.sh "$index_dir_path" "$bedtools_dir"


#apply the requiered analysis on the resulted merged gtf files 
while read pipeline; do 
      for paper_dir in $pipeline/final_output; do
           bash $work_dir/scripts/analysis.sh "$paper_dir" "$index_dir_path" "$bedtools_dir"
      done
done < pipeline.txt



 

