#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=4,mem=64Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N hisat_index

#module load GNU/4.9;
module load hisat2/2.1.0

cd $PBS_O_WORKDIR

hisat2-build -p 4 $genome $index

qstat -f ${PBS_JOBID}

