# Name: Get-Tail.ps1
# Author: William Stacey
# Created: 02/22/2007
# Description: Gets the last N lines of a file. Does scan from end-of-file so works on large files. Also has a loop flag that prompts for refresh.
 
function Get-Tail([string]$path = $(throw "Path name must be specified."), [int]$count = 10, [bool]$loop = $false)
{
	if ( $count -lt 1 ) {$(throw "Count must be greater than 1.")}
	function get-last
	{
		$lineCount = 0
		$reader = new-object -typename System.IO.StreamReader -argumentlist $path, $true
		[long]$pos = $reader.BaseStream.Length - 1
 
		while($pos -gt 0)
		{
			$reader.BaseStream.Position = $pos
			if ($reader.BaseStream.ReadByte() -eq 10)
			{
				if($pos -eq $reader.BaseStream.Length - 1)
				{
					$count++
				}
				$lineCount++
				if ($lineCount -ge $count) { break }
			}
			$pos--
		} 
		
		if ($lineCount -lt $count)
		{
			$reader.BaseStream.Position = 0
		}
		
		while($line = $reader.ReadLine())
		{
			$lines += ,$line
		}
		
		$reader.Close()
		$lines
	}
 
	while(1)
	{
		get-last
		if ( ! $loop ) { break }
		$in = read-host -prompt "Hit [Enter] to tail again or Ctrl-C to exit"
	}
}
