#!/bin/bash -ve

paper_dir="$1"
trinity_dir="$2"
plateform="$3"
paper_name=$(echo "$(basename $paper_dir)")
script_path=$(dirname "${BASH_SOURCE[0]}")

while read tissue;do
      tissue_dir=$trinity_dir/$paper_name/$tissue
      echo $paper_dir/$tissue/trimmed_reads/ 
      for sample in $paper_dir/$tissue/trimmed_reads/*_1.fastq.gz; do #excute the loop for paired read
          echo $sample
	  input1=$sample
	  input2=$(echo $sample | sed s/_1.fastq.gz/_2.fastq.gz/)
	  sampleDirName=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/_trinity_output/)
	  
          new_input1=$(echo $input1 | sed s/_1.fastq.gz/_1v2.fastq/)
          zcat $input1 | awk '{if (NR % 4 == 1) {print $1"/1"} else {print $0} }' > $new_input1
          new_input2=$(echo $input2 | sed s/_2.fastq.gz/_2v2.fastq/)
          zcat $input2 | awk '{if (NR % 4 == 1) {print $1"/1"} else {print $0} }' > $new_input2  
          
          if [ "$plateform" == "HPC" ];then
              qsub -v output="$tissue_dir/$sampleDirName",input1="$new_input1",input2="$new_input2" $script_path/run_trinity.sh
          else
              $plateform/trinityrnaseq-Trinity-v2.5.1/Trinity --seqType fq \
                                                          --max_memory 2G \
                                                          --output $tissue_dir/$sampleDirName \
		 					  --left $new_input1 \
		 					  --right $new_input2 \
							  --SS_lib_type RF #\
							  #--no_bowtie
              outputName=$(echo "$(basename $sample)" | sed s/_1.fastq.gz/.fasta/)
              cp $tissue_dir/$sampleDirName/Trinity.fasta $tissue_dir/$outputName 
      fi;done 
done < $paper_dir/tissues.txt



