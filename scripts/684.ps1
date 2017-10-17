# Author: Steven Murawski http://www.mindofroot.com
# This script requires the Show-NetMap script from Doug Finke and the NetMap files 
# These can be found at http://dougfinke.com/blog/?p=465
# 
# Also required are the Quest AD Cmdlets.

#requires -pssnapin Quest.ActiveRoles.ADManagement

param([string]$SearchRoot= 'yourdomain.local/usersOU')

Function New-SourceTarget ($s,$t) {
	New-Object PSObject |
		Add-Member -pass noteproperty source $s |
		Add-Member -pass noteproperty target $t
}

$groups = Get-QADGroup -GroupType Security -SearchRoot $SearchRoot

[string[]]$GroupNames = $groups | foreach {$_.name}

$sources = @()

foreach ($group in $groups)
{
	$name = $group.name
	foreach ($member in $group.members)
	{
		$SubGroupName = $member -replace '^CN=(.+?),OU=.*', '$1'
		if ($GroupNames -contains $SubGroupName)
		{
			$sources += New-SourceTarget $SubGroupName $name
		}
	}
	
}

. c:\scripts\powershell\Show-NetMap

$sources | Show-NetMap
