$vmPath = "[Storage1] MyVM/MyVM.vmx"
$vm = New-VM –VMHost "192.168.1.10" –VMFilePath $vmPath -Name MyVM

# Check if there is an error and if so – handle it
if (!$?) {
    if ($error[0].Exception –is [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.DuplicateName]) {
	# A VM with the same name already exists. Change the name and try again.
	$vm = New-VM –VMHost "192.168.1.10" –VMFilePath $vmPath –Name "myVM (1)"
    } elseif ($error[0].Exception –is [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InsufficientResourcesFault]) {
	# There aren’t enough resources on this host. Try again on another host.
	$vm = New-VM –VMHost "192.168.1.12" –VMFilePath $vmPath
    } else {
	# Handle unexpected exceptions here …
    }
}

