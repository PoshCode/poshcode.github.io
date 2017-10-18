#######################################################################################################################
# File:             ESXiMgmt_machines_poweron_sample.ps1                                                              #
# Author:           Alexander Petrovskiy                                                                              #
# Publisher:        Alexander Petrovskiy, SoftwareTestingUsingPowerShell.WordPress.Com                                #
# Copyright:        © 2011 Alexander Petrovskiy, SoftwareTestingUsingPowerShell.WordPress.Com. All rights reserved.   #
# Prerequisites:    The module was tested with Vmware ESXi 4.1 U1 on the server side and                              #
#                       Vmware PowerCLI 4.1 U1                                                                        #
#                       plink.exe 0.60.0.0                                                                            #
# Usage:            To load this module run the following instruction:                                                #
#                       Import-Module -Name ESXiMgmt -Force                                                           #
#                   Please provide feedback in the SoftwareTestingUsingPowerShell.WordPress.Com blog.                 #
#######################################################################################################################
param([string]$Server,
	  [string]$User,
	  [string]$Password,
	  [string]$DatastoreName,
	  [string]$Drive,
	  [string]$MachinePrefix,
	  [int]$OperationTimeout
	  )
# USAGE: .\ESXiMgmt_machines_poweron_sample.ps1 192.168.1.1 root 123 datastore3 host1ds3 XPSP2 300

cls
Set-StrictMode -Version Latest
Import-Module ESXiMgmt -Force;

Connect-ESXi -Server $Server -Port 443 `
	-Protocol HTTPS -User $User -Password $Password `
	-DatastoreName $DatastoreName -Drive $Drive;

$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue;
$VMs = Get-VM *

[int]$grouper = 5;
foreach($vm in $VMs)
{
	if ($vm.Name -like "$($MachinePrefix)*" -and `
		$vm.PowerState -ne 1) 
	# [VMware.VimAutomation.ViCore.Types.V1.Inventory.PowerState]::PoweredOff = 0
	# [VMware.VimAutomation.ViCore.Types.V1.Inventory.PowerState]::PoweredOn = 1
	# [VMware.VimAutomation.ViCore.Types.V1.Inventory.PowerState]::Suspended = 2
	{
		Write-Verbose "$($vm.Name) is starting";
		Start-ESXiVM -Server $Server `
			-User $User -Password $Password `
			-Id (Get-ESXiVMId $vm);
		$grouper--;
		if ($grouper -eq 0){
			Write-Verbose "Sleeping for $($OperationTimeout) seconds";
			sleep -Seconds $OperationTimeout;
			$grouper = 5;
		}
	}
}
		
Disconnect-ESXi
