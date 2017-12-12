#!/bin/bash

#download SRA toolkit and unzip it  
wget ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar xvzf sratoolkit.2.8.2-1-ubuntu64.tar.gz

#copying the code file -that will download the reads and convert them into fastq- to the PATH
sudo cp /home/$username/sratoolkit.2.8.2-1-ubuntu64/bin/fastq-dump /usr/bin/

#download the fastq data using the accession numbers' list
cat $PATH/file.txt | while read acc_num ; do 
    fastq-dump --outdir $PATH_to_storing_folder -- gzip -split-files $acc_num     
done
