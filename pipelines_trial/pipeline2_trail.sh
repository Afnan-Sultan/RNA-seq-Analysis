#!/bin/bash
#impeleminting STAR and scallop

#Installing scallop dependancies
wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz #getting boost folder
tar xvzf boost_1_65_1.tar.gz

wget https://zlib.net/zlib-1.2.11.tar.gz #getting & installing zlib required for htslib
tar xvzf zlib-1.2.11.tar.gz 
cd zlib-1.2.11/
./configure
make
sudo make install
cd

git clone https://github.com/samtools/htslib #cloning & installing htslib
cd htslib/
autoheader
autoconf
./configure --disable-bz2 --disable-lzma --disable-gcs --disable-s3 --enable-libcurl=no
make 
sudo make install
cd

sudo apt-get install subversion #install subversion requiered for ClP
svn co https://projects.coin-or.org/svn/Clp/stable/1.16 coin-Clp #getting & installing clp
cd coin-Clp
./configure --disable-bzlib --disable-zlib
make
sudo make install 
cd

#Installing Scallop
git clone https://github.com/Kingsford-Group/scallop
cd scallop/ 
autoreconf --install       	
autoconf configure.ac
./configure --with-clp=/home/$username/coin-Clp --with-htslib=/home/$username/htslib --with-boost=/home/$username/boost_1_65_1
make
cd

#downloading STAR and unziping it
wget https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz 
tar xvzf STAR-2.5.3a.tar.gz

#adding STAR and scallop binary files to PATH environment
sudo cp /home/$username/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin/
sudo cp /home/$username/scallop/src/scallop /usr/bin/

#----------------------------------------------#

#procedures 

export LD_LIBRARY_PATH=/home/$username/coin-Clp/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries

mkdir /home/$username/star-scallop

#copy importanti files to work directory
cp -r /home/$username/chrX_data /home/$username/star-scallop #where $HOME is the path to directory 
cp -r /home/$username/STAR-2.5.3a/source /home/$username/star-scallop
echo "files copied to workspace"

#create a folder to store generated indexes files
cd /home/$username/star-scallop/
mkdir genome 
echo "folder created for storing genome indexes"

#generating genome indexing with gtf annotation
: <<'END'
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir /home/$username/star-scallop/genome/ --genomeFastaFiles /home/$username/star-scallop/chrX_data/chrX.fa --sjdbGTFfile /home/$username/star-scallop/chrX_data/chrX.gtf --sjdbOverhang 100
echo "genome indexes generated with reference gtf"
END

#generating genome indexing without gtf annotation
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir /home/$username/star-scallop/genome/ --genomeFastaFiles /home/$username/star-scallop/chrX_data/chrX.fa
echo "genome indexes generated without reference gtf"

#creating a file to store the reads
mkdir reads
cd reads/

