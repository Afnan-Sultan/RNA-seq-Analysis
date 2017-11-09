#!/bin/bash
#implementing HISAT2 and Stringtie 

sudo apt-get updat #just a step to make sure everything is updated

: <<'END'
- downloads and installment:  
  1-  download the data using the following command on the terminal (The zip file is around 2GB) and unzip it.
  2-  if you don't hav GitHub installed already in your OS, use the following command on the terminal to install it. 
  3-  clone HISAT2 from GitHub using the following command
  4-  download Samtools into your device, unzip and configure it. -version later that 1.2 is requiered to analyse data more easily. 
  # The latest version at the time of writting this script is 1.6. The following command will download Samtools1.6. 
  #if you used the command $ sudo apt-get install samtools ; it'll install samtools-0.1.19, which will cost you more steps when applying the analysis. 
  5-  clone StringTie from GitHub and make it.
  6- clone gffcompare with the dependancy gclib and make release it.
END

wget ftp://ftp.ccb.jhu.edu/pub/RNAseq_protocol/chrX_data.tar.gz #download data
cd /home/$username/Downloads #where username is your OS user name
tar xvzf chrX_data.tar.gz #unzip it
cd #getting out of the directory

sudo apt-get install git #installing GitHub
 
git clone https://github.com/infphilo/hisat2 #installing Hisat2

wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 -O - | tar xj #downloadeing samtools
tar jxvf samtools-1.6.tar.bz2
cd samtools-1.6
make
cd

git clone https://github.com/gpertea/stringtie #installing StringTie
cd stringtie
make release
cd

git clone https://github.com/gpertea/gclib #installing dependancy of gffcompare
git clone https://github.com/gpertea/gffcompare #installing gffcompare
cd gffcompare
make release
cd

: <<'END'
- Setting the environment: 
  1-  create a directory to store all the requiered inputs/outputs inside. we called the file created "RNA-seq".
  2- add that file to your PATH so it becomes easy to run excutable files without needing to cd its directory.
  #if you used $ echo $PATH; you will manage to see all the files that are already in your PATH so far. 
  3- copy all the data we need into that directory, including our chromosom X data, Hisat2, samtools and strinTie binaries.
END

mkdir $HOME/RNA-seq #where $HOME is the desired path to place the directory at.  
export $HOME/RNA-seq:$PATH #adding to path

#copying data from chromosome X, samtools, Hisat, Stringtie & gffcompare
cp $HOME/chrX_dtat $HOME/RNA-seq #where $HOME is the path to our directory
cp $HOME/samtools-01.6/samtools $HOME/RNA-seq 
cp hisat2/hisat2* hisat2/*.py $HOME/RNA-seq
cp stringtie/stringtie $HOME/RNA-seq
cp gffcompare/gffcompare $HOME/RNA-seq

: <<'END'
- excution: 
  1- aligning RNA-seq data with a reference using hisat2. 
  # the chrX-data file contains 12 sampled from 12 persons. we will run the alignment for all these 12 samples. 
  2- converting the output sam files from hisat into bam files using samtools for all 12 resulted files. 
  3- assembling a transcriptome for each of the bam files using stringtie.
  4- merge the resulted 12 transcripts into one transcript. 
  5- comparing the trancsript with the reference annotation.  
END

cd $HOME/RNA-seq

# Map the reads for each sample to the reference genome:

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188044_chrX_1.fastq.gz -2 chrX_data/samples/ERR188044_chrX_2.fastq.gz -S ERR188044_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188104_chrX_1.fastq.gz -2 chrX_data/samples/ERR188104_chrX_2.fastq.gz -S ERR188104_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188234_chrX_1.fastq.gz -2 chrX_data/samples/ERR188234_chrX_2.fastq.gz -S ERR188234_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188245_chrX_1.fastq.gz -2 chrX_data/samples/ERR188245_chrX_2.fastq.gz -S ERR188245_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188257_chrX_1.fastq.gz -2 chrX_data/samples/ERR188257_chrX_2.fastq.gz -S ERR188257_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188273_chrX_1.fastq.gz -2 chrX_data/samples/ERR188273_chrX_2.fastq.gz -S ERR188273_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188337_chrX_1.fastq.gz -2 chrX_data/samples/ERR188337_chrX_2.fastq.gz -S ERR188337_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188383_chrX_1.fastq.gz -2 chrX_data/samples/ERR188383_chrX_2.fastq.gz -S ERR188383_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188401_chrX_1.fastq.gz -2 chrX_data/samples/ERR188401_chrX_2.fastq.gz -S ERR188401_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188428_chrX_1.fastq.gz -2 chrX_data/samples/ERR188428_chrX_2.fastq.gz -S ERR188428_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR188454_chrX_1.fastq.gz -2 chrX_data/samples/ERR188454_chrX_2.fastq.gz -S ERR188454_chrX.sam

hisat2 -p 8 --dta -x chrX_data/indexes/chrX_tran -1 chrX_data/samples/ERR204916_chrX_1.fastq.gz -2 chrX_data/samples/ERR204916_chrX_2.fastq.gz -S ERR204916_chrX.sam

# Sort and convert the SAM files to BAM:

samtools sort -@ 8 -o ERR188044_chrX.bam ERR188044_chrX.sam

samtools sort -@ 8 -o ERR188104_chrX.bam ERR188104_chrX.sam

samtools sort -@ 8 -o ERR188234_chrX.bam ERR188234_chrX.sam

samtools sort -@ 8 -o ERR188245_chrX.bam ERR188245_chrX.sam

samtools sort -@ 8 -o ERR188257_chrX.bam ERR188257_chrX.sam

samtools sort -@ 8 -o ERR188273_chrX.bam ERR188273_chrX.sam

samtools sort -@ 8 -o ERR188337_chrX.bam ERR188337_chrX.sam

samtools sort -@ 8 -o ERR188383_chrX.bam ERR188383_chrX.sam

samtools sort -@ 8 -o ERR188401_chrX.bam ERR188401_chrX.sam

samtools sort -@ 8 -o ERR188428_chrX.bam ERR188428_chrX.sam

samtools sort -@ 8 -o ERR188454_chrX.bam ERR188454_chrX.sam

samtools sort -@ 8 -o ERR204916_chrX.bam ERR204916_chrX.sam

	

# Assemble transcripts for each sample:

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188044_chrX.gtf -l ERR188044 ERR188044_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188104_chrX.gtf -l ERR188104 ERR188104_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188234_chrX.gtf -l ERR188234 ERR188234_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188245_chrX.gtf -l ERR188245 ERR188245_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188257_chrX.gtf -l ERR188257 ERR188257_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188273_chrX.gtf -l ERR188273 ERR188273_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188337_chrX.gtf -l ERR188337 ERR188337_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188383_chrX.gtf -l ERR188383 ERR188383_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188401_chrX.gtf -l ERR188401 ERR188401_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188428_chrX.gtf -l ERR188428 ERR188428_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR188454_chrX.gtf -l ERR188454 ERR188454_chrX.bam

stringtie -p 8 -G chrX_data/genes/chrX.gtf -o ERR204916_chrX.gtf -l ERR204916 ERR204916_chrX.bam

# Merge transcripts from all samples:

stringtie --merge -p 8 -G chrX_data/genes/chrX.gtf -o stringtie_merged.gtf chrX_data/mergelist.txt

# Examine how the transcripts compare with the reference annotation:

gffcompare -r chrX_data/genes/chrX.gtf -G -o merged stringtie_merged.gtf 

     
  
  

