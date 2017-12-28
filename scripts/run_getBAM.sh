#!/bin/bash -login
#PBS -l walltime=02:00:00,nodes=1:ppn=4,mem=32Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N getBAM

module load SAMTools/1.2

cd $PBS_O_WORKDIR

samtools view -u -@ 4 -o $label.bam $label.sam
samtools sort -@ 4 -O bam -T $label -o $label.sorted.bam $label.bam

qstat -f ${PBS_JOBID}

