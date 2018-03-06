#!/bin/bash

paper_dir="$1"

for txt in $paper_dir/metadata* ; do
    cat $txt |
    while read line; do
          lib_ribo_dir=$(echo $line | awk 'BEGIN{FS=",";} {print $1}')
          lib_poly_dir=$(echo $line | awk 'BEGIN{FS=",";} {print $9}')
          lib_ribo_name=$(echo $line | awk 'BEGIN{FS=",";} {print $3}')
          lib_poly_name=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
          lib_ribo_len=$(echo $line | awk 'BEGIN{FS=",";} {print $4}')
          lib_poly_len=$(echo $line | awk 'BEGIN{FS=",";} {print $12}')
          if [ $lib_ribo_len > $lib_poly_len ]; then
             lib_len=$lib_poly_len
          else
             lib_len=$lib_ribo_len
          fi
          mkdir $lib_ribo_dir/RS_reads
          mkdir $lib_poly_dir/RS_reads
          seqtk sample -s$lib_len $lib_ribo_dir/fastq/$lib_ribo_name"_1.fastq.gz" > $lib_ribo_dir/RS_reads/$lib_ribo_name"_RS_1.fastq.gz"
          seqtk sample -s$lib_len $lib_ribo_dir/fastq/$lib_ribo_name"_2.fastq.gz" > $lib_ribo_dir/RS_reads/$lib_ribo_name"_RS_2.fastq.gz"
          seqtk sample -s$lib_len $lib_poly_dir/fastq/$lib_poly_name"_1.fastq.gz" > $lib_poly_dir/RS_reads/$lib_poly_name"_RS_1.fastq.gz"
          seqtk sample -s$lib_len $lib_poly_dir/fastq/$lib_poly_name"_2.fastq.gz" > $lib_poly_dir/RS_reads/$lib_poly_name"_RS_2.fastq.gz"
    done
done 

