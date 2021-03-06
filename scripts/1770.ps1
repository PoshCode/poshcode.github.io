# new version avoids recalculating MD5s, has delete/noprompt options, and by default checks the current directory.

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

$matches = 0     	# initialize number of matches for summary.
$filesdeleted = 0 	# number of files deleted.
$bytesrec = 0 		# Number of bytes recovered.
$files=@()
$del = $false 		# delete duplicates
$noprompt = $false  	# delete without prompting toggle
$currentdir = $true 	# work on current directory by default

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
			$files+=(dir $args[$i] -recurse | ? {$_.psiscontainer -ne $true})
			$currentdir=$false
		} 
	} 
}

if ($currentdir -eq $true) { $files=(dir -recurse | ? {$_.psiscontainer -ne $true})}

if ($files -eq $null) {write-host "No files found."; exit}

for ($i=0;$i -ne $files.count; $i++)  # Cycle thru all files
{
	if ($files[$i] -eq $null) {continue}
	$filecheck = $files[$i]
	$files[$i] = $null	
	for ($c=0;$c -ne $files.count; $c++)
	{
		if ($files[$c] -eq $null) {continue}
#		write-host "Comparing $filecheck and $($files[$c])     `r" -nonewline
	
		if ($filecheck.length -eq $files[$c].length)
		{
			#write-host "Comparing MD5 of $($filecheck.fullname) and $($files[$c].fullname)     `r" -nonewline	

			if ($filecheck.md5 -eq $null) 
			{ 
				$md5 = (get-md5 $filecheck.fullname)
				$filecheck = $filecheck | %{add-member -inputobject $_ -name MD5 -membertype noteproperty -value $md5 -passthru}			
			}
			if ($files[$c].md5 -eq $null) 
			{ 
				$md5 = (get-md5 $files[$c].fullname)
				$files[$c] = $files[$c] | %{add-member -inputobject $_ -name MD5 -membertype noteproperty -value $md5 -passthru}				
			}
			
			if ($filecheck.md5 -eq $files[$c].md5) 
			{
				
				write-host "Size and MD5 match: " -fore red -nonewline
				write-host "`"$($filecheck.fullname)`"" -nonewline
				write-host " and " -nonewline
				write-host "`"$($files[$c].fullname)`""
				$matches++
				
				if ($del -eq $true)
				{
					if ($noprompt -eq $true)
					{
						del $files[$c].fullname
						write-host "Deleted duplicate: " -f red -nonewline
						write-host "$($files[$c].fullname)."
					}
					else
					{
						del $files[$c].fullname -confirm
					}
					if ((get-item -ea 0 $files[$c].fullname) -eq $null)
					{
						$filesdeleted += 1
						$bytesrec += $files[$c].length
					}

				}
	
				$files[$c] = $null
			}
		}
	}
}
write-host ""
write-host "Number of Files checked: $($files.count)."	# Display useful info; files checked and matches found.
write-host "Number of matches found: $matches."
Write-host "Number of duplicates deleted: $filesdeleted." # Display number of duplicate files deleted and bytes recovered.
write-host "$bytesrec bytes recovered."	
write-host ""
