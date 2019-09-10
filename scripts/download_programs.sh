#!/bin/bash

work_dir="$1"

#downloading and installing the required programms for hisat/stringtie and star/scallop pipelines 

cd $work_dir/programs/

### required downloads for downloading/sampling and trimming reads ### 

wget ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar xvzf sratoolkit.2.8.2-1-ubuntu64.tar.gz

git clone https://github.com/lh3/seqtk.git;
cd seqtk; make
cd ../

wget www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
unzip Trimmomatic-0.36.zip
mv Trimmomatic-0.36.zip/trimmomatic-0.36.jar Trimmomatic-0.36.zip/trimmomatic

### done ### 

### required downloads for hisat-stringtie pipeline ###
   
git clone https://github.com/infphilo/hisat2 #installing Hisat2

wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 #downloadeing samtools-1.6
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

###done###

### required downloads for Trinity pipeline ###

#download Trinity
wget https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v2.5.1.tar.gz
tar xvzf Trinity-v2.5.1.tar.gz

#download blat and other binaries from ucsc to convert fasta files to gtf 
mkdir ucscLib
rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/blat/ ./ucscLib
rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/pslToBed ./ucscLib
rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/bedToGenePred ./ucscLib
rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/genePredToGtf ./ucscLib

### done ###


### reqiured downloads for expression analysis ###

#download TransDecoder to prepare the Transcriptome.fasta file to be passed for Salmon
wget https://github.com/TransDecoder/TransDecoder/archive/TransDecoder-v5.5.0.tar.gz
tar xvzf TransDecoder-v5.5.0.tar.gz

#download Salmon to quantify RNA-seq reads
wget https://github.com/COMBINE-lab/salmon/releases/download/v0.14.1/salmon-0.14.1_linux_x86_64.tar.gz
tar xzvf salmon-0.14.1_linux_x86_64.tar.gz

cd ../
 
