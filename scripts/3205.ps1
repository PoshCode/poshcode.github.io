#####################################################################
#	
# 	Purpose:  "Check and upgrade Tools during power cycling"
# 	Author:   David Chung
# 	Support:  IT Infrastructure
# 	Docs:     N/A
#
#	Instruction:	1. Create CSV file with list of servers
#					2. Execute script from PowerCLI
#					3. Enter virtual server name
#				
#####################################################################
$viserver = read-host "Please enter vCenter Server:"
connect-viserver $viserver
$vms = Import-Csv c:\server.csv

foreach ($vm.name in $vms) 
	{
	Write-Host $vm.name " - Enabling VMTools Update at Power Cycle" 
	$vmConfig = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfig.Tools = New-Object VMware.Vim.ToolsConfigInfo
	$vmConfig.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"
	Get-VM $vm.name | where {$_.Extensiondata.ReconfigVM($vmconfig)}
	}
