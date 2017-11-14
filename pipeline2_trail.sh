#!/bin/bash
#implementing STAR and * 

#downloading STAR and unziping it
wget https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz 
tar xvzf chrX_data.tar.gz

#downloading scripture
wget ftp://ftp.broadinstitute.org/pub/papers/lincRNA/scripture-beta2.jar #download scripture

#copy chromosom X GTF file, chromosom X fasta file, and couple of read files -for simplicity- into STAR workspace
cp $HOME/chrX_data/genes/chrX.gtf  $HOME/STAR-2.5.3a 
cp $HOME/chrX_data/genome/chrX.fa  $HOME/STAR-2.5.3a
cp /home/afnan/RNA_seq/chrX_data/samples/ERR188044_chrX_1.fastq.gz  /home/afnan/STAR-2.5.3a/ 
cp /home/afnan/RNA_seq/chrX_data/samples/ERR188044_chrX_2.fastq.gz  /home/afnan/STAR-2.5.3a/

#adding STAR binary file to PATH environment
cp $HOME/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin 

#creating important folders
cd $HOME/STAR-2.5.3a
mkdir basic #to store the output of the process inside
mkdir genome #create a folder to store generated indixes files

#generating genome indexing
cd basic/ 
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $HOME/STAR-2.5.3a/genome/ --genomeFastaFiles $HOME/STAR-2.5.3a/chrX.fa --sjdbGTFfile $HOME/STAR-2.5.3a/chrX.gtf --sjdbOverhang 100

#Mapping the reads 
STAR --runThreadN 4 --genomeDir $HOME//STAR-2.5.3a/genome --sjdbGTFfile $HOME/STAR-2.5.3a/chrX.gtf --readFilesIn $HOME/STAR-2.5.3a/ERR188044_chrX_1.fastq.gz $HOME/STAR-2.5.3a/ERR188044_chrX_2.fastq.gz --readFilesCommand zcat


