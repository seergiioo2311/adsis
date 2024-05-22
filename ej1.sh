#!/bin/bash

main () {
	local processes=$(ps ax -o etimes,pid,comm | tail -n +2)
	while read -r line; do
		local pid=$(echo "$line" | awk -F " " '{print $2}')
		local time=$(echo "$line" | awk -F " " '{print $1}')
		if [[ time -lt 86400 ]]; then
			echo "kill -9 $pid"
		fi
	done <<< "$processes"
}
main
