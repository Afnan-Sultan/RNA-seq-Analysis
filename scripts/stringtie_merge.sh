#!/bin/bash

tissue_dir="$1"
paper_dir="$2"


stringtieMerge_output=$(echo "$(basename $tissue_dir"_stringtie_merged.gtf")")
stringtie --merge $tissue_dir/*.gtf -o $paper_dir/$stringtieMerge_output
