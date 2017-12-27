#!/bin/bash
index_dir_path="$1"
plateform="$2"

### Download the human genome data
## Nucleotide sequence of the GRCh38 primary genome assembly (chromosomes and scaffolds)
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/GRCh38.primary_assembly.genome.fa.gz -P $index_dir_path
gunzip -c $index_dir_path/GRCh38.primary_assembly.genome.fa.gz > $index_dir_path/GRCh38.primary_assembly.genome.fa

## comprehensive gene annotation on the reference chromosomes only
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz -P $index_dir_path
gunzip -c $index_dir_path/gencode.v27.annotation.gtf.gz > $index_dir_path/gencode.v27.annotation.gtf

## calculte chromosome sizes of the genome
if [ $plateform == "HPC" ];then
  module load SAMTools/1.2;fi
samtools faidx $index_dir_path/GRCh38.primary_assembly.genome.fa
cut -f1,2 $index_dir_path/GRCh38.primary_assembly.genome.fa.fai > $index_dir_path/hg38.genome

#hisat genome indexing without gtf annotation
mkdir $index_dir_path/hisat_index
if [ $plateform == "HPC" ];then
  module load hisat2/2.1.0;fi
hisat2-build -p 8 $index_dir_path/GRCh38.primary_assembly.genome.fa $index_dir_path/hisat_index/hg38

#star genome indexing without gtf annotation
mkdir $index_dir_path/star_index
genomeDir="$index_dir_path/star_index/"
genomeFastaFiles="$index_dir_path/GRCh38.primary_assembly.genome.fa"
if [ $plateform == "HPC" ];then
 script_path=$(dirname "${BASH_SOURCE[0]}")
 qsub -v genomeDir="$genomeDir",genomeFastaFiles="$genomeFastaFiles" $script_path/run_starIndex.sh
else
 STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles $genomeFastaFiles
fi

### done ###
