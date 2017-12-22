# scripts

In this `README.md` file, the workflow of each script will be mentioned breifly.
  -`required_downloads.sh`
The first script to be excuted is this one, the content of this script is:
    - the first block is downloading the required genomic data for the pipelines and analysis
    - the second block downloads the tool to download RNA-seq reads as well as the tool to trim it
    - the third and fourth block are for downloading each pipeline related programs as well as installing them
You may wish to have a look on that script to check if a program is already on your PC and comment it's command

  - `set_path.sh` 
This is the second in the line script to be excuted. It simply add the downloaded programs' binaries, libraries or any needed file during the excution, just for simplicitly. 
You may also like to check it and comment the programs you didn't dowsnload from the previous scripr -to avoid errors in the bash-, or changed the path to the program. 

** If you don't need any of these two scripts, you can comment their excution command from the `main.sh` script

  - `trim_concatenate.sh`
The next excuted script is performing a quality control over the reads by trimming the adaptors, checking for bases length eligibility and some other conditions, using `trimmomatic-0.36.jar`

  - `hisat-stringtie.sh`
This is our first pipeline, the content of this script is as follows: 
    - the first block generates the needed indexes for hisat aligner
    - the second block generates a `final_output` folder to store the most important outpus 
    - the third block loops over each paper, sample and read in `data` folder and map a paired read per time while storing the output `.sam` file in the equivelant file in `hisat-stringtie` folder. 
    - at the same loop, the generated sam file is passed to `samtools-1.6` to be sorted and converted into `.bed` file.
    - the `.bam` file itself is then passed to `stringtie-1.3.4` to assemble the transcript and generate `.gtf` file
    - by the end of this loop, and as all output files were stored at the hisate* pipeline, `stringtie --merge` is then catshing all the `.gtf` files and merge them in one output. 
    - A new loop is then started to the next paper and so on. 
    
  - `star-scallop` 
The same workflow of `hisat-stringtie.sh` applies for this pipeline. The only difference is that `STAR-2.5.3a` is the aligner, `scallop-1.0.20` is the assembler, and `cuffmerge-2.2.1` is the merge tool. 

  - `bedtool.sh` 
This script's mission is to convert the reference transcriptome into bed file and extract the exom=nic, intronic and intergenic regions in a `.bed` format to be used with the `analysis.sh` script

  - `analysis.sh`
This script is the final script that will operate all the analysis on the resulted `*merged.gtf` files. 
    - the for loop loops over the papers inside the `final_output` folder for each pipeline.
    - the first block in the loop excutes `gffcompare-0.10.1` generating a `.stats` files
    - the second block converts the `*merged.gtf` into `*merged.bed`
    - the `*merged.bed` is then passed to `bedtools-2.25.0` along with the `.bed` files from `bedtools` folder to generate the intersection between the resulted transcriptome and the different genomic data


