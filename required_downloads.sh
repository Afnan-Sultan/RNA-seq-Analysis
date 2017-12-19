#!/bin/bash
#downloading and installing the required programms for hisat/stringtie and star/scallop pipelines 

work_dir="$(pwd)"


### Download the human genome data we are going to need ###
 
mkdir hg38_data
cd hg38_data/
ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/GRCh38.p10.genome.fa.gz #download the fasta file for indexes generating
gunzip GRCh38.p10.genome.fa.gz

Wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz #download transcriptome gtf file to use for comparison 
gunzip gencode.v27.annotation.gtf.gz

mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \ "select chrom, size from hg38.chromInfo"  > hg38.genome #dowmload genome sizes file
cd ../

### done ###


#creating a directory to store the programs at 
mkdir programs_WorkDir 
cd programs_WorkDir/


### required downloads for hisat-stringtie pipeline ###
   
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
cd ../

### done ### 



### required downloads for star-scallop pipeline ###

#Installing scallop dependancies
wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz #getting boost folder
tar xvzf boost_1_65_1.tar.gz

#getting & installing zlib required for htslib
wget https://zlib.net/zlib-1.2.11.tar.gz 
tar xvzf zlib-1.2.11.tar.gz 
cd zlib-1.2.11/
./configure
make
sudo make install
cd ../

#cloning & installing htslib
git clone https://github.com/samtools/htslib 
cd htslib/
autoheader
autoconf
./configure --disable-bz2 --disable-lzma --disable-gcs --disable-s3 --enable-libcurl=no
make 
sudo make install
cd ../

#install subversion requiered for ClP
sudo apt-get install subversion 
svn co https://projects.coin-or.org/svn/Clp/stable/1.16 coin-Clp #getting & installing clp
cd coin-Clp
./configure --disable-bzlib --disable-zlib
make
sudo make install 
cd ../

#Installing Scallop
git clone https://github.com/Kingsford-Group/scallop
cd scallop/ 
autoreconf --install       	
autoconf configure.ac
./configure --with-clp=/home/$username/coin-Clp --with-htslib=/home/$username/htslib --with-boost=/home/$username/boost_1_65_1
make
cd ../

#downloading STAR and unziping it
wget https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz 
tar xvzf STAR-2.5.3a.tar.gz

#downloading cufflinks to merge scallop GTFs 
wget cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz
tar xvzf cufflinks-2.2.1.Linux_x86_64.tar.gz
 ### done ### 
