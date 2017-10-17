Function Set-dvSwitch {
	param($vmName,$dvPG) # the two parameters.

	$nic = "Network adapter 1"	# change this line if you want to change network adapter 2

	# Find the NIC
	$vm = Get-VM $vmName | Get-View
	foreach($tempdev in $vm.Config.Hardware.Device){
		if($tempdev.DeviceInfo.Label -eq $nic){
			$tgtdev = $tempdev
		}
	}

	# Find the dvSwitch & dvPortGroup
	$esx = Get-View -Id $vm.Runtime.Host
	foreach($netMoRef in $esx.Network){
		if($netMoRef.Type -eq "DistributedVirtualPortGroup"){
			$net = Get-View -Id $netMoRef
			if($net.Name -eq $dvPg){
				$dvPGKey = $net.MoRef.Value
				$dvSwitchUuid = (Get-View -Id $net.Config.DistributedVirtualSwitch).Summary.Uuid
			}
		}
	}

	# Prepare Spec
	$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$devChange = New-Object VMware.Vim.VirtualDeviceConfigSpec
	$devChange.operation = "edit"

	$dev = New-Object ("VMware.Vim." + $tgtdev.GetType().Name)
	$dev.deviceInfo = New-Object VMware.Vim.Description
	$dev.deviceInfo.label = $tgtdev.DeviceInfo.Label
	$dev.deviceInfo.summary = $tgtdev.DeviceInfo.Summary
	$dev.Backing = New-Object VMware.Vim.VirtualEthernetCardDistributedVirtualPortBackingInfo
	$dev.Backing.Port = New-Object VMware.Vim.DistributedVirtualSwitchPortConnection
	$dev.Backing.Port.PortgroupKey = $dvPGKey
	$dev.Backing.Port.SwitchUuid = $dvSwitchUuid
	$dev.Key = $tgtdev.Key

	$devChange.Device = $dev
	$spec.deviceChange = $devChange

	$taskMoRef = $vm.ReconfigVM_Task($spec)
}
