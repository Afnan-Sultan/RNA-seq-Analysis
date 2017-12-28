#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=8,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N hisat2

module load hisat2/2.1.0;

cd $PBS_O_WORKDIR

hisat2 -p 8 --dta -x $index -1 $input1 -2 $input2 -S $output;

qstat -f ${PBS_JOBID}

