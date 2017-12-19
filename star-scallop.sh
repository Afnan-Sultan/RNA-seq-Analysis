#!/bin/bash
#impeleminting STAR and scallop

work_dir="$(pwd)"

#copying STAR and scallop to $PATH
sudo cp $work_dir/programs_WorkDir/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin/
sudo cp $work_dir/programs_WorkDir/scallop/src/scallop /usr/bin/

#create a directory to store all the requiered inputs/outputs inside. we called the file created "star-scallop".
mkdir $work_dir/start-scallop

#genome indexing without gtf annotation
mkdir $work_dir/hg38_data/star_index
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $work_dir/hg38_data/star_index/ --genomeFastaFiles $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa 

#create directories for paper 1 liberaries/samples 
mkdir $work_dir/star-scallop/paper1 
mkdir $work_dir/star-scallop/paper1/poly_A $work_dir/star-scallop/paper1/ribo-depleted
mkdir $work_dir/star-scallop/paper1/poly_A/reads_A $work_dir/star-scallop/paper1/poly_A/reads_B $work_dir/star-scallop/paper1/ribo-depleted/reads_A $work_dir/star-scallop/paper1/ribo-depleted/reads_B

# loop over the paired reads from each sample to map them to the reference genome:
for a in $work_dir/download_data_RNA-seq_TM-AS/RNA-seq_data/*; do
    x=$(echo "$(basename $a)")
    for b in $a/reads_*; do
    y=$(echo "$(basename $b)")
    arr=($b/*)
        for ((i=0; i<${#arr[@]}; i=i+2)); do #excute the loop with base 2 
    mkdir $work_dir/star-scallop/paper1/$x/$y/read_$i 
 STAR --runThreadN 1 --genomeDir $work_dir/hg38_data/star_index --readFilesIn ${arr[$i]} ${arr[$i+1]} --readFilesCommand zcat --outFileNamePrefix /$work_dir/star-scallop/paper1/$x/$y/read_$i
        done  
    done
done

# Sort and convert the SAM files to BAM:
for a in $work_dir/star-scallop/paper1/*; do
    for b in $a/reads_*; do
        for c in $b/read_*; do
    v=$(echo "$(basename $c)"| sed s/read//)
    samtools sort -o $b/Aligned.out$v.bam $c/Aligned.out.sam
        done
    done
done

# Assemble transcripts for each sample:
export LD_LIBRARY_PATH=$work_dir/programs_WorkDir/coin-Clp/lib:LD_LIBRARY_PATH #set Clp library to be available for shared libraries
for a in $work_dir/star-scallop/paper1/*; do
    for b in $a/reads_*; do
    arr=($b/*.bam)
    	for ((i=0; i<${#arr[@]}; i++)); do 
    s=${arr[$i]}
    v=$(echo "$(basename $s)"| sed s/.bam/.gtf/)  
    scallop -i $b/${arr[$i]} -o $b/$v
        done
    done
done

#stor gtf paths for each sample in a txt file to pass it to cufflinks
for a in $work_dir/star-scallop/paper1/*; do
    for b in $a/reads_*; do
      for c in $b/*.gtf; do 
    echo $c 
      done > $b/gtf_list.txt
    done
done

#create a directory to store th merged transcripts, stats and intersection with the differnet genome regions.  
mkdir $work_dir/star-scallop/final_output
mkdir $work_dir/star-scallop/final_output/paper1

# Merge transcripts from all samples:
for a in $work_dir/star-scallop/paper1/*; do
    x=p1_
    y=$(echo "$(basename $a"_")"
    for b in $a/reads_*; do
    z=$(echo "$(basename $b"_")"

cuffmerge $b/gtf_list.txt -o $b/
mv $b/merged_asm/merged.gtf $work_dir/star-scallop/final_output/paper1/$x$y$z"scallop_merged.gtf"
    done
done

#create a directory to store the final transcript gff stat
mkdir $work_dir/star-scallope/final_output/paper1/gffcompare 

# Examine how the transcripts compare with the reference annotation
for dir in $work_dir/star-scallope/final_output/paper1/*.gtf; do 
    v=$(echo "$(basename $dir)"| sed s/scallop_merged.gtf//)
gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $work_dir/star-scallope/final_output/paper1/gffcompare/$v $dir
done

#copy the stats files to final output
cp $work_dir/star-scallope/final_output/paper1/gffcompare/*.stats $work_dir/star-scallope/final_output/paper1/

#creating a directory to stor bedtools output
mkdir $work_dir/star-scallope/bedtools/ 

#extract exons, introns and intergenic coordinates, convert them to bed, sorting them and storing the result in separate files
cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > $work_dir/star-scallope/bedtools/hg38_exons.bed

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b hg38_exons.bed > $work_dir/star-scallope/bedtools/hg38_introns.bed

samtools faidx $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa
cut -f1,2 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa.fai > $work_dir/star-scallope/bedtools/hg38.genome

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g $work_dir/star-scallope/bedtools/hg38.genome > $work_dir/star-scallope/bedtools/hg38_intergenic.bed  

for f in $work_dir/star-scallope/final_output/paper1/*.gtf; do 
    v=$(echo "$(basename $f)"| sed s/.gtf/.bed/)
cat $f| 
awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
sortBed | > $work_dir/star-scallope/bedtools/$v
done

for f in $work_dir/star-scallope/final_output/paper1/bedtools/*.bed; do
    v=$(echo "$(basename $dir)"| sed s/.bed/_intersect_/)
intersectBed -a $work_dir/star-scallope/bedtools/hg38_exons.bed -b $f > $work_dir/star-scallope/final_output/paper1/$v"exons.bed"
intersectBed -a $work_dir/star-scallope/bedtools/hg38_introns.bed -b $f > $work_dir/star-scallope/final_output/paper1/$v"introns.bed"
intersectBed -a $work_dir/star-scallope/bedtools/hg38_intergenic.bed -b $f > $work_dir/star-scallope/final_output/paper1/$v"intergenic.bed"
done







