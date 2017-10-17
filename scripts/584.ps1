# author: Hal Rottenberg
# Website/OpenID: http://halr9000.com
# purpose: does "real" SVMotion of a VM
# usage: get-vm | SVMotion-VM -destination (get-datastore foo)

function SVMotion-VM {
	param(
		[VMware.VimAutomation.Client20.DatastoreImpl]$destination
	)
	Begin {
		$datastoreView = Get-View -VIObject $destination
		$relocationSpec = New-Object VMware.Vim.VirtualMachineRelocateSpec
		$relocationSpec.Datastore = $datastoreView.MoRef
	}
	Process {
		if ( $_ -isnot [VMware.VimAutomation.Client20.VirtualMachineImpl] ) {
			Write-Warning "Expected virtual machine object on pipeline. skipping $_"
			continue
		}
		$vmView = Get-View -VIObject $_
		$vmView.RelocateVM_Task($relocationSpec)
	}
}
