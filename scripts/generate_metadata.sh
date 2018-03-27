#!/bin/bash

paper_dir="$1"

cat $paper_dir/acc_lists/SraRunTable.txt|
while read line; do
	read_id=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
	exp_id=$(echo $line | awk 'BEGIN{FS=",";} {print $12}')
	lib_prep=$(echo $line | awk 'BEGIN{FS=",";} {print $16}')
	echo $lib_prep
	if [[ $lib_prep == ABRF-ILMN-RIBO-A ]]; then
		lib_name=ribo_depleted
		tissue_name=ribo_tumor
	elif [[ $lib_prep == ABRF-ILMN-RIBO-B ]]; then
		lib_name=ribo_depleted
		tissue_name=ribo_brain
	elif [[ $lib_prep == ABRF-ILMN-RNA-A ]]; then
		lib_name=poly_A
		tissue_name=poly_tumor
	elif [[ $lib_prep == ABRF-ILMN-RNA-B ]]; then
		lib_name=poly_A
		tissue_name=poly_brain
	fi
	read=$paper_dir/$lib_name/$tissue_name/fastq/$read_id"_1.fastq.gz"
	read_lines_len=$(zcat $read | wc -l)
	read_len=$(($read_lines_len/4))
	echo $lib_name,$tissue_name,$exp_id,$read_id,$read_len >> $paper_dir/metadata_unsorted.txt
done
				 	
cat $paper_dir/metadata_unsorted.txt | awk -F ',' '{A[$1" "$2" "$3]+=$5}END{for(i in A)print i,A[i]}' | sort -k1,1r -k2,2 -k4,4nr | awk '{print $3}' > $paper_dir/sorted_exp
while read exp;do grep -w $exp $paper_dir/metadata_unsorted.txt;done < $paper_dir/sorted_exp > $paper_dir/metadata_sorted.txt
cat $paper_dir/metadata_sorted.txt | pr -2 -t -s"," > $paper_dir/metadata.txt



