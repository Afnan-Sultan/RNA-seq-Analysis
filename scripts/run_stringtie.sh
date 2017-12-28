#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=4,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N StringTie

module load stringtie/1.3.3b

cd $PBS_O_WORKDIR

stringtie -o $output -l $label $bam

qstat -f ${PBS_JOBID}

