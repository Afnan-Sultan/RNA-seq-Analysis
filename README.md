# motivation

  The study of transcriptome enables us to understand the functionality of the genome in different physiological conditions, development stages, and disease status [1]. Two widely used transriptome data come from poly(A) enriched libraries [16] or poly(A)- library which depends on depleting ribosomal RNA [4]. Both libraries are important in analyzing different functionality and to gain different insights about the cell. However, both libraries are usually assembled by the same RNA-seq assemblers even tho the two libraries exhibit huge content difference [4, 10, 11, 12] that might affect the assemblers'performance differently. Our suspison is that due to the higher content and difference of ribo-depleted libraries, and since most assemblers were designed to detect the most features of poly(A) libraries, the performance of the assemblers will be compromised for ribo-depleted libraries. This project designed different pipelines for assembling RNA-seq reads coming from both poly(A) and ribo-depleted libraries. We also used assemblers that were made to assemble RNA-seq reads either based on a reference or de novo. The results showed that performance of the assemblers on the same tissue but using different libraries were greatly negatively affected for ribo-depleted RNA-seq.     

# Materials and Methods

## Data

  A publicly available dataset [12] was used for the benchmarking analysis. The dataset is composed of paired-end poly(A) and ribo-depleted RNA-seq libraries for the same human tissues, including healthy brain tissues and tumor brain tissues. The reference genome (GRCh38) and transcriptome annotation files were obtained from GENCODE Release 27. 

## Reads download, quality assurance and data normalization

  The reads were downloaded using the sra-toolkit [18]. For each library preparation, reads coming from the same biological sample in all sequencing lanes were merged together, adapters were trimmed and low-quality reads were discarded using Trimomatic 0.36 [19]. The data was normalized to have equal number  of reads per both libraries. The bigger samples were subsampled randomly using seqtk [25].

## Transcriptome assembly using reference based pipeline

  Two pipelines were used: HISAT2 [5] - StringTie v1.3.4 [8] and STAR v2.5.3a [6] - Scallop [13]. The  aligners were fed with the reference genome to generate indexes, then each pair of the fastq paired reads were given to the aligner to output a sam file. Sam files were sorted and converted to bam files using samtools 1.6 [20]. The bam files were used as input to the assemblers. The assembly was done without reference transcriptome annotation guidance in order to assess the ability of these programs to assemble the correct transcriptome independently. The outputs GTF files of the HISAT-StringTie pipeline for each tissue type were merged into one gtf file using stringtie merge software. Cuffmerge from cufflinks 2.2.1 package [22] was used to do the same for the outputs GTF files of the STAR-Scallop pipeline. 

## Transcriptome assembly using De novo pipeline

  Trinity 2.5.1 was used for de novo assembly. The output fasta files were converted into GTF files using a pipeline of blat, pslToBed, bedToGenPred and GenPredToGTF tools from ucsclib [21]. Cuffmerge was used to merge the resulted GTF files for each tissue type.

## Benchmarking Analysis

  Sensitivity and specificity for the detection of transcriptomic features were calculated using gffcompare 0.10.1 [23]. Base pair intersection between the assembled transcriptomes and different genomic parts (intronic, exonic and intergenic) was done using bedtools [24]. Different between-group analysis was done using R.  

# Results

## Sensetivity and Specificity ##



This project is about analyzing different libraries of RNA-seq data and deriving differences between them using different pipelines. The purpose of this project is done by following the usual RNA-seq data analysis steps.
  - obtain the reads
  - apply quality control
  - map to reference
  - transcriptome assembly
  - analysis

The `main.sh` script is orchesterating the execution of these steps using the different scripts inside `scripts` folder. The work of `main.sh` and the susequent scripts could be easily summaraized as follows:

  - `main.sh` firstly generates some folders to stor the requiered data/programs at.
  - it would be convenient that `main.sh` will then call `required_downloads.sh` to excute that action. For `required_downloads.sh` itself, the work goes as follows
    - firstly, the script downloads and decompress the human geome. human transcriptome and genome sizes file.
    - the next step is downloading and istalling the required programms for downloading, quality control, aligning, assembeling and analyzing the RNA-seq reads.
  - `set_bath.sh` is then called to copy working bins, libs or any needed file to the PATH environment, to make work easier.
  - `main.sh` then generates the general structure for `data` folder, which primarily includes folders containing the accession lists for downloading the reads. The folder structure within `data` folder is as follows:
  
```
data
├── $paper_1 (the name of the paper where the data came from)
│   ├── acc_lists (different lists for different samples)
│   │   └── lists.txt (txt files containing accession numbers needed for downloawding reads)
│   ├── poly_A (liberary name; a folder to contain the poly_A reads)
│   │   ├── poly_tissueA (specific tissue reads from this library)
│   │   │   ├── fastq (fastq.gz files)
|   |   |   ├── merged_reads (the reads after merging the replicates)
│   │   │   └── trimmed_reads (the reads after applying quality controling upon)
│   │   ├── poly_tissueB 
│   │   ├── .
│   │   ├── .
│   │   └── poly_tissueX
│   └── ribo_depleted (liberary name; a folder to contain the ribo_depleted reads)
│       ├── ribo_tissueA (specific tissue reads from this library)
│       │   ├── fastq (fastq.gz files)
|   |   |   ├── merged_reads (the reads after merging the replicates)
│       │   └── trimmed_reads (the reads after applying quality controling upon)
│       ├── ribo_tissueB 
│       ├── .
│       ├── .
│       └── ribo_tissueX
├── .     
├── .     
└── $paper_n     
```
  - after downloading and refining the data, the mapping/assembeling takes place with two different pipelines by calling `hisat-stringtie.sh` and `star-scallop.sh` respectively.
    - the two pipelines run the mapping step using hisat/star which results in a `.sam` file
    - `.sam` files are then sorted and converted into `.bam` files
    - the `.bam` files are used by the assembeler -stringtie/scallop- to generate `.gtf` files
  - before calling the the pipeline scripts, a folder is created for each pipeline and the structure is perserved partially in both of them as the data folder.
  
```
hisat-stringtie(star-scallo)
├── $paper_1 
│   ├── poly_A 
│   │   ├── $sample_a 
│   │   │   └── reads (sam/bam/gtf)   
│   │   ├── $sample_b 
│   │   ├── .
│   │   ├── .
│   │   └──$sample_x
│   └── ribo_depleted 
│       ├── sample_a 
│       │   └── reads (sam/bam/gtf; the resulted output files from the mapper, samtools and the assembelet)
│       ├── $sample_b 
│       ├── .
│       ├── .
│       └──$sample_x
├── .     
├── .     
├── $paper_n 
└── final_output
    ├── $paper_1
    │   └── merged gtf, gffcompare output and bed files 
    ├── .     
    ├── .     
    └── $paper_n 
```
  - the additional folder in this structure is the `final_output` folder. This folder contains the final and most important outputs, which are mostly generated after calling `analysis.sh` script from the `main.sh`
  - `analysis.sh` function is
    - converting the merged `.gtf` file into `.bed` file
    - applying gffcompare on each merged gtf with refrence trancriptome and generating `.stats` files.
    - applying bedtools on the converted `.bed` file with the generated `.bed` files in the bedtools folder, to generate intersection with different genomic regions.

After calling the `analysis.sh` script, `main.sh` will be done and the general structure of the repository will be as follows.

```
RNA-seq-Analysis
├── data 
├── hg38_data
├── programs 
├── scripts
├── hisat-stringtie 
├── star-scallop
├── bedtools
├── main.sh
└── README.md 
```
