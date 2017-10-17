function Catch-LongNames
<#
.SYNOPSIS
This function stores the error from Get-ChildItem when it encounters files longer than the 260 Character Limit.
.DESCRIPTION
This function stores the error from Get-ChildItem when it encounters files longer than the 260 Character Limit.
This functin will produce a lot of error messages on the shell. This is normal behavior (After all, this funciton relies on there being errors. If you want to see them, comment out the $ErrorActionPreference = "SilentlyContinue"'.
.EXAMPLE
Catch-LongNames C:
Outputs an array of files that exceeded the character limit for Drive C:\.
.EXAMPLE
Catch-LongNames C: -Export
Outputs an array of files that exceeded the character limit for Drive C:\ and outputs them to a text file in the current PowerShell directory. .\
.EXAMPLE
Catch-LongNames C: -Find
Outputs an array of paths that contain files that exceed the character limit and an array of files in those paths that are the offenders. This switch uses CMD.exe and the creation of a text file. (Dir outputs even the files that are too long) Dir to a variable which is compared to a variable from the output of Get-ChildItem in the same directory. These two variables are then sent to Compare-Object.
.EXAMPLE
Catch-LongNames C: -Export -Find
Outputs an array of paths that contain files that exceed the character limit and an array of files in those paths that are the offenders. This switch uses CMD.exe and the creation of a text file. (Dir outputs even the files that are too long) Dir to a variable which is compared to a variable from the output of Get-ChildItem in the same directory. These two variables are then sent to Compare-Object. All of the output on the shell is also sent to two text files in $env:userprofile direcory, named LongPaths.txt and TooLongFiles.txt respectively.
.PARAMETERS
-Path
.Author
Mark R. Ince mrince@outlook.com
#>
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True,
		Position=0)]
		[string[]]$Path,
		[Parameter(Mandatory=$False)]
		[switch]
		$Export,
		[Parameter(Mandatory=$False)]
		[switch]
		$Find		
	)
	BEGIN
	{
		$old_ErrorActionPreference = $ErrorActionPreference #Stores original erroractionpreference
		$error.clear() #Clears any past errors
		$MaximumErrorCount = 500 #increases count from 256 to 500.
		$ErrorActionPreference = "SilentlyContinue" #Comment this out if you prefer to see the red text this function relies on to work.
	}
	PROCESS
	{
			Get-ChildItem -path $path -r * | Out-Null
			#The cmdlet that produces the error output that gets the full path. We don't actually want to see the output of this cmdlet, so it is piped to Out-Null.
	}
	END
	{
		$paths = ($error | Where-Object {$_.FullyQualifiedErrorId -match "DirIOError,Microsoft.PowerShell.Commands.GetChildItemCommand"} ) #Stores all the error messages that have a TargetObject
		ForEach ($item in $paths) #Runs through each instance from the Select-Object
		{
			[array]$longfiles += $item.TargetObject	#makes an array of all of the resulting long paths.
			If ($Export -eq $True)
			{
				$longfiles | Out-File "$env:userprofile\LongPaths.txt" -Append #Creates a text file in working PowerShell directory and appends each item to it.
			}			
		}

		If ($Find -eq $True)
		{
			ForEach ($resfile in $longfiles)
			{
				$Locate = $env:userprofile
				Set-Location $resfile				
				$check = cmd /C "dir /b ""$resfile"" /b"
				$validfiles = Get-ChildItem -r
				$toolong = (Compare-Object $validfiles $check).InputObject
				$files += $toolong
				Set-Location $Locate
			}
			If ($Export -eq $True)
			{
				$files | Out-File "$env:userprofile\TooLongFiles.txt"
			}
			$files
		}
		$longfiles #Writes the end array onto the shell				
		$ErrorActionPreference = $old_ErrorActionPreference #restores original erroractionpreference
	}
}
