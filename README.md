This project is about analyzing different libraries of RNA-seq data and deriving differences between them using different pipelines. The purpose of this project is done by following the usual RNA-seq data analysis.

    obtain the reads
    apply quality control
    map to reference
    transcriptome assembly
    analysis

The main.sh script is orchesterating the execution of these steps using the different scripts inside scripts folder. The work of main.sh and the susequent scripts could be easily summaraized as follows:

    main.sh firstly generates some folders to stor the requiered data/programs at.
    it would be convenient the main.sh will then call required_downloads to excute that action. For required_downloads itself, the work goes as follows
        firstly, the script downloads and decompress the human geome. human transcriptome and genome sizes file.
        the next step is downloading and istalling the required programms for downloading, quality control, aligning, assembeling and analyzing the RNA-seq reads.
    set_bath.sh is then called to copy working bins, ibs or any needed file to the PATH environment to make work easier.
    main.sh then generates the general structure for data folder, which primarily includes folders containing the accession lists for downloading the reads. The folder structure within data folder is as follows:

data
├── $paper_1 (the paper where the data came from)
│   ├── poly_A (a folder to contain the poly_A reads)
│   │   ├── acc_lists
│   │   │   └── lists.txt (txt files containing accession numbers needed for downloawding)
│   │   ├── $sample_a (specific tissue reads from this library)
│   │   │   ├── reads (fastq.gz files)
│   │   │   └── trimmed_reads (the reads after applying quality controling upon)
│   │   ├── $sample_b 
│   │   ├── .
│   │   ├── .
│   │   └──$sample_x
│   └── ribo_depleted (a folder to contain the ribo_depleted reads)
│       ├── sample_a (specific tissue reads from this library)
│       │   ├── reads (fastq.gz files)
│       │   └── trimmed_reads (the reads after applying quality controling upon)
│       ├── $sample_b 
│       ├── .
│       ├── .
│       └──$sample_x
├── .     
├── .     
└── $paper_n     

    after downloading and refining the data, the mapping/assembeling take place with two different pipelines by calling hisat-stringtie.sh and star-scallop.sh respectively.
        the two pipelines run the mapping step using hisat/star which results in a .sam file
        .sam files are then sorted and converted into .bam files
        the .bam files are used by the assembeler -stringtie/scallop- to generate .gtf files
    before calling the the pipeline scripts, a folder is created for each pipeline and the structure is perserved partially in both of them as the data folder.

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

    the additional fplder in this structure is the final_output folder. This folder contains the final and most important outputs, whic are mostly generated after calling analysis.sh script from the main.sh
    analysis.sh function is
        convert the merged .gtf file into .bed file
        applying gffcompare on each mergerd gtf with refrence trancriptom and generating stats files.
        applying bedtools on the converted .bed file with the generated .bed files in the bedtools folder to generate intersection with different with different genomic regions.

After calling the analysis.sh script, main.sh will be done and the general structure of the repository will be as follows.

RNA-seq-Analysis
├── data 
├── hg38_data
├── programs   
├── hisat-stringtie 
├── star-scallop
└── bedtools 

