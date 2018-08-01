param($dir = '.')

$matches = 0     # initialize number of matches for summary.

$files = (dir $dir -recurse | ? {$_.psiscontainer -ne $true})

for ($i=0;$i -ne $files.count; $i++)  # Cycle thru all files
{
	if ($files[$i] -eq $null) {continue}
	$md5 = $null
	$filecheck = $files[$i]
	$files[$i] = $null	
	for ($c=0;$c -ne $files.count; $c++)
	{
		if ($files[$c] -eq $null) {continue}
#		write-host "Comparing $filecheck and $($files[$c])     `r" -nonewline
	
		if ($filecheck.length -eq $files[$c].length)
		{
			#write-host "Comparing MD5 of $($filecheck.fullname) and $($files[$c].fullname)     `r" -nonewline	

			if ($md5 -eq $null) {$md5 = (get-md5 $filecheck)}

			if ($md5 -eq (get-md5 $files[$c]))
			{
				"Size and MD5 match: {0} and {1}" -f $filecheck.fullname, $files[$c].fullname
				$matches++
				$files[$c] = $null
			}
		}
	}
}
write-host ""
write-host "Number of Files checked: $($files.count)."	# Display useful info; files checked and matches found.
write-host "Number of matches found: $($matches)."
write-host ""
