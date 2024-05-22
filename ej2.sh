#!/bin/bash

transfer () {
	local file=$1
	local dest=$2
	scp $file $dest &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo "Error en la transmisión del fichero: $file"
	fi
}

checkTranfer () {
	local file=$1
	local dest=$2
	local dir=$3
	local firma=$(md5sum $file | awk -F " " '{print $1}')
	ssh $dest "md5sum $dir/$file" 2>/dev/null | grep -q firma
	if [[ $? -eq 0 ]]; then
		transfer $file $dest
	fi
}

main () {
	local user=$(echo "$1" | awk -F "@" '{print $1}')
	local dest=$(echo "$1" | awk -F "@" '{print $2}')
	local dir=$2
	for i in 3..$#; do
		if [[ -d $i ]]; then
			for files in $i/*; do 
				if [[ -f $files ]]; then
					checkTransfer $files $dest $dir
				fi
			done
		elif [[ -f $i ]]; then
			checkTransfer $i $dest $dir
		fi
	done
}
main
