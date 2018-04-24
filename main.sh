work_dir="$(pwd)"

#create the directories for storing human genome relative data, and a directory for stroing the requiered programs
mkdir $work_dir/programs
bash $work_dir/scripts/download_programs.sh "$work_dir"   #download/install the needed programs
bash $work_dir/scripts/set_path.sh "$work_dir"            #setting the needed binary/scripts to PATH 

#download human genome resources and generate indexes for HISAT and STAR
mkdir $work_dir/hg38_data
index_dir_path=$work_dir/hg38_data/
bash $work_dir/scripts/genomeResources.sh "$index_dir_path" "HPC" 

## define a list of paper directories inside data file
for paper_dir in $work_dir/data/*; do if [ -d $paper_dir ];then
  echo $paper_dir;
fi;done > paper_dirs.txt      

#download the RNA-seq data 
module load SRAToolkit/2.3.4.2                 #if you already have it  
while read paper_dir; do          
      ##creating the structure for the downloaded data
      mkdir $paper_dir/poly_A
      mkdir $paper_dir/ribo_depleted
      ##download the data according to the accession list
      paper_name=$(echo "$(basename $paper_dir)")
      for acc_list in $work_dir/data/$paper_name/acc_lists/*.txt; do 
          if [[ $(echo "$(basename $acc_list)") == poly* || $(echo "$(basename $acc_list)") == ribo* ]]; then
             tissue_name=$(echo "$(basename $acc_list)" | sed s/.txt//)
             if [[ $(echo "$(basename $acc_list)") == poly* ]]; then
                tissue_dir=poly_A/$tissue_name;
             else
                tissue_dir=ribo_depleted/$tissue_name;
             fi   
             mkdir -p $paper_dir/$tissue_dir/fastq
             echo $tissue_dir >> $paper_dir/tissues.txt;
             cat $acc_list| 
	     while read acc_num ; do 
                ##download and convert data into fastq.gz format
                echo $acc_num $paper_dir/$tissue_dir;
                fastq-dump --outdir $paper_dir/$tissue_dir/fastq --gzip --split-files $acc_num   
             done
          fi
      done  
done < paper_dirs.txt
#############################

#perform quality control for the reads 
##merge reads coming from one sample
while read paper_dir;do
      bash $work_dir/scripts/concatenate.sh "$paper_dir"  
done < paper_dirs.txt

##trim merged reads
#prog_path=$work_dir/programs
prog_path="HPC" ## in case we use MSU HPC
while read paper_dir;do
      bash $work_dir/scripts/trim.sh "$paper_dir" "$prog_path" 
done < paper_dirs.txt
#############################

#creat folder to store the final assembled gtf files
while read paper_dir;do
      paper_name=$(echo "$(basename $paper_dir)")
      mkdir -p merged_gtf/$paper_name
done < paper_dirs.txt
merged_gtf_dir=$work_dir/merged_gtf

#create bed_files folder to stor the genomic regions in bed format
while read paper_dir;do
      paper_name=$(echo "$(basename $paper_dir)")
      mkdir -p bed_files/$paper_name
done < paper_dirs.txt
bed_files_dir=$work_dir/bed_files
#############################

### Hisat-stringtie pipeline
#map the trimmed merged reads using hisat
mkdir $work_dir/hisat-stringtie
hisat_dir=$work_dir/hisat-stringtie
while read paper_dir;do
      bash $work_dir/scripts/hisat.sh "$paper_dir" "$hisat_dir" "$index_dir_path" "HPC"
done < paper_dirs.txt 

#sort, convert to bam 
while read paper_dir;do
      bash $work_dir/scripts/getBAM.sh "$paper_dir" "$hisat_dir" "HPC"
done < paper_dirs.txt

while read paper_dir;do
      bash $work_dir/scripts/BamToBed.sh "$paper_dir" "$hisat_dir" "HPC" "$bed_files_dir" "stringtie"
done < paper_dirs.txt

#assemple the sam files using stringtie
while read paper_dir;do
      bash $work_dir/scripts/stringtie.sh "$paper_dir" "$hisat_dir" "HPC"
done < paper_dirs.txt

#merge the assembled gtf files
while read paper_dir;do
      bash $work_dir/scripts/stringtie_merge.sh "$paper_dir" "$hisat_dir" "$merged_gtf_dir" "HPC"
done < paper_dirs.txt
#############################

### STAR-Scallop pipeline
#map the trimmed merged reads using STAR
mkdir $work_dir/star-scallop
star_dir=$work_dir/star-scallop
while read paper_dir;do
      bash $work_dir/scripts/star.sh "$paper_dir" "$star_dir" "$index_dir_path"  "HPC"
done < paper_dirs.txt

#sort, convert to bam 
while read paper_dir;do
      bash $work_dir/scripts/getBAM.sh "$paper_dir" "$star_dir" "HPC" "scallop"
done < paper_dirs.txt

while read paper_dir;do
      bash $work_dir/scripts/BamToBed.sh "$paper_dir" "$star_dir" "HPC" "$bed_files_dir"
done < paper_dirs.txt

#assemple the sam files using scallop
prog_path=$work_dir/programs/coin-Clp
while read paper_dir;do
      bash $work_dir/scripts/scallop.sh "$paper_dir" "$star_dir" "HPC" ## use "$prog_path" instead of "HPC" for local analysis
done < paper_dirs.txt

#merge the assembled gtf files
while read paper_dir;do
      bash $work_dir/scripts/cuffmerge.sh "$paper_dir" "$star_dir" "$merged_gtf_dir" "HPC"
done < paper_dirs.txt
#############################

#Trinity pipeline
#map the trimmed merged reads using Trinity
mkdir $work_dir/trinity
prog_path="you need to define the path to the folder of trinity"
trinity_dir=$work_dir/trinity
while read paper_dir;do
      bash $work_dir/scripts/trinity.sh "$paper_dir" "$trinity_dir" "HPC"  ## use "$prog_path" instead of "HPC" for local analysis
done < paper_dirs.txt

#convert fasta to gtf 
while read paper_dir;do
      bash $work_dir/scripts/faToGtf.sh "$paper_dir" "$trinity_dir" "$index_dir_path" "$merged_gtf_dir" "HPC" "$bed_files_dir"
done < paper_dirs.txt
#############################

#perform comparisons and analysis
#compare assembled gtf files with the reference annotation using gffCompare
while read paper_dir;do
      bash $work_dir/scripts/compare_gtf.sh "$paper_dir" "$merged_gtf_dir" "$index_dir_path" 
done < paper_dirs.txt

bash $work_dir/scripts/refAnn_to_bedParts.sh "$index_dir_path" "$bed_files_dir" 

#convert the assembled gtf files to bed
while read paper_dir;do
      bash $work_dir/scripts/assemGtf_to_bed.sh "$paper_dir" "$merged_gtf_dir" "$bed_files_dir" 
done < paper_dirs.txt

#compare bed files converted from the assemblers' gtf files with the genomic-parts bed files
while read paper_dir;do
      bash $work_dir/scripts/compare_bed.sh "$bed_files_dir" "$paper_dir"
done < paper_dirs.txt

###########################

#perform exon-intron junction (EIJ) analysis
#extract the exon-intron spanning sequences
while read paper_dir;do
      bash $work_dir/scripts/generate_EIJ.sh "$bed_files_dir" "$paper_dir"
done < paper_dirs.txt

bash $work_dir/scripts/EIJ_spanning_reads.sh "$bed_files_dir"

