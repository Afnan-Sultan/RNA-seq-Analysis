#!/bin/bash

#copying the code file -that will download the reads and convert them into fastq- to the PATH
sudo cp /home/$username/sratoolkit.2.8.2-1-ubuntu64/bin/fastq-dump /usr/bin/

#copying samtools, Hisat, Stringtie & gffcompare to $PATH
sudo cp $work_dir/programs_WorkDir/samtools-01.6/samtools /usr/bin
sudo cp $work_dir/programs_WorkDir/hisat2/hisat2* hisat2/*.py /usr/bin
sudo cp $work_dir/programs_WorkDir/stringtie/stringtie /usr/bin
sudo cp $work_dir/programs_WorkDir/gffcompare/gffcompare /usr/bin

#copying STAR and scallop to $PATH
sudo cp $work_dir/programs_WorkDir/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin/
sudo cp $work_dir/programs_WorkDir/scallop/src/scallop /usr/bin/


