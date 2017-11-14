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
       * The data to use (in this case, chromosome X data - Homosapiens) 
     * all these required files and softwarews will be obtained during the pipeline1.sh excution. 
  - STAR as an aligner, and Scripture as an assembler. 
    * requierments: 
      * unix OS and hardware that is 10x GB RAM -where x is the size of the genom in billion-  
      * STAR software
      * the data to use -which is the same chromosome X we already have-
- pipline1.sh file is illustrating all the requirements and steps to apply HISAT/StringTie pipeline. 
  * before excuting pipeline1.sh, you will need to set some paths and directories firstly. So, open the file and look for $ signs.
  * apply the following commands to get permission to excute pipeline1.sh file and to initiate it
    * $ chmod 755 pipeline1.sh 
    * $ ./pipeline1.sh
    
- pipeline2.sh file 
  
