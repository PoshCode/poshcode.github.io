param ( $Credential, $ComputerName )

# The official way to detect .NET versions is to look at their known location on the hard drive as per
# this article: http://msdn.microsoft.com/en-us/kb/kb00318785.aspx

# thanks to David M (http://twitter.com/makovec) for the WQL 
$query = "select name from win32_directory where name like 'c:\\windows\\microsoft.net\\framework\\v%'"

$res = Get-WmiObject -query $query -Credential $Credential -ComputerName $ComputerName | ForEach-Object {
	Split-Path $_.name -Leaf } | # returns directories
		Where-Object { $_ -like 'v*' } | # only include those that start with v
			ForEach-Object { [system.version]( $_ -replace "^v" ) } # remove "v" from the string and convert to version object

# Create hashtable with computername and version details
$prop = @{
	ComputerName	= $ComputerName
	V1Present		= &{ if ( $res | Where-Object { $_.Major -eq 1 -and $_.Minor -eq 0 } ) { $true } }
	V1_1Present		= &{ if ( $res | Where-Object { $_.Major -eq 1 -and $_.Minor -eq 1 } ) { $true } }
	V2Present		= &{ if ( $res | Where-Object { $_.Major -eq 2 -and $_.Minor -eq 0 } ) { $true } }
	V3_5Present		= &{ if ( $res | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 } ) { $true } }
	VersionDetails	= $res
}

# Create and output PSobject using hashtable
New-Object PSObject -Property $prop
