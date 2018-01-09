#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=1,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N scallop

module swap GNU GNU/4.9
module load scallop/0.10.2

cd $PBS_O_WORKDIR

scallop -i $bam -o $output

qstat -f ${PBS_JOBID}

