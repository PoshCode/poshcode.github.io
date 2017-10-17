# Author: Steven Murawski http://www.mindofroot.com
# This script requires the Show-NetMap script from Doug Finke and the NetMap files
# These can be found at http://dougfinke.com/blog/?p=465
#
# Also required are the Quest AD Cmdlets.

#requires -pssnapin Quest.ActiveRoles.ADManagement



function Write-Help()
{
	$ExampleUsage = @'
To use this script, you will need the Show-Netmap script from Doug Finke,
along with the NetMap DLLs (included with the Show-NetMap script on Doug's blog).
Downloadable from http://dougfinke.com/blog/?p=465

Usage:
. .\Get-ADMapObject.ps1
Get-ADMapObject ([Object Class Name] | [Array of Object Class Names]) | % { New-SourceTarget $_.Name $_.Parent } | Show-NetMap


Example:
. .\Get-ADMapObject.ps1
Get-ADMapObject group | % { New-SourceTarget $_.Name $_.Parent } | Show-NetMap -layoutType G
Get-ADMapObject ou, group, user | % { New-SourceTarget $_.Name $_.Parent } | Show-NetMap -layoutType S

If you would like to get a listing (or array) of the Object Class Names, use the Get-ADObjectClassName function

$classes = Get-ADObjectClassName

'@
	Write-Host $ExampleUsage
}

#Check to see if the required files are present to run the script.
function Test-Prerequisites()
{
	$required = @{ShowNetMap = 'Show-Netmap.ps1';
		NetMapApp = 'Microsoft.NetMap.ApplicationUtil.dll';
		NetMapControl = 'Microsoft.NetMap.Control.dll';
		NetMapCore =  'Microsoft.NetMap.Core.dll';
		NetMapUtil =  'Microsoft.NetMap.Util.dll';
		NetMapVisual =  'Microsoft.NetMap.Visualization.dll'
		}
		
	$report = @()
	
	foreach ($key in $required.Keys)
	{
		$file = $required[$($key)]
		if (Test-Path $file )
		{
			Write-Debug "Found $file"
		}
		else
		{
			$report +=  "Missing $file"
		}
		
	}
	
	if ($report.count -eq 0)
	{
		Write-Debug "All prerequisites were found."
		return $true
	}
	else
	{
		Write-Help
		Write-Host "Missing files: "
		$report | ForEach-Object { Write-Host "`tMissing $_" }
		throw "Please move the needed files into the current directory!"
	}


}

#If all the prereq's are in the local directory and the script was not run
#with the -help switch, load everything up!
if (Test-Prerequisites)
{
	#Add the Show-Netmap functions from Doug Finke
	. .\Show-NetMap.ps1
	
	#This is just a helper function to find the parent of an object based on the parent's distinguished name
	function Get-ParentFromDN()
	{
		PROCESS
		{
			$root = '^DC=(\w+),DC=(\w+)$'
			$pattern = '^(OU|CN)=(\w+?),.*?DC=\w+?,DC=\w+?$'
			$dn = $_
			
			
			if ($dn -notmatch $root)
			{
				$dn -replace $pattern, '$2'
			}
			else
			{
				$dn -replace $root, '$1.$2'
			}
		}
	}
	
	#This will return an array of all the Object Classes in your Active Directory
	function Get-ADObjectClassName()
	{
		Get-QADObject | Select-Object -property @{name='Name';Expression={$_.type}} -unique | Sort-Object
	}
	
	function Get-ADMapObject()
	{
		param($TypesToMap=$(Throw 'One (or more object types as an array) are required to run this function'), 
		[switch]$help)
		if ($help)
		{
			Write-Help 
		}
		
		if ($TypesToMap -is [string])
		{
			Get-QADObject -Type $TypesToMap | select Name, @{name='Parent';Expression={$_.ParentContainerDN | Get-ParentFromDN}}
		}
		else
		{
			foreach ( $type in $TypesToMap )
			{
				Get-QADObject -Type $type | select Name, @{name='Parent';Expression={$_.ParentContainerDN | Get-ParentFromDN}}
			}
		}
	}
	
	#Helper function stolen from Doug Finke and used to create the objects to feed to 
	#Show-Netmap
	function New-SourceTarget ($s,$t) 
	{
		New-Object PSObject |
			Add-Member -pass noteproperty source $s |
			Add-Member -pass noteproperty target $t
	}
	
}

Write-Help
