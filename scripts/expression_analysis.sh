#!/bin/bash

prog_dir="$1"
index_dir_path="$2"
paper_dir="$3"

echo "################prepare Transcriptome.fasta########################"
.$prog_dir/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl $index_dir_path/gencode.v27.primary_assembly.annotation.gtf $index_dir_path/GRCh38.primary_assembly.genome.fa > $index_dir_path/transcripts.fasta

echo "####################quantifying reads########################"

#build transcriptome.fasta index
.$prog_dir/salmon-latest_linux_x86_64/bin/salmon index -t $index_dir_path/transcripts.fasta -i $index_dir_path/salmon_transcripts_index

#quantfication
##loop over libraries 
for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
       ## loop over tissues
       for tissue_dir in $lib_dir/*; do
           echo $tissue_dir
           tissue_name=$(echo "$(basename $tissue_dir)")
           if [ -d $tissue_dir ]; then
	      mkdir -p expression_analysis/$lib_name/$tissue_name
	      for read in $tissue_dir/trimmed_reads/*_1.fastq.gz; do
		read_2=$(echo $read | sed s/_1.fastq.gz/_2.fastq.gz/)
		read_name=$(echo "$(basename $read)" | sed s/_1.fastq.gz//)
		.$prog_dir/salmon-latest_linux_x86_64/bin/salmon quant -i $index_dir_path/salmon_transcripts_index -l A -1 $read -2 $read_2 -p 8 --validateMappings -o expression_analysis/$lib_name/$tissue_name/$read_name"_quant"
	      done
	   fi
	done
    fi
done


