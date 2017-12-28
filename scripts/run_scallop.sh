#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=4,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N scallop

module load scallop

cd $PBS_O_WORKDIR

scallop -i $bam -o $output

qstat -f ${PBS_JOBID}

