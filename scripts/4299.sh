#!/bin/bash
clear	# clear terminal window
read -p "CSCI212Shell$ " input

case "$input" in
	"exit" )
		exit 1 ;;
	'cd' )
		cd ;;
	'cd '* )
		$input ;;
	"jobs" )
		ps ;;
	* )
		array=$(echo $input | tr " " "\t")
	
		#for argument in $array
		#do
		#	echo "[$argument]"
		#done	
			
			$input & pid_child=$! 
			wait $pid_child ;;
			#bash $0 ;;
esac
