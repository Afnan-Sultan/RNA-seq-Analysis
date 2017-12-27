#!/bin/bash -login
#PBS -l walltime=04:00:00,nodes=1:ppn=1,mem=24Gb
#mdiag -A ged	
#PBS -m abe		
#PBS -N T_Trim	


module load Trimmomatic/0.33

cd $PBS_O_WORKDIR

java -jar $TRIM/trimmomatic PE -threads 1 -phred33 ${R1_INPUT} ${R2_INPUT} ${output_pe1} ${output_se1} ${output_pe2} ${output_se2} ILLUMINACLIP:$TRIM/adapters/TruSeq3-PE-2.fa:2:30:10:1 SLIDINGWINDOW:4:2 MINLEN:20


qstat -f ${PBS_JOBID}
