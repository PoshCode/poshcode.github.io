# begin of settings
$VC1 = "VC server"
# end of settings
if (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
	Add-PSSnapin VMware.VimAutomation.Core
}
# Connect to vCenter server
Connect-VIServer "$VC1"

$vms = Get-VM | where {(Get-Cluster).Name -eq "CLUSTER NAME"}
Foreach ($vm in $vms) {
$config = New-Object VMware.Vim.VirtualMachineConfigSpec
$config.Tools = New-Object VMware.Vim.ToolsConfigInfo
$config.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"
$vm.ExtensionData.ReconfigVM($config)
}

# Disconnect vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false
