#!/bin/bash

pipeline_dir="$1"                   
single_gtf_dir="$2"
index_dir_path="$3"
paper_dir="$4"
paper_name=$(echo "$(basename $gtf_dir)") 

for lib_dir in $pipeline_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
       ## loop over tissues
       for tissue_dir in $lib_dir/*; do
           echo $tissue_dir
           tissue_name=$(echo "$(basename $tissue_dir)")
           if [ -d $tissue_dir ]; then
		mkdir -p $single_gtf_dir/$paper_name/gffCompare 
		for gtf in $tissue_dir/*.gtf; do
			gff_output_prefix=$(echo "$(basename $gtf)"| sed s/.gtf//)
    			gffcompare -r $index_dir_path/gencode.v27.primary_assembly.annotation.gtf -o $single_gtf_dir/$paper_name/gffCompare/$gff_output_prefix $gtf
		done
	    fi
	done
     fi
done
