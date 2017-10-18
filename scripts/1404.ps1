<#
.SYNOPSIS
	Reports on Fibre Channel Adapters in the ESX hosts for a vCenter environment.
.DESCRIPTION
	This script iterates through each Datacenter,Cluster, and Host in a vCenter environment and then lists the Fibre Channel HBAs that are present. 
.LINK
.EXAMPLE
	PS> Get-VMStorageAdapters.ps1 -FileName hba.txt
	
	This example runs the script and directs output to be saved to hba.txt in addition to the console. 
.PARAMETER Server
	Connect to the specified vCenter server for the environment you wish to collect information from.
.PARAMETER Credential
	Credential to connect to the vCenter server. If no credentials are specified script will prompt for them.
.PARAMETER FileName
	Name of text file to save script output in addition to the console
.NOTES
  Name:			Get-VMStorageAdapters
  Author:		Mark E. Schill
  Date Created:	10/01/2009
  Date Revised:	10/01/2009
  Version:		1.0
  History:		1.0 10/01/2009 - Initial Revision
  
  #requires –Version 2.0
  #requires -PsSnapIn VMware.VimAutomation.Core -Version 2
#>
[CmdletBinding()]
param(
[Parameter(Position=1,Mandatory=$false)]
[Alias("VIServer")]
$Server
,
[Parameter(Position=2,Mandatory=$false)]
[Alias("PSCredential")]
[System.Management.Automation.PSCredential]$Credential
,
[Parameter(Position=3,Mandatory=$False)]
$FileName
)
Begin
{
	# Were credentials specified? If not then prompt for them.
	if(!$Credential)
	{
		$Credential = Get-Credential
	}
	
	# Are we outputing to file? If so then set filename and create.
	if ($FileName)
	{
		$ScriptPath = Split-Path $MyInvocation.MyCommand.Definition -Parent
		$FileName = "$ScriptPath\$FileName"			
		Set-Content -Path $FileName -Value "" -force
	}
	
	#Connect to vCenter Server
	Connect-VIServer -Server $VIServer -Credential $Credential

	#Iterate Datacenters
	Get-Datacenter | % { 
		Write-Host $([string]::Format( "{0}",$_.Name)) -ForegroundColor Cyan
		if ($FileName) {Add-Content -Path $FileName -Value $([string]::Format( "{0}",$_.Name))}
		
		#Iterate Clusters
		Get-Cluster -Location $_ | % {
			Write-Host $([string]::Format( "`t{0}",$_.Name)) -ForegroundColor Cyan
			if ($FileName) {Add-Content -Path $FileName -Value $([string]::Format( "`t{0}",$_.Name))}
			
			#Iterate ESX Hosts
			Get-VMHost -Location $_ | % { 
				Write-Host $([string]::Format( "`t`t{0}",$_.Name)) -ForegroundColor Cyan
				if ($FileName) {Add-Content -Path $FileName -Value $([string]::Format( "`t`t{0}",$_.Name))}
				
				#Iterate through storage adapters on server and filter out Fibre Channel Adapters. 
				$StorageView = Get-VMHostStorage -VMHost $_ | Get-View
				$StorageAdapter = $StorageView.StorageDeviceInfo.HostBusAdapter
				$StorageAdapter | % { 
					if ( $_.key -match "FibreChannelHba" )
					{
						# Output the Device Name and Port and Node WWNs respectively.
						Write-Host $([string]::Format("`t`t`t{0} {1:X} {2:X}",$_.Device, $_.PortWorldWideName, $_.NodeWorldWideName)) -ForegroundColor Yellow
						if ($FileName) {Add-Content -Path $FileName -Value $([string]::Format("`t`t`t{0} {1:X} {2:X}",$_.Device, $_.PortWorldWideName, $_.NodeWorldWideName))}
					}
				}
			}
		}
	}
}
Process
{
}
End
{
}
