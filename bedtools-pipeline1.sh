#!/bin/bash
#performing bedtools analysis 

#in order to perform bed analysis, we have to convert the gtf giles into bed files first. gtfToGenePred and genePredToBed are two programs that will help us do this, and bedtools is the program to perform the analysis. 
 
wget -r --no-directories ftp://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred #download gtfToGenePred to convert gtf to genepred first
chmod 755 gtfToGenePred #enable gtfToGenePred

wget https://raw.githubusercontent.com/drtamermansour/horse_trans/master/scripts/genePredToBed #downlod genePredToBed to convert the genepred to bed 
chmod 755 genePredToBed #enable genePredToBed 

#copying the files to PATH
sudo cp /home/$username/genePredToBed /usr/bin
sudo cp /home/$username/gtfToGenePred /usr/bin

sudo apt-get install bedtools #install bedtools

#perform analysis on the bed files
cd RNA-seq/

mkdir bedtools/ #creating a directory to stor bedtools output
cd bedtools

gtfToGenePred /home/afnan/chrX_data/genes/chrX.gtf chrX.gpred #converting chromosome x gtf file into bed file
genePredToBed chrX.gpred > chrX.bed
echo "chrX file converted into bed file"

gtfToGenePred /home/afnan/RNA-seq/final_output/stringtie_merged.gtf stringtie_merged.gpred #converting assembled transcript gtf file into bed file
genePredToBed stringtie_merged.gpred > stringtie_merged.bed
echo "merged_transcript file converted into bed file"

#perform bedtools complement to get the non-exon regions from chrX.bed 
samtools faidx /home/afnan/RNA-seq/chrX_data/genome/chrX.fa #obtaining the size file from chrX.fa to be used with the complement command
cut -f1,2 /home/afnan/RNA-seq/chrX_data/genome/chrX.fa.fai > chrX.genome
sortBed -i chrX.bed > chrX_complement_sorted.bed #sort the bed file to pass it to the complement command
echo "sizes file and sorting are done"

complementBed -i chrX_sorted.bed -g chrX.genome > chrX_complement.bed #bed file containig the sequences that are not in the original gtf file
echo "complement finished"

cd #exit bedtools directory

#store the final output into final output folder
cd RNA-seq/final_output/
 
bedtools intersect -a /home/afnan/RNA-seq/bedtools/chrX.bed -b /home/afnan/RNA-seq/bedtools/stringtie_merged.bed > intersect_gtf.bed #report the overlapping parts with chrX.bed file
echo "intersection with ref bed is done" 

bedtools intersect -a /home/afnan/RNA-seq/bedtools/chrX_complement.bed -b /home/afnan/RNA-seq/bedtools/stringtie_merged.bed > intersect_gtfComplement.bed #reports the overlapping parts with chrX_complement.bed file
echo "intersection with ref-complement bed is done"


