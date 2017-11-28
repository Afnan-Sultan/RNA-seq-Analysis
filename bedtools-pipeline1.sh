

#download bedopt to convert gtf to bed
wget wget https://github.com/bedops/bedops/releases/download/v2.4.28/bedops_linux_x86_64-v2.4.28.tar.bz2  
tar jxvf bedops_linux_x86_64-v2.4.28.tar.bz2

#converting the resulted gtf and reference gtf into bed files
cd RNA-seq/
convert2bed --input=gtf [--output=bed]  < stringtie_merged.gtf > transcript.bed
convert2bed --input=gtf [--output=bed]  < chrX.gtf > reference.bed 

sudo apt-get install bedtools #install bedtools 


