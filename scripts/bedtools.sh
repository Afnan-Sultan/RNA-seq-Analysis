#extract exons, introns and intergenic coordinates, convert them to bed, sorting them and storing the result in separate files
cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="exon" {print $1,$4-1,$5}' | 
sortBed | 
mergeBed -i - > $work_dir/bedtools/hg38_exons.bed

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | 
subtractBed -a stdin -b hg38_exons.bed > $work_dir/bedtools/hg38_introns.bed

cat $work_dir/hg38_data/gencode.v27.annotation.gtf | 
awk 'BEGIN{OFS="\t";} $3=="gene" {print $1,$4-1,$5}' | 
sortBed | complementBed -i stdin -g $work_dir/hg38_data/hg38.genome > $work_dir/bedtools/hg38_intergenic.bed
bash $work_dir/scripts/analysis.sh  
