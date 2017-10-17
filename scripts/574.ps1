# author: Hal Rottenberg
# Website/OpenID: http://halr9000.com
# purpose: does "real" SVMotion of a VM
# usage: get-vm | SVMotion-VM -destination (get-datastore foo)

function SVMotion-VM {
	param(
		[VMware.VimAutomation.Client20.DatastoreImpl]
		$destination
	)
	Begin {
		$datastoreView = get-view $destination
		$relocationSpec = new-object VMware.Vim.VirtualMachineRelocateSpec
		$relocationSpec.Datastore = $datastoreView.MoRef
	}
	Process {
		if ( $_ -isnot VMware.VimAutomation.Client20.VirtualMachineImpl ) {
			Write-Error "Expected VMware object on pipeline. skipping $_"
			continue
		}
		$vmView = Get-View $_
		$vmView.RelocateVM_Task($relocationSpec)
	}
}


