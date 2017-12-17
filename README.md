# RNA-seq-Analysis
In this repository, we are going to apply two pipelines on RNA-seq data. 
- hisat-stringtie 
- star-scallop 

Before running the pipelines' script, some downloads and installments are requiered. 'required_downloads.sh' contains the downloads/installs programs, their dependancies and any other needed configurations. If you don't have any of these programms running already, you can excute that file and it'll do the work for you. Otherwise, navigate through the file to see what are you missing. 
  - the first lines of 'requiered_downloads.sh' contains the download commands for human gtf and fasta files needed in this project. Make sure to obtain these files.
  - the script creates 2 folders, one for storing the programs and another for storing the human genome data
  
'hisat-stringtie.sh' is the script for the first pipeline, it operates over the data downloaded from 'download_data_RNA-seq_TM-AS' folder. The flow of this pipeline is as follows: 
  - hisat generates genome indexes using the fasta file 
  - the reads per sample are mapped againest the genome using the generated indexes and a sam output is generated
  - samtools sorts the sam files and convert them into ban files
  - stringtie then assemble the generated bam files into gtf files 
  - stringtie --merge takes all the generated gtf files from one sample and merge them into one gtf file
  - gffcompare generates statistics files bwtween the assembled gtf and the human reference gtf
  - bedtools is then used to determine the intersections between the assembled transcripts and the exons/introns/intergenic regions from the reference gtf
  
The structur of the output folders from 'hisat-stringtie.sh' script is as follows: 
  - The script firstly creats 'hisat-stringtie' where all the work is stored 
  - hisat-stringtie folder containes 3 folders 
      - 'paper1': where the sam, bam anf gtf files are stored in subdirectories according to the liberary/sample
      - 'bedtools': where the exons, introns, intergenic and assembled transcript bed files are stored
      - 'final_output': where the assembled gtf from each sample, the gffcompare stats files and the intersection betwwen each file and genomic region are stored. 
      
