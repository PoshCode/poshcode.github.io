#Some Parameters
param([string]$ftVM, [string]$ftState)

#Load the PowerCLI Snapin
add-pssnapin VMware.VimAutomation.Core

#Load the creds file
$creds = Get-VICredentialStoreItem -file c:\test 

#Connect to the host
connect-viserver -Server $creds.Host -User $creds.User -Password $creds.Password

#Based on $ftState, turn FT on or off for $ftVM
$ftState = $ftState.ToLower()
if ($ftState -eq "on"){
	#Turn FT On
	Get-VM X | Get-View | % { $_.CreateSecondaryVM($null) }
} elseif ($ftstate -eq "off"){
	#Turn FT Off
	Get-VM X | Select -First 1 | Get-View | % { $_.TurnOffFaultToleranceForVM() }
} else {
	Write-Error "FT State must be either On or Off"
}
