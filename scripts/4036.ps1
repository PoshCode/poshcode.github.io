<#
.SYNOPSIS
Creates config bundle backup for ESXi hosts. Works where 80 is blocked to ESXi host
Originally script by Alan Renouf (http://www.virtu-al.net/2011/02/23/backing-up-the-esxi-system-image)
Heavily Modified by Jimmy Hester 
.DESCRIPTION
Checks for connection to a vCenter or ESXi server
If not connected, connects to the server specified
If already connected, connects to the server listed in $Global:DefaultVIServer
Connects to each vmhost in a vCenter, pulls a backup of its configuration, and saves it to the client machine.
If connected to an ESXi host, it will backup that host.
Once backed up, it will disconnect from the server if the connection was intially created by this script. It will leave pre-existing connections intact.

If run in an environment where access to the ESXi host(s) on port 80 (from the machine running this script) is blocked, 
the script will bypass the access failure and download the config bundle directly. 
See this VMware Community thread for details: http://communities.vmware.com/thread/419926

.PARAMETER <paramName>
VIServer = The name of the vCenter server or ESXi host to use. If a vCenter server is specified, all the hosts in the vCenter will be backed up
If an ESXi host is specified, only that host will be backed up.
#>

Param (
	[string]$VIServer
	)
#Check for PowerCLI
If ( (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null) {
	Add-PSSnapin VMware.VimAutomation.Core
	}

#Change this to a local folder that already exists	
$RootFolder = "C:\admin\ESXi_Backups\"

If (($VIServer) -and (-not($VIServer -eq $global:defaultviserver)))  {
	Connect-VIServer $VIServer -Credential (Get-Credential) | Out-Null
	Write-Host ""
	Write-Host "Connecting to $VIServer"
	Write-Host ""
	$Disconnect = $true
	}
	elseif (!$global:DefaultVIServer) {
		Write-Host "Cannot determine which VCenter to use. No backups taken."
		Write-Host ""
		break
		}
	else {
		$VIServer = $global:DefaultVIServer
		Write-Host "Connected to $VIServer"
		Write-Host ""
		}
	
	$VMhosts = Get-VMHost -Server $VIServer
	
	Foreach ($VMhost in $VMhosts) {
		Write-Host "Backing up state for $VMhost"
		$Date = Get-Date -f yyyyMMdd_hhmm
		$Folder = $RootFolder + "$($VIServer)\" + $Date 
		If (-not (test-path $Folder)) {
		MD $Folder | Out-Null
		}
		
	 	Get-VMHostFirmware $VMhost -BackupConfiguration -DestinationPath $Folder -ErrorAction SilentlyContinue | Out-Null
		#Uncomment next line if the path for $Folder has hyphens
		#MV ($RootFolder + "*") $Folder -ErrorAction SilentlyContinue
		
		#This will bypass the port http get failure in environments where port 80 is blocked to the ESXi host.
		#This tests to see if the Get-VMHostFirmware cmdlet was able to download the config bundle.
		#If not, calls the same https URL as the Get-VMHostFirmware cmdlet
		If (-not (test-path $Folder\configBundle-$vmhost.tgz)){
		Invoke-Webrequest https://$vmhost/downloads/configBundle-$vmhost.tgz -outfile $folder\configBundle-$vmhost.tgz
		}
				
	}
If ($Disconnect) {
	Write-Host "Disconnecting from $VIServer"
	Disconnect-VIServer $VIServer -Confirm:$false | Out-Null
	}
	
	
Write-Host ""
Write-Host "The config backups for $VIServer are located at:"
Write-Host $Folder
Write-Host ""

