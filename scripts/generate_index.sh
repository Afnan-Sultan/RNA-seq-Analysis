#!/bin/bash

index_dir_path="$1"

#hisat genome indexing without gtf annotation
hisat2-build -p 8 $index_dir_path/GRCh38.primary_assembly.genome.fa $index_dir_path/hisat_index/hg38

#star genome indexing without gtf annotation
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $index_dir_path/star_index/ --genomeFastaFiles $index_dir_path/GRCh38.primary_assembly.genome.fa 