#Mapping the reads with gtf reference  
:<<'END'
arr=(/home/$username/chrX_data/samples/*) #store all fastq.gz files in an array to loop over
for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2
    mkdir read_$i
    cd read_$i/
    STAR --runThreadN 1 --genomeDir /home/$username/star-scallop/genome --sjdbGTFfile /home/$username/star-scallop/chrX_data/chrX.gtf --readFilesIn ${arr[$i]} ${arr[$i+1]} --readFilesCommand zcat
    cd ../
done
echo "reads mapped and stored in 'reads' directory with respect to gtf file"
END

#Mapping the reads without gtf reference
arr=(/home/$username/chrX_data/samples/*) #store all fastq.gz files in an array to loop over
for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2
    mkdir read_$i
    cd read_$i/
    STAR --runThreadN 1 --genomeDir /home/$username/star-scallop/genome --readFilesIn ${arr[$i]} ${arr[$i+1]} --readFilesCommand zcat
    cd ../
done
echo "reads mapped and stored in 'reads' directory with no respect to gtf file"

#Sorting and converting the output sam file into bam file
for dir in /home/$username/star-scallop/reads/read_*; do
    cd $dir
    v=$(echo "$(basename $dir)"| sed s/read//)
    samtools sort -o Aligned.out$v.bam Aligned.out.sam
    cp $dir/Aligned.out$v.bam  /home/afnan/star-scallop/
done
echo "sam files sorted, converted into bam files and copied to the 'star-scallop' directory"

#create a directory to store the final transcript gffCompare stat 
mkdir /home/$username/star-scallop/final_output
cd final_output/

#transcriptom assembly
export LD_LIBRARY_PATH=/home/$username/coin-Clp/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries
scallop -i /home/$username/star-scallop/*.bam -o scallop_merged.gtf
echo "bam files assembled into gtf file and stored at 'final_output' directory"

# Examine how the transcripts compare with the reference annotation:
gffcompare -r /home/$username/star-scallop/chrX_data/genes/chrX.gtf -o gffOutput scallop_merged.gtf 
echo"gffCompare files generated and stored at 'final_output' directory"

#--------------------------------------------------------------------------------------------------------#

#old pipeline 2

: <<'END'
#downloading STAR and unziping it
wget https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz 
tar xvzf chrX_data.tar.gz

#Installing scallop dependancies
wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz #getting boost folder
tar xvzf boost_1_65_1.tar.gz

wget https://zlib.net/zlib-1.2.11.tar.gz #getting & installing zlib required for htslib
tar xvzf zlib-1.2.11.tar.gz 
cd zlib-1.2.11/
./configure
make
sudo make install
cd

git clone https://github.com/samtools/htslib #cloning & installing htslib
cd htslib/
autoheader
autoconf
./configure --disable-bz2 --disable-lzma --disable-gcs --disable-s3 --enable-libcurl=no
make 
sudo make install
cd

sudo apt-get install subversion #install subversion requiered for ClP
svn co https://projects.coin-or.org/svn/Clp/stable/1.16 coin-Clp #getting & installing clp
cd coin-Clp
./configure --disable-bzlib --disable-zlib
make
sudo make install 
cd

export LD_LIBRARY_PATH=/home/$username/coin-Clp/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries

#Installing Scallop
git clone https://github.com/Kingsford-Group/scallop
cd scallop/ 
autoreconf --install       	
autoconf configure.ac
./configure --with-clp=/home/$username/coin-Clp --with-htslib=/home/$username/htslib --with-boost=/home/$username/boost_1_65_1
make
cd

#----------------------------------------------#

#procedures 

#copy chromosom X GTF file, chromosom X fasta file, and couple of read files -for simplicity- into STAR workspace
cp $HOME/chrX_data/genes/chrX.gtf  /home/$username/STAR-2.5.3a 
cp $HOME/chrX_data/genome/chrX.fa  /home/$username/STAR-2.5.3a
cp $HOME/chrX_data/samples/ERR188044_chrX_1.fastq.gz  /home/$username/STAR-2.5.3a/ 
cp $HOME/chrX_data/samples/ERR188044_chrX_2.fastq.gz  /home/$username/STAR-2.5.3a/

#copy gffcompare to do a comparison when done with the assembly
cp $HOME/gffcompare/gffcompare  /home/$username/STAR-2.5.3a 

#adding STAR and scallop binary files to PATH environment
cp /home/$username/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin
cp /home/$username/scallop/src/scallop /usr/bin 

#creating important folders
cd /home/$username/STAR-2.5.3a
mkdir basic #to store the output of the process inside
mkdir genome #create a folder to store generated indixes files

#generating genome indexing
cd basic/ 
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir /home/$username/STAR-2.5.3a/genome/ --genomeFastaFiles /home/$username/STAR-2.5.3a/chrX.fa --sjdbGTFfile /home/$username/STAR-2.5.3a/chrX.gtf --sjdbOverhang 100

#Mapping the reads 
STAR --runThreadN 4 --genomeDir /home/$username/STAR-2.5.3a/genome --sjdbGTFfile /home/$username/STAR-2.5.3a/chrX.gtf --readFilesIn /home/$username/STAR-2.5.3a/ERR188044_chrX_1.fastq.gz /home/$username/STAR-2.5.3a/ERR188044_chrX_2.fastq.gz --readFilesCommand zcat

#Sorting and converting the output sam file into bam file
samtools sort -@ 8 -o Aligned.out.bam Aligned.out.sam

#transcriptom assembly
scallop -i Aligned.out.bam -o Aligned.out.gtf 

# Examine how the transcripts compare with the reference annotation
./gffcompare -r chrX.gtf -G -o merged Aligned.out.gtf
END
