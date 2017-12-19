#!/bin/bash
#implementing HISAT2 and Stringtie 

work_dir="$(pwd)"

#copying samtools, Hisat, Stringtie & gffcompare to $PATH
sudo cp $work_dir/programs_WorkDir/samtools-01.6/samtools /usr/bin
sudo cp $work_dir/programs_WorkDir/hisat2/hisat2* hisat2/*.py /usr/bin
sudo cp $work_dir/programs_WorkDir/stringtie/stringtie /usr/bin
sudo cp $work_dir/programs_WorkDir/gffcompare/gffcompare /usr/bin

#create a directory to store all the requiered inputs/outputs inside. we called the file created "hisat-stringtie".
mkdir $work_dir/hisat-stringtie   

#genome indexing without gtf annotation
mkdir $work_dir/hg38_data/hisat_index
hisat2-build -p 8 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa $work_dir/hg38_data/hisat_index/hg38

#create directories for paper 1 liberaries/samples 
mkdir $work_dir/hisat-stringtie/paper1 
mkdir $work_dir/hisat-stringtie/paper1/poly_A $work_dir/hisat-stringtie/paper1/ribo-depleted
mkdir $work_dir/hisat-stringtie/paper1/poly_A/reads_A $work_dir/hisat-stringtie/paper1/poly_A/reads_B $work_dir/hisat-stringtie/paper1/ribo-depleted/reads_A $work_dir/hisat-stringtie/paper1/ribo-depleted/reads_B

# loop over the paired reads from each sample to map them to the reference genome:
for a in $work_dir/download_data_RNA-seq_TM-AS/RNA-seq_data/*; do
    x=$(echo "$(basename $a)")
    for b in $a/reads_*; do
    y=$(echo "$(basename $b)")
    arr=($b/*) 
        for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2
    s=${arr[$i]} 
    v=$(echo "$(basename $s)"| sed s/_1.fastq.gz/.sam/) #naming the output fila based on the input file. basename is to get the file name without the path, and sed is to replace the extention. 
    
    hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 ${arr[$i]} -2 ${arr[$i+1]} -S $work_dir/hisat-stringtie/paper1/$x/$y/$v
       done  
    done
done

# Sort and convert the SAM files to BAM:
for a in $work_dir/hisat-stringtie/paper1/*; do
    for b in $a/reads_*; do
    arr=($b/*.sam)
    	for ((i=0; i<${#arr[@]}; i++)); do   
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.sam/.bam/)

    samtools sort -o $b/$v ${arr[$i]}
        done
    done      
done


# Assemble transcripts for each sample:
for a in $work_dir/hisat-stringtie/paper1/*; do
    for b in $a/reads_*; do
    arr=($b/*.bam)
    	for ((i=0; i<${#arr[@]}; i++)); do   
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.bam/.gtf/)
    w=$(echo "$(basename $s)"| sed s/.bam//)

    stringtie -o $b/$v -l $w ${arr[$i]}
        done
    done      
done


#create a directory to store th merged transcripts, stats and intersection with the differnet genome regions.  
mkdir $work_dir/hisat-stringtie/final_output
mkdir $work_dir/hisat-stringtie/final_output/paper1

# Merge transcripts from all samples:
# Merge transcripts from all samples:
for a in $work_dir/star-scallop/paper1/*; do
    x=p1_
    y=$(echo "$(basename $a"_")"
    for b in $a/reads_*; do
    z=$(echo "$(basename $b"_")"
    
stringtie --merge $b/*.gtf -o $work_dir/hisat-stringtie/final_output/paper1/$x$y$z"stringtie_merged.gtf"
    done
done

#create a directory to store the final transcript gff stat
mkdir $work_dir/hisat-stringtie/final_output/paper1/gffcompare 

# Examine how the transcripts compare with the reference annotation
for dir in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
    v=$(echo "$(basename $dir)"| sed s/stringtie_merged.gtf//)
gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $work_dir/hisat-stringtie/final_output/paper1/gffcompare/$v $dir
done

#copy the stats files to final output
cp $work_dir/hisat-stringtie/final_output/paper1/gffcompare/*.stats $work_dir/hisat-stringtie/final_output/paper1/

#creating a directory to stor bedtools output
mkdir $work_dir/hisat-stringtie/bedtools/ 

#extract exons, introns and intergenic coordinates, convert them to bed, sorting them and storing the result in separate files
cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > $work_dir/hisat-stringtie/bedtools/hg38_exons.bed

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b hg38_exons.bed > $work_dir/hisat-stringtie/bedtools/hg38_introns.bed

samtools faidx $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa
cut -f1,2 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa.fai > $work_dir/hisat-stringtie/bedtools/hg38.genome

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g $work_dir/hisat-stringtie/bedtools/hg38.genome > $work_dir/hisat-stringtie/bedtools/hg38_intergenic.bed  

for f in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
    v=$(echo "$(basename $f)"| sed s/.gtf/.bed/)
cat $f| 
awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
sortBed | > $work_dir/hisat-stringtie/bedtools/$v
done

for f in $work_dir/hisat-stringtie/final_output/paper1/bedtools/*.bed; do
    v=$(echo "$(basename $dir)"| sed s/.bed/_intersect_/)
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_exons.bed -b $f > $work_dir/hisat-stringtie/final_output/paper1/$v"exons.bed"
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_introns.bed -b $f > $work_dir/hisat-stringtie/final_output/paper1/$v"introns.bed"
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_intergenic.bed -b $f > $work_dir/hisat-stringtie/final_output/paper1/$v"intergenic.bed"
done
