#!/bin/bash

bed_files_dir="$1"

for EIJ in $bed_files_dir/*_junctions.bed; do
	temp=(echo "$(basename $EIJ)"
	EIj_info=${temp%_exon_intron_junctions.bed}
	for read in $bed_files_dir/*ToBed.bed; do
		temp=(echo "$(basename $be)"
		read_info=${temp%bamToBed.bed}
		if [[ $EIJ_info == $bed_info ]]; then
			cat $EIJ |
			while read line1; do
				EIJ_chr=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $1}')
				EIJ_start=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $2}')
				EIJ_end=$(echo $line1 | awk 'BEGIN{ FS="\t" }{print $3}')
				cat $read |
				while read line2; do
					read_chr=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $1}')
					read_start=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $2}')
					read_end=$(echo $line2 | awk 'BEGIN{ FS="\t" }{print $3}')
					if [[ $EIJ_chr == $read_chr ]]; then
						if [[ $EIJ_start -ge $read_start ]] && [[ $EIJ_end -le $read_end ]]; then
							echo $line2 >> $bed_files_dir/$EIJ_info"_EIJ_spanning_reads.bed"
						fi
					fi
				done
			done
		fi
	done
done