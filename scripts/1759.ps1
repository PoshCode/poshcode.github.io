function Get-MD5([System.IO.FileInfo] $file = $(throw 'Usage: Get-MD5 [System.IO.FileInfo]'))

{
  	$stream = $null;
  	$cryptoServiceProvider = [System.Security.Cryptography.MD5CryptoServiceProvider];
  	$hashAlgorithm = new-object $cryptoServiceProvider
  	$stream = $file.OpenRead();
  	$hashByteArray = $hashAlgorithm.ComputeHash($stream);
  	$stream.Close();

  	## We have to be sure that we close the file stream if any exceptions are thrown.

  	trap
  	{
   		if ($stream -ne $null)
    		{
			$stream.Close();
		}
  		break;
	}	

 	foreach ($byte in $hashByteArray) { if ($byte -lt 16) {$result += “0{0:X}” -f $byte } else { $result += “{0:X}” -f $byte }}
	return [string]$result;
}

write-host "Usage: finddupe.ps1 <directory/file #1> <directory/file #2> ... <directory/file #N> [-delete] [-noprompt]"

$matches = 0     # initialize number of matches for summary.

$files=$null

$del = $false # delete duplicates

$noprompt = $false  # delete without prompting toggle

for ($i=0;$i -ne $args.count; $i++) 
{ 
	if ($args[$i] -eq "-delete") 
	{
		$del=$true;continue
	} 
	else 
	{ 
		if ($args[$i] -eq "-noprompt") 
		{ 
			$noprompt=$true;continue
		} 
		else 
		{ 
			write-host $args[$i];$files+=(dir $args[$i] -recurse | ? {$_.psiscontainer -ne $true})
		} 
	} 
}

if ($files -eq $null) {write-host "No files found." -f red; exit}

$files | % {$_.fullname}

write-host "delete=$del; noprompt=$noprompt"

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
				
				write-host "Size and MD5 match: " -fore red -nonewline
				"{0} and {1}" -f $filecheck.fullname, $files[$c].fullname
				$matches++
				
				if ($del -eq $true)
				{
					if ($noprompt -eq $true)
					{
						del $files[$c].fullname;write-host "$($files[$c].fullname) deleted." -f Red
					}
					else
					{
						del $files[$c].fullname -confirm
					}
				}
	
				$files[$c] = $null
			}
		}
	}
}
write-host ""
write-host "Number of Files checked: $($files.count)."	# Display useful info; files checked and matches found.
write-host "Number of matches found: $($matches)."
write-host ""
