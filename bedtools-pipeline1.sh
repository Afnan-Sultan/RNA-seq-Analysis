#!/bin/bash
#performing bedtools analysis 

sudo apt-get install bedtools #install bedtools

#perform analysis on the bed files
cd hisat-stringtie/

mkdir bedtools/ #creating a directory to stor bedtools output
cd bedtools

#extract exons coordinated only, convert them to bed, sorting them and storing the result in separate file
cat /home/afnan/chrX_data/genes/chrX.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > chrX_exons.bed

#extracting the rest of the genome coordinates. a genome sizes file is requiered, so, the following two command provide it.
samtools faidx /home/afnan/hisat-stringtie/chrX_data/genome/chrX.fa 
cut -f1,2 /home/afnan/hisat-stringtie/chrX_data/genome/chrX.fa.fai > chrX.genome

complementBed -i chrX_sorted.bed -g chrX.genome > chrX_complement.bed #bed file containig the sequences that are not in the original gtf file
echo "complement finished"

intersectBed -a chrX_exons.bed -b stringtie_merged.bed > /home/afnan/hisat-stringtie/final_output/intersect_exons.bed
intersectBed -a chrX_complement.bed -b stringtie_merged.bed > /home/afnan/hisat-stringtie/final_output/intersect_complement.bed #reports the overlapping parts with chrX_complement.bed file
echo "intersection with ref-complement bed is done"

#------------------------------------------------------------------------------------------------------------------------------#

:<<'END'

#in case of having the gene data as well in the annotation file, we can separate intronic from intergenic regions using the following commands 
cat /home/afnan/chrX_data/genes/chrX.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b chrX_exons.bed > chrX_introns.bed

cat /home/afnan/chrX_data/genes/chrX.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g chrX.genome > chrX_intergenic.bed  

cat /home/afnan/hisat-stringtie/final_output/stringtie_merged.gtf | 
awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
sortBed | > stringtie_merged.bed

intersectBed -a chrX_introns.bed -b stringtie_merged.bed > /home/afnan/hisat-stringtie/final_output/intersect_introns.bed
intersectBed -a chrX_intergenic.bed -b stringtie_merged.bed > /home/afnan/hisat-stringtie/final_output/intersect_intergenic.bed

:<<'END'
#OR use this command to generate genome sizes file for whole genome 
mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \ "select chrom, size from hg19.chromInfo"  > hg19.genome

#use this command to download mysql if not already installed  
sudo apt-get install mysql-client-core.5.7
END
END  


#-------------------------------------------------------------------------------------------------------------------------------#

#old pipeline
 
:<<'END'

#in order to perform bed analysis, we have to convert the gtf giles into bed files first. gtfToGenePred and genePredToBed are two programs that will help us do this, and bedtools is the program to perform the analysis. 
 
wget -r --no-directories ftp://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred #download gtfToGenePred to convert gtf to genepred first
chmod 755 gtfToGenePred #enable gtfToGenePred

wget https://raw.githubusercontent.com/drtamermansour/horse_trans/master/scripts/genePredToBed #downlod genePredToBed to convert the genepred to bed 
chmod 755 genePredToBed #enable genePredToBed 

#copying the files to PATH
sudo cp /home/$username/genePredToBed /usr/bin
sudo cp /home/$username/gtfToGenePred /usr/bin

gtfToGenePred /home/afnan/chrX_data/genes/chrX.gtf chrX.gpred #converting chromosome x gtf file into bed file
genePredToBed chrX.gpred > chrX.bed
echo "chrX file converted into bed file"

gtfToGenePred /home/afnan/hisat-stringtie/final_output/stringtie_merged.gtf stringtie_merged.gpred #converting assembled transcript gtf file into bed file
genePredToBed stringtie_merged.gpred > stringtie_merged.bed
echo "merged_transcript file converted into bed file"

#perform bedtools complement to get the non-exon regions from chrX.bed 
samtools faidx /home/afnan/hisat-stringtie/chrX_data/genome/chrX.fa #obtaining the size file from chrX.fa to be used with the complement command
cut -f1,2 /home/afnan/hisat-stringtie/chrX_data/genome/chrX.fa.fai > chrX.genome
sortBed -i chrX.bed > chrX_complement_sorted.bed #sort the bed file to pass it to the complement command
echo "sizes file and sorting are done"

complementBed -i chrX_sorted.bed -g chrX.genome > chrX_complement.bed #bed file containig the sequences that are not in the original gtf file
echo "complement finished"

cd #exit bedtools directory

#store the final output into final output folder
cd hisat-stringtie/final_output/
 
bedtools intersect -a /home/afnan/hisat-stringtie/bedtools/chrX.bed -b /home/afnan/hisat-stringtie/bedtools/stringtie_merged.bed > intersect_gtf.bed #report the overlapping parts with chrX.bed file
echo "intersection with ref bed is done" 

bedtools intersect -a /home/afnan/hisat-stringtie/bedtools/chrX_complement.bed -b /home/afnan/hisat-stringtie/bedtools/stringtie_merged.bed > intersect_gtfComplement.bed #reports the overlapping parts with chrX_complement.bed file
echo "intersection with ref-complement bed is done"
END


