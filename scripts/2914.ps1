#######################################################################################################################
# File:             ESXiMgmt_register_all_virtual_machines_sample.ps1                                                 #
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
	  [string]$Drive
	  )
# USAGE: .\ESXiMgmt_register_all_virtual_machines_sample.ps1 192.168.1.1 root 123 datastore3 host1ds3

cls
Set-StrictMode -Version Latest
Import-Module ESXiMgmt -Force;

Connect-ESXi -Server $Server -Port 443 `
	-Protocol HTTPS -User $User -Password $Password `
	-DatastoreName $DatastoreName -Drive $Drive;

dir "$($Drive):" | %{ `
		# supposedly, all the *.vmx files have
		# the same names as their folders
		# like VMName\VMName.vmx
		if (Test-Path "$($_.FullName)\$($_.Name).vmx")
		{
			Register-ESXiVM  -Server $Server `
				-User $User -Password $Password `
				-Path "/vmfs/volumes/$($DatastoreName)/$($_.Name)/$($_.Name).vmx" `
				-OperationTImeout 5;
		}
	}
			
