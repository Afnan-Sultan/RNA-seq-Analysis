#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=8,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N Star

module load GNU/4.9;
module load STAR/2.5.3a;

cd $PBS_O_WORKDIR

STAR --runThreadN 8 --genomeDir $index --readFilesIn $input1 $input2 --readFilesCommand zcat --outSAMattributes XS --outFileNamePrefix $output

qstat -f ${PBS_JOBID}

