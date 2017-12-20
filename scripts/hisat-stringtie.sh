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
for lib_dir in $work_dir/download_data_RNA-seq_TM-AS/RNA-seq_data/*; do #if lib_dir -d #check if folder 
    temp1=$(echo "$(basename $lib_dir)")
    for gb_dir in $lib_dir/reads_*; do
        temp2=$(echo "$(basename $gb_dir)") 
        for read in $gb_dir/*_1.fastq.gz ; do #excute the loop for paired read
            temp3=$(echo "$(basename $s)"| sed s/_1.fastq.gz/.sam/) #naming the output fila based on the input file. basename is to get the file name without the path, and sed is to replace the extention. 
            input1=$read
            input2=$(echo "$(basename $s)"| sed s/_1.fastq.gz/_2.fastq.gz/)
            output=$temp1/temp2/temp3
            hisat2 -p 8 --dta -x $work_dir/hg38/hisat_index/hg38 -1 $input1 -2 $input2 -S $work_dir/hisat-stringtie/paper1/$output
       done  
    done
done

# Sort and convert the SAM files to BAM:
for lib_dir in $work_dir/hisat-stringtie/paper1/*; do
    for gb_dir in $lib_dir/reads_*; do
    	for sam in $gb_dir/*.sam; do ; do   
            output=$(echo "$(basename $sam)"| sed s/.sam/.bam/)
            samtools sort -o $gb_dir/$output ${arr[$i]}
        done
    done      
done


# Assemble transcripts for each sample:
for lib_dir in $work_dir/hisat-stringtie/paper1/*; do
    for gb_dir in $lib_dir/reads_*; do
    	for bam in &gb_dir/*.bam; do   
            output=$(echo "$(basename $s)"| sed s/.bam/.gtf/)
            label=$(echo "$(basename $s)"| sed s/.bam//)
            stringtie -o $bam/$output -l $label $bam
        done
    done      
done


#create a directory to store th merged transcripts, stats and intersection with the differnet genome regions.  
mkdir $work_dir/hisat-stringtie/final_output
mkdir $work_dir/hisat-stringtie/final_output/paper1

# Merge transcripts from all samples:
# Merge transcripts from all samples:
for lib_dir in $work_dir/star-scallop/paper1/*; do if $lib_dir -d
    temp1=$(echo "p1_""$(basename $a"_")")
    for read_dir in $lib_dir/reads_*; do
        temp2=$(echo "$(basename $read_dir"_stringtie_merged.gtf")") 
        output=$temp1$temp2
        stringtie --merge $read_dir/*.gtf -o $work_dir/hisat-stringtie/final_output/paper1/$output
    done
done

#create a directory to store the final transcript gff stat
mkdir $work_dir/hisat-stringtie/final_output/paper1/gffcompare 

# Examine how the transcripts compare with the reference annotation
for gtf_file in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
    output=$(echo "$(basename $gtf_file)"| sed s/stringtie_merged.gtf//)
    gffcompare -r $work_dir/hg38_data/gencode.v27.annotation.gtf -o $work_dir/hisat-stringtie/final_output/paper1/gffcompare/$output $gtf_file
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

for gtf_file in $work_dir/hisat-stringtie/final_output/paper1/*.gtf; do 
    output=$(echo "$(basename $gtf_file)"| sed s/.gtf/.bed/)
    cat $gtf_file| 
    awk 'BEGIN{OFS="\t";} {print $1,$4-1,$5}' | 
    sortBed | > $work_dir/hisat-stringtie/bedtools/$output
done

for bed_file in $work_dir/hisat-stringtie/final_output/paper1/bedtools/*.bed; do
    output=$(echo "$(basename $dir)"| sed s/.bed/_intersect_/)
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_exons.bed -b $bed_file > $work_dir/hisat-stringtie/final_output/paper1/$output"exons.bed"
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_introns.bed -b $bed_file > $work_dir/hisat-stringtie/final_output/paper1/$output"introns.bed"
intersectBed -a $work_dir/hisat-stringtie/bedtools/hg38_intergenic.bed -b $bed_file > $work_dir/hisat-stringtie/final_output/paper1/$output"intergenic.bed"
done
