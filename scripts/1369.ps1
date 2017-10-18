Begin {

	$key = "keyboard.typematicMinDelay"
	$value = "2000000"
}

Process {
    #Make Sure it's a VM
	if ( $_ -isnot [VMware.VimAutomation.Client20.VirtualMachineImpl] ) { continue }
	
	#Setup our Object
	$vm = Get-View $_.Id
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
	$vmConfigSpec.extraconfig[0].Key=$key
	$vmConfigSpec.extraconfig[0].Value=$value
	
	#Run the change
	$vm.ReconfigVM($vmConfigSpec)
}
