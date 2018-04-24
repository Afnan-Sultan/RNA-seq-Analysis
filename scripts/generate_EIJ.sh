#!/bin/bash

bed_files_dir="$1"
paper_dir="$2"
paper_name=$(echo "$(basename $paper_dir)"

for bed in $bed_files_dir/$paper_name/*_intrsect_introns.bed; do
	temp=$(echo "$(basename $bed)")
	bed_name=${temp%_merged_intersect_introns.bed}
	cat $bed |
	while read line1; do
		intron_chr=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $1}')
		intron_start=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $2}')
		intron_end=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $3}')
		cat $bed_files_dir/hg38_exons.bed |
		while read line2; do
			exon_chr=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $1}')
			exon_start=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $2}')
			exon_end=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $3}')
			if [[ intron_chr == exon_chr ]]; then
				if [[ intron_start == exon_end ]]; then
					echo intron_chr"\t"$(($intron_start-50))"\t"$(($intron_start+50)) >> $bed_files_dir/$bed_name"_exon_intron_junctions.bed"
				elif [[ merged_intersect_introns.bed ]]; then
					echo -e intron_chr"\t"$(($intron_end-50))"\t"$(($intron_end+50)) >> $bed_files_dir/$bed_name"_exon_intron_junctions.bed"
				fi
			fi
		done
	done
done