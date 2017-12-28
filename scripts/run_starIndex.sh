#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=4,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N Star_index

module load GNU/4.9;
module load STAR/2.5.3a;

cd $PBS_O_WORKDIR

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles $genomeFastaFiles

qstat -f ${PBS_JOBID}

