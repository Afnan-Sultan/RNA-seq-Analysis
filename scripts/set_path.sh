#!/bin/bash
work_dir="$1"

#copying the code file -that will download the reads and convert them into fastq- to the PATH
sudo cp $work_dir/programs/sratoolkit.2.8.2-1-ubuntu64/bin/fastq-dump /usr/bin/

#copy seqtk to PATH
sudo cp work_dir/programs/seqtk/seqtk /usr/bin

#copying samtools, Hisat, Stringtie & gffcompare to $PATH
sudo cp $work_dir/programs/samtools-01.6/samtools /usr/bin
sudo cp $work_dir/programs/hisat2/hisat2* hisat2/*.py /usr/bin
sudo cp $work_dir/programs/stringtie/stringtie /usr/bin
sudo cp $work_dir/programs/gffcompare/gffcompare /usr/bin

#copying STAR and scallop to $PATH
sudo cp $work_dir/programs/STAR-2.5.3a/bin/Linux_x86_64/STAR /usr/bin/
sudo cp $work_dir/programs/scallop/src/scallop /usr/bin/

#copy blat and other bnaries to path 
sudo cp $work_dir/programs/ucscLib/blat /usr/bin/
sudo cp $work_dir/programs/ucscLib/pslToBed /usr/bin/
sudo cp $work_dir/programs/ucscLib/bedToGenePred /usr/bin/
sudo cp $work_dir/programs/ucscLib/genePredToGtf /usr/bin/


