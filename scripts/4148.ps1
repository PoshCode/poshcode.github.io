# begin of settings
$VC1 = "VC server"
# end of settings
if (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
	Add-PSSnapin VMware.VimAutomation.Core
}
# Connect to vCenter server
Connect-VIServer "$VC1"

$VMs = Import-Csv D:\vSpherePowerCLI\Scripts\Inventory-report\upgrade.csv | 
	Foreach {Get-VM -Name $_.Name | Sort Name}
$VM = $VMs | Select -First 1

Foreach ($vm in $vms) {
$config = New-Object VMware.Vim.VirtualMachineConfigSpec
$config.Tools = New-Object VMware.Vim.ToolsConfigInfo
$config.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"
$vm.ExtensionData.ReconfigVM($config)
}

# Disconnect vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false
