#!/bin/bash

for file in $(ls -a "$@"); do
	echo -n $(pwd)
	[[ $(pwd) != "/" ]] && echo -n /
	echo $file
done
