#!/bin/bash
#downloading and installing the required programms for hisat/stringtie and star/scallop pipelines 

work_dir="$(pwd)"

#Download the human genome data we are going to need 
mkdir hg38_data
cd $work_dir/hg38_data/
ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/GRCh38.primary_assembly.genome.fa.gz #download the fasta file for indexes generating
gunzip GRCh38.p10.genome.fa.gz

Wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz #download transcriptome gtf file to use for comparison 
gunzip gencode.v27.annotation.gtf.gz

mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \ "select chrom, size from hg38.chromInfo"  > hg38.genome #dowmload genome sizes file
cd ../

#creating a directory to store the programs at 
mkdir programs_WorkDir 
cd programs_WorkDir/

#download programms required for hisat/stringtie pipeline and copy binaries to PATH
   
git clone https://github.com/infphilo/hisat2 #installing Hisat2

wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 -O - | tar xj #downloadeing samtools-1.6
tar jxvf samtools-1.6.tar.bz2
cd samtools-1.6
make
cd ../

git clone https://github.com/gpertea/stringtie #installing StringTie-1.3.4
cd stringtie
make release
cd ../

sudo apt-get install bedtools #install bedtools

git clone https://github.com/gpertea/gclib #installing dependancy of gffcompare
git clone https://github.com/gpertea/gffcompare #installing gffcompare-0.10.1
cd gffcompare
make release
cd ../ ../




