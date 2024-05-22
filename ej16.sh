#!/bin/bash

mostrarResultado(){
	file=$1
	nline=$2
	content=$(awk '{ if (length > L) {L=length; S=$0 } }END {print S}' $file)
	echo "$file    $nline    $content"
}

max=0
maxfile=""

for files in "$@"; do
	#files=$(awk -F " " '{print $i}' $@)
	if [[ -f $files && -r $files ]]; then
		numchar=$(awk '{ if (length > L) {L=length }} END { print L}' $files)
		if [[ $max < $numchar ]]; then 
			max=$numchar
			maxfile=$files	
		fi
	fi
done

mostrarResultado $maxfile $max

exit 0
