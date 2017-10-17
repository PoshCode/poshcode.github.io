function get-IsWritable(){
<#
    .Synopsis
        Command tests if a file is present and writable.
    .Description
        Command to test if a file is writeable. Returns true if file can be opened for write access.
    .Example
        get-IsWritable -path $foo
		Test if file $foo is accesible for write access.
	.Example
        $bar | get-IsWriteable
		Test if each file object in $bar is accesible for write access.
	.Parameter Path
        Psobject containing the path or object of the file to test for write access.
#>
	[CmdletBinding()]
	param([Parameter(Mandatory=$true,ValueFromPipeline=$true)][psobject]$path)
	
	process{
		Write-Verbose "Test if file $path is writeable"
		if (Test-Path -Path $path -PathType Leaf){
			Write-Verbose "File is present"
			$target = Get-Item $path -Force
			Write-Verbose "File is readable"
			try{
				Write-Verbose "Trying to openwrite"	
				$writestream = $target.Openwrite()
				Write-Verbose "Openwrite succeded"	
				$writestream.Close() | Out-Null
				Write-Verbose "Closing file"				
				Remove-Variable -Name writestream
				Write-Verbose "File is writable"
				Write-Output $true
				}
			catch{
				Write-Verbose "Openwrite failed"
				Write-Verbose "File is not writable"
				Write-Output $false
				}
			Write-Verbose "Tidying up"
			Remove-Variable -Name target
		}
		else{
			Write-Verbose "File $path does not exist or is a directory"
			Write-Output $false
		}
	}
}
