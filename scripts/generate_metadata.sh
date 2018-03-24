#!/bin/bash

#temporary explanation. 
#This code utilized the data inside SraRunTable file to generate metadata incluing read id, liberary id and read length. 
#The aim is to organize liberaries per size to help us in the random sampling step. So, we need the libraris per tissue to be sorted to be utilize its data with the other lib
#The code works as follows: 
#1- it loops over the downloaded reads at each libper tissue in a time. 
#2- each read is matched to it's line in the SraRunTable, then lib id is extracte along with read length
#3- lib id is stored as key in associative array, while the value is the length of the current read.
#4- each time a new lib id inroduced, it's aded as key, and if it's already a key, it's value increases by the length of the current read.
#5- at the end of eah loop, we end up with 4 libraries with their total lenght. 
#6- the libraries are then sorted and stored in a list.
#7- this list is now used to export the data we need. when each lib is called, all it's corresponding lines in the SraRunTable file are identified and stored in another file.
#8- the data in the new file will be sorted by library size.
#9- finally, the two files of the same tissue are merged in onw file side by sde for further usage. 



paper_dir="$1"

for lib_dir in $paper_dir/* ; do
	lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
		reads_len=$(
		for tissue_dir in $lib_dir/*; do
			#echo $tissue_dir
		    tissue_name=$(echo "$(basename $tissue_dir)")
		    #echo $tissue_name
			for read in $tissue_dir/fastq/*_1.fastq.gz; do
			   temp=$(echo "$(basename $read)")
			   read_name=${temp%_1.fastq.gz}
			   read_lines_len=$(zcat $read | wc -l)
			   read_len=$(($read_lines_len/4))
			   echo 
			   echo $lib_name/$tissue_name','$read_name','$read_len #>> $paper_dir/$tissue_name"_unsorted.txt"
			done
		 done)
     fi
	 #echo $reads_len
done 

for lib_dir in $paper_dir/* ; do
	lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then	
		for tissue_dir in $lib_dir/*; do
			tissue_name=$(echo "$(basename $tissue_dir)")
			declare -A libs_len
			echo 'array declared'
			#echo "${!libs_len[@]}" "${libs_len[@]}"
			for line1 in $reads_len; do
				#echo "${!libs_len[@]}" "${libs_len[@]}"
				read_name=$(echo $line1 | awk 'BEGIN{FS=",";} {print $2}')
				read_len=$(echo $line1 | awk 'BEGIN{FS=",";} {print $3}')
				#echo $read_name $read_len 
				cat $paper_dir/acc_lists/SraRunTable.txt|
				while read line2; do
					#echo "${!libs_len[@]}" "${libs_len[@]}"
					lib_id=$(echo $line2 | awk 'BEGIN{FS=",";} {print $12}')
				 	read_id=$(echo $line2 | awk 'BEGIN{FS=",";} {print $11}')
					#echo $lib_id 
					#echo "${libs_len[@]}"
				 	if [[ $read_id == $read_name ]]; then
						echo "inside if"
						echo $line1",$lib_id" >> $paper_dir/$tissue_name"_unsorted.txt"
						if [[ ${libs_len[$lib_id]+isset} ]]; then
				   			echo "inside second if"
				   			libs_len[$lib_id]=$((${libs_len[$lib_id]}+$read_len))
							#echo "${libs_len[@]}"
						else
				   			echo "inside else"
				   			libs_len[$lib_id]=$read_len
							echo "${!libs_len[@]}" "${libs_len[@]}"
						fi
						break
				 	fi
				 done
			done
			echo "${libs_len[@]}"
			sorted_lib_IDs=$(
            for lib in "${!libs_len[@]}"; do
				echo $lib ',' ${libs_len["$lib"]}
			done | sort -n -k3 | sed 's/,.*//') 
	    	echo "sorted libs" $sorted_lib_IDs
	    	for lib in $sorted_lib_IDs; do
				cat $paper_dir/$tissue_name"_unsorted.txt"|
				while read line; do
					lib_id=$(echo $line | awk 'BEGIN{FS=",";} {print $4}')
					if [ $lib == $lib_id ]; then
						echo $line >> $paper_dir/$tissue_name"sorted.txt"
					fi
				done
				end=$(cat $paper_dir/$tissue_name"sorted.txt" | wc -l)
				for i in $(seq 0 8 $end); do
					echo 'x' | ex -s -c 'i,$((i+8))!sort -k3 -n' $paper_dir/$tissue_name"sorted.txt"
				done	
			done
		done 
	fi
done 
#merging poly and ribo liberaries from the same tissue in one file for easier comparison later.
for txt in $paper_name/poly*; do
	if [ $txt == *_sorted.txt ]; then
		file1=$(echo "$(basename $txt)")
		out=$(echo $file1 | sed 's/poly_//')
		if [[ txt == poly_brain.txt ]]; then
		   file2=ribo_brain.tx
		else
		   file2=ribo_tumor.txt
		fi
		paste -d "," $paper_dir/file1 $paper_dir/file2 > $paper_dir/metadata"_$out"
	fi
done  

