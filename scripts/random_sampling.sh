#!/bin/bash

paper_dir="$1"

module load seqtk/1.0

cat $paper_dir/metadata.txt |
while read line; do
    echo new line
    lib_ribo=$(echo $line | awk 'BEGIN{FS=",";} {print $1}')
    tissue_ribo=$(echo $line | awk 'BEGIN{FS=",";} {print $2}')
    read_ribo=$(echo $line | awk 'BEGIN{FS=",";} {print $4}')
    read_ribo_len=$(echo $line | awk 'BEGIN{FS=",";} {print $5}')
    lib_poly=$(echo $line | awk 'BEGIN{FS=",";} {print $6}')
    tissue_poly=$(echo $line | awk 'BEGIN{FS=",";} {print $7}')
    read_poly=$(echo $line | awk 'BEGIN{FS=",";} {print $9}')
    read_poly_len=$(echo $line | awk 'BEGIN{FS=",";} {print $10}')
    if [ $read_ribo_len -gt $read_poly_len ]; then
	lib_len=$read_poly_len
    else
        lib_len=$read_ribo_len
    fi
    mkdir -p $paper_dir/$lib_ribo/$tissue_ribo/RS_reads
    mkdir -p $paper_dir/$lib_poly/$tissue_poly/RS_reads
    echo $lib_len
    zcat $paper_dir/$lib_ribo/$tissue_ribo/fastq/$read_ribo"_1.fastq.gz"|\
	seqtk sample - $lib_len > $paper_dir/$lib_ribo/$tissue_ribo/RS_reads/$read_ribo"_RS_1.fastq"
    zcat $paper_dir/$lib_ribo/$tissue_ribo/fastq/$read_ribo"_2.fastq.gz"|\
	seqtk sample - $lib_len > $paper_dir/$lib_ribo/$tissue_ribo/RS_reads/$read_ribo"_RS_2.fastq"
    zcat $paper_dir/$lib_poly/$tissue_poly/fastq/$read_poly"_1.fastq.gz"|\
	seqtk sample - $lib_len > $paper_dir/$lib_poly/$tissue_poly/RS_reads/$read_poly"_RS_1.fastq"
    zcat $paper_dir/$lib_poly/$tissue_poly/fastq/$read_poly"_2.fastq.gz"|\
	seqtk sample - $lib_len > $paper_dir/$lib_poly/$tissue_poly/RS_reads/$read_poly"_RS_2.fastq"
done
