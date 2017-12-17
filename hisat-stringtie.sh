#!/bin/bash
#implementing HISAT2 and Stringtie 

work_dir="$(pwd)"
cd $work_dir/

#copying samtools, Hisat, Stringtie & gffcompare to $PATH
sudo cp $work_dir/programs_WorkDir/samtools-01.6/samtools /usr/bin
sudo cp $work_dir/programs_WorkDir/hisat2/hisat2* hisat2/*.py /usr/bin
sudo cp $work_dir/programs_WorkDir/stringtie/stringtie /usr/bin
sudo cp $work_dir/programs_WorkDir/gffcompare/gffcompare /usr/bin

#create a directory to store all the requiered inputs/outputs inside. we called the file created "hisat-stringtie".
mkdir hisat-stringtie #where $work_dir is the desired path to place the directory at.  
cd hisat-stringtie/

#genome indexing without gtf annotation
mkdir $work_dir/hg38/hisat_index
hisat2-build -p 8 $work_dir/hg38_data/GRCh38.p10.genome.fa $work_dir/hg38_data/hisat_index/hg38

#create directories for paper 1 liberaries/samples 
mkdir paper1
cd paper1/
 
mkdir polyA
cd polyA/
mkdir reads_A reads_B
cd ../

mkdir ribo-depleted
cd ribo-depleted/
mkdir reads_A reads_B
cd ../ 

# loop over the paired reads from each sample to map them to the reference genome:

for a in $work_dir/download_data_RNA-seq_TM-AS/RNA-seq_data/*; do
    x=$(echo "$(basename $a)")
    for b in $a/reads_*; do
    y=$(echo "$(basename $b)")
    arr=($b/*) 
    cd $work_dir/hisat-stringtie/paper1/$x/$y/
        for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2
    s=${arr[$i]} 
    v=$(echo "$(basename $s)"| sed s/_1.fastq.gz/.sam/) #naming the output fila based on the input file. basename is to get the file name without the path, and sed is to replace the extention. 
    
    hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 ${arr[$i]} -2 ${arr[$i+1]} -S $v
done  
done
done

# Sort and convert the SAM files to BAM:

for a in $work_dir/hisat-stringtie/paper1/*; do
    for b in $a/reads_*; do
    arr=($b/*.sam)
    cd $b
    	for ((i=0; i<${#arr[@]}; i++)); do   
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.sam/.bam/)

    samtools sort -o $v ${arr[$i]}
done
done      
done


# Assemble transcripts for each sample:

for a in $work_dir/hisat-stringtie/paper1/*; do
    for b in $a/reads_*; do
    arr=($b/*.bam)
    cd $b
    	for ((i=0; i<${#arr[@]}; i++)); do   
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.bam/.gtf/)

    stringtie -o $v -l $w ${arr[$i]}
done
done      
done
cd ../ ../ ../

#create a directory to store the final transcript gff stat 
mkdir final_output
cd final_output/
mkdir paper1
cd paper1/

# Merge transcripts from all samples:
stringtie --merge $work_dir/hisat-stringtie/paper1/polyA/reads_A/*.gtf -o p1_sA_poly_stringtie_merged.gtf
stringtie --merge $work_dir/hisat-stringtie/paper1/polyA/reads_B/*.gtf -o p1_sB_poly_stringtie_merged.gtf
stringtie --merge $work_dir/hisat-stringtie/paper1/ribo_depleted/reads_A/*.gtf -o p1_sA_ribo_stringtie_merged.gtf
stringtie --merge $work_dir/hisat-stringtie/paper1/ribo_depleted/reads_B/*.gtf -o p1_sB_ribo_stringtie_merged.gtf

# Examine how the transcripts compare with the reference annotation
mkdir gffcompare 
cd gffcompare/

for dir in $work_dir/hisat-stringtie/final_output/paper1/*; do 
    v=$(echo "$(basename $dir)"| sed s/stringtie_merged.gtf//)
gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $v $dir
done

#copy the stats files to final output
cp *.stats $work_dir/hisat-stringtie/final_output/paper1/
cd ../ ../ ../ 


mkdir bedtools/ #creating a directory to stor bedtools output
cd bedtools

#extract exons coordinated only, convert them to bed, sorting them and storing the result in separate file
cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > hg38_exons.bed

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b hg38_exons.bed > hg38_introns.bed

mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e \ "select chrom, size from hg38.chromInfo"  > hg38.genome
cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g hg38.genome > hg38_intergenic.bed  

for dir in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
    v=$(echo "$(basename $dir)"| sed s/.gtf/.bed/)
cat $dir| 
awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
sortBed | > $v
done

for dir in $work_dir/hisat-stringtie/final_output/paper1/*.bed; do
    v=$(echo "$(basename $dir)"| sed s/.bed/_intersect_/)
intersectBed -a hg38_exons.bed -b $dir > $work_dir/hisat-stringtie/final_output/paper1/$v"exons.bed"
intersectBed -a hg38_introns.bed -b $dir > $work_dir/hisat-stringtie/final_output/paper1/$v"introns.bed"
intersectBed -a hg38_intergenic.bed -b $dir > $work_dir/hisat-stringtie/final_output/paper1/$v"intergenic.bed"
done

cd








 


