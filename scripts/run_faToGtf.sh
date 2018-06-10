#!/bin/bash -login
#PBS -l walltime=120:00:00,nodes=1:ppn=1,mem=32Gb
#mdiag -A ged   
#PBS -m abe             
#PBS -N faToGtf

module load BLAT/36;
module load SeqClean/20130718
#module load ucscUtils/262;

cd $PBS_O_WORKDIR

mkdir -p $tissue_dir/$output.seqclean && cd $tissue_dir/$output.seqclean
seqclean $tissue_dir/$output.fasta
mv $output.fasta.clean $tissue_dir/.
cd $tissue_dir/

blat -t=dna -q=rna -fine $genome $output.fasta.clean $tissue_dir/$output.psl
pslToBed $tissue_dir/$output.psl $tissue_dir/$output.bed
#cp $tissue_dir/$output.bed $bed_files_dir/$tissue"_"$pipeline_name"_bamToBed.bed" #the name is for the sake of uniformity
bedToGenePred $tissue_dir/$output.bed $tissue_dir/$output.GenePred
genePredToGtf file $tissue_dir/$output.GenePred $tissue_dir/$output.gtf
#genePredToGtf $tissue_dir/$output.GenePred $merged_gtf_dir/$paper_name/$output.gtf

qstat -f ${PBS_JOBID}

