function New-HyperVVM {
	param	(
			[string]$Hypervhost = "localhost",
			[string]$Vm = "VM Courtesy of PowerShell",
			[string]$location = "C:\MyVirtualMachines\$vm"
			)
	$wmiClassString = "\\" + $Hypervhost + "\root\virtualization:Msvm_VirtualSystemGlobalSettingData"
	$wmiclass = [WMIClass]$wmiClassString
	$newVSGlobalSettingData = $wmiClass.CreateInstance()
	$newVSGlobalSettingData.psbase.Properties.Item("ExternalDataRoot").value = $location
	$newVSGlobalSettingData.psbase.Properties.Item("ElementName").value = $Vm
	$VSManagementService = gwmi MSVM_VirtualSystemManagementService -namespace "root\virtualization" -ComputerName $Hypervhost
	$GlobalSettings  = $newVSGlobalSettingData.psbase.GetText(1)
	$VSManagementService.DefineVirtualSystem($GlobalSettings, $ResourceSettings)
}
