[CmdletBinding()]
PARAM (
	[Parameter(Mandatory=$true,HelpMessage="The filter to use for checking paths")]
	[ValidateNotNullOrEmpty()]
	$Filter
)

Import-Module ActiveDirectory

Get-ADUser -Filter $Filter -Properties ProfilePath | ForEach-Object {
    
    	try
	{
		$tsPath = $null
		$adsiObject = [ADSI]('LDAP://{0}' -f $_.DistinguishedName)
		$tsPath = $adsiObject.InvokeGet("TerminalServicesProfilePath")
    	}
    	catch
	{
    	}

	$newObject = New-Object PSObject -Property @{
		Username=$_.sAMAccountName
       		DistinguishedName=$_.DistinguishedName;
		TerminalServicesProfilePath=$tsPath
		ProfilePath=$_.ProfilePath
	}

	Write-Output $newObject
}

