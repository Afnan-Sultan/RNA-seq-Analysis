# RNA-seq-Analysis
 This project is about using tools to analyze RNA-seq data by mapping the reads to a reference genome,followed by transcriptom assembly.
- In this project, we will use two pipelines. 
  - HISAT2 as an aligner, and StringTie as an assembler.
    * requirements for this pipeline: 
       * a unix operating system (in this project, ubuntu 16.04 was used) 
       * 64-bit computer with 4 to 8 GB RAM
       * HISAT2 software
       * Samtools
       * StringTie software
       * gffcompare
       * The data to use.
     * all these required files and softwarews will be obtained during the pipeline1.sh excution.
     * you need to open the script first and change any $HOME/$username with the path to the directory requiered or you PC username
  - STAR as an aligner, and scallop as an assembler. 
    * requierments: 
      * unix OS and hardware that is 10x GB RAM -where x is the size of the reference genome used in billions-  
      * STAR software
      * scallop software
      * zlib
      * htslib
      * Clp
      * the data to use -which is the same chromosome X we already have-
     * all these required files and softwarews will be obtained during the pipeline1.sh excution. 
     * you need to open the script first and change any $HOME/$username with the path to the directory requiered or you PC username
     
     
- pipline1_trail.sh file is illustrating all the requirements and steps to apply HISAT/StringTie pipeline with a small data which is chromosome X from human. 
  * before excuting pipeline1_trail.sh, you will need to set some paths and directories firstly. So, open the file and look for $ signs.
  * apply the following commands to get permission to excute pipeline1_trail.sh file and to initiate it
    * $ chmod 755 pipeline1.sh 
    * $ ./pipeline1_trail.sh
   
   
- pipline2_trail.sh file is illustrating all the requirements and steps to apply STAR/scallop pipeline with the same data of chromosome X from human, but only couple of reads were used for simplicity. 
  * before excuting pipeline1_trail.sh, you will need to set some paths and directories firstly. So, open the file and look for $ signs.
  * apply the following commands to get permission to excute pipeline2_trail.sh file and to initiate it
    * $ chmod 755 pipeline2.sh 
    * $ ./pipeline2_trail.sh

- bedtools-pipeline1.sh file is for the analysis of the resulting transcript gtf file using bedtools. In this file, we will find out which exons intersect withing the reference transcriptome, which introns intersect and which intergenic regions will intersect; 

  * before excuting pipeline1_trail.sh, you will need to set some paths and directories firstly. So, open the file and look for $ signs.
  * apply the following commands to get permission to excute pipeline2_trail.sh file and to initiate it
    * $ chmod 755 bedtools-pipeline1.sh 
    * $ ./bedtools-pipeline1_trail.sh
 
