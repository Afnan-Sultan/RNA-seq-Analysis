#!/bin/bash

#download SRA toolkit and unzip it  
wget ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar xvzf sratoolkit.2.8.2-1-ubuntu64.tar.gz

#copying the code file -that will download the reads and convert them into fastq- to the PATH
sudo cp /home/$username/sratoolkit.2.8.2-1-ubuntu64/bin/fastq-dump /usr/bin/

#------------------------------------------------#

#procedures 

#entering the working directory and create some required folders
cd /home/$username/download_data_RNA-seq_TM-AS/
mkdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/

#create separat folders for each library
cd RNA-seq_data/
mkdir riobo-depleted poly-A 

#create separat folders for each sample
cd poly-A/
mkdir reads_A reads_B reads_C reads_D
cd ../

cd ribo-depleted/
mkdir reads_A reads_B reads_C reads_D
cd ../

#download the fastq files for each sample in the poly-A library
cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-poly-A.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/poly-A/reads_A/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-poly-B.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/poly-A/reads_B/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-poly-C.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/poly-A/reads_C/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-poly-D.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/poly-A/reads_D/  -- gzip -split-files $acc_num     
done

#download the fastq files for each sample in the ribo-depleted
cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-ribo-A.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/riobo-depleted/reads_A/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-ribo-B.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/riobo-depleted/reads_B/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-ribo-C.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/riobo-depleted/reads_C/  -- gzip -split-files $acc_num     
done

cat /home/$username/download_data_RNA-seq_TM-AS/acc_lists/illumin-w-ribo-D.txt | while read acc_num ; do 
    fastq-dump --outdir /home/$username/download_data_RNA-seq_TM-AS/RNA-seq_data/riobo-depleted/reads_D/  -- gzip -split-files $acc_num     
done
