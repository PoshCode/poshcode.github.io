cd M:\Files\Netcasts\ShowName		# switch to the diretory to store your content
Import-Module BitsTransfer 			# enable BITS on host machine as a file transfer method
$start=47 					# start epidode number
$end=170 					# end epidode number
$url="http://download.domain.com/episodes/" # URL of the download up to the directory containing the content
$file_base="Podcast-" 			# this is the filename of the download without the show number
$file_ext=".ogg"
for($i=$start;$i -le $end;$i++)			# start the loop, and run until end of range, inclrementing by one
{
    $b="{0:D3}" -f $i 				# cast loop counter to a string, stored as a formated number with leading zeros, example 002
    $file="$file_base$b$file_ext" 		# Concatenatesthe file name with formated loop counter + file extension
    Start-BitsTransfer -source $url$file; 	# download trigger, 
}

