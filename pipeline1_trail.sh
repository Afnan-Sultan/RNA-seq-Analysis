#!/bin/bash
#implementing HISAT2 and Stringtie 

sudo apt-get updat #just a step to make sure everything is updated

## modified pipeline 1

#downloads and installment:  
wget ftp://ftp.ccb.jhu.edu/pub/RNAseq_protocol/chrX_data.tar.gz #download data
cd /home/$username/Downloads #where username is your OS user name
tar xvzf chrX_data.tar.gz #unzip it
cd #getting out of the directory

sudo apt-get install git #installing GitHub
 
git clone https://github.com/infphilo/hisat2 #installing Hisat2

wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 -O - | tar xj #downloadeing samtools
cd /home/$username/Downloads #where username is your OS user name 
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

#create a directory to store all the requiered inputs/outputs inside. we called the file created "RNA-seq".
mkdir $HOME/RNA-seq #where $HOME is the desired path to place the directory at.  
cd RNA-seq/

#copying data from chromosome X to our work directory, and samtools, Hisat, Stringtie & gffcompare to $PATH
cp -r $HOME/chrX_data $HOME/RNA-seq #where $HOME is the path to directory
sudo cp $HOME/samtools-01.6/samtools /usr/bin
sudo cp hisat2/hisat2* hisat2/*.py /usr/bin
sudo cp stringtie/stringtie /usr/bin
sudo cp gffcompare/gffcompare /usr/bin

#genome indexing without gtf annotation
mkdir /home/$username/RNA-seq/chrX_data/index
hisat2-build -p 8 HOME/chrX_data/genome/chrX.fa home/$username/RNA-seq/chrX_data/index/index 

# loop over the paired reads to map them to the reference genome:
arr=(/home/$username/chrX_data/samples/*) #store all fastq.gz files in an array to loop over
for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2
    s=${arr[$i]} 
    v=$(echo "$(basename $s)"| sed s/_1.fastq.gz/.sam/) #naming the output fila based on the input file. basename is to get the file name without the path, and sed is to replace the extention. 
    
    hisat2 -p 8 --dta -x chrX_data/index/index -1 ${arr[$i]} -2 ${arr[$i+1]} -S $v
done

# Sort and convert the SAM files to BAM:
arr=(/home/$username/RNA-seq/*.sam)
for ((i=0; i<${#arr[@]}; i++)); do
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.sam/.bam/)
    
    samtools sort -o $v ${arr[$i]}
done
	

# Assemble transcripts for each sample:
arr=(/home/$username/RNA-seq/*.bam)
for ((i=0; i<${#arr[@]}; i++)); do
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.bam/.gtf/)
    w=$(echo "$(basename $v)"| sed s/.bam//)
 
    stringtie -o $v -l $w ${arr[$i]}
done

#create a directory to store the final transcript abd gff stat 
mkdir /home/$username/RNA-seq/final_output
cd final_output/

# Merge transcripts from all samples:
stringtie --merge /home/$username/RNA-seq/*.gtf -o stringtie_merged.gtf

# Examine how the transcripts compare with the reference annotation:
gffcompare -r /home/$username/RNA-seq/chrX_data/genes/chrX.gtf -o gffOutput merged_transcript.gtf 
