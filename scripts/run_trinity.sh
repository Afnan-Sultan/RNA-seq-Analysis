#!/bin/bash -login
#PBS -l walltime=7:00:00:00,nodes=1:ppn=6,mem=128Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N trinity

module swap GNU GNU/4.9
module load trinity/2.4.0

cd $PBS_O_WORKDIR

Trinity --seqType fq --max_memory 120G --CPU 6 --output $output --left $input1 --right $input2 --SS_lib_type RF

outputName=$(echo "$(basename $input1)" | sed s/_1*.fastq.gz/.fasta/)
cp $output/Trinity.fasta $(dirname $output)/$outputName

qstat -f ${PBS_JOBID}

