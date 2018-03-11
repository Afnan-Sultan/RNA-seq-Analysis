#!/bin/bash

paper_dir="$1"

for lib_dir in $paper_dir/* ; do
    lib_name=$(echo "$(basename $lib_dir)")
    if [[ -d $lib_dir && ($lib_name == poly* || $lib_name == ribo*) ]]; then
       for tissue_dir in $lib_dir/*; do
           echo $tissue_dir
           tissue_name=$(echo "$(basename $tissue_dir)")
           echo $tissue_name

	   #sorting the libraries ascending by length 
	   for read in $tissue_dir/fastq/*_1.fastq.gz; do
	       temp=$(echo "$(basename $read)")
	       read_name=${temp%_1.fastq.gz}

	       #creating associative array to store the library ID as key, and the length as value
	       declare -A libs_num
               cat $paper_dir/acc_lists/SraRunTable.txt |
	       while read line; do 
	             lib_id=$(echo $line | awk 'BEGIN{FS=",";} {print $12}')
		     read_id=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
	             read_lines_len=$(zcat $read | wc -l)
		     read_len=$(($read_lines_len/4))     		#as each spot is reported in 4 lines

		     #incrementing the liberary value by the read length associated with it
		     if [[ $read_id == $read_name ]]; then
			if [[ ${libs_len[lib_id]+isset} ]]; then
			   libs_len[lib_id]=$((${libs_len[lib_id]}+$read_len))
			else
			   libs_len[lib_id]=$read_len
			fi
		     fi
	       done
	    done

	    #sort the library IDs by their values and store them in a list
	    sorted_lib_IDs=$(
            for lib in "${!libs_len[@]}"; do
		echo $lib ',' ${libs_len["$lib"]}
		done | sort -n -k3 | sed 's/,.*//') 

	    #writting the requiered fields in the metada file for each tissue 
	    for lib in $sorted_lib_IDs; do
    		cat $paper_dir/acc_lists/SraRunTable.txt |
	        while read line; do
                      lib_id=$(echo $line | awk 'BEGIN{FS=",";} {print $12}') 
                      if [[ $lib == $lib_id ]]; then
			 read_id=$(echo $line | awk 'BEGIN{FS=",";} {print $11}')
	             	 read_lines_len=$(zcat $read | wc -l)
		     	 read_len=$((rea_len/4))
			 echo $tissue_name','$lib_id','$read_id','$read_len >> $paper_dir/$tissue_name".txt"
		      fi
		done
	    done	
       done
    fi
done

#merging poly and ribo liberaries from the same tissue in one file for easier comparison later.
for txt in $paper_name/poly*; do
    file1=$(echo "$(basename $txt)")
    out=$(echo $file1 | sed 's/poly_//')
    if [[ txt == poly_brain.txt ]]; then
       file2=ribo_brain.tx
    else
       file2=ribo_tumor.txt
    paste -d "," $paper_dir/file1 $paper_dir/file2 > $paper_dir/metadata"_$out"
    fi
done 
