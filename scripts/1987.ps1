function ConvertVMDiskToThin($vm, $datastore) {
   $vmView = Get-View $vm
   $dsView = Get-View $datastore
   
   $relocateSpec = New-Object VMware.Vim.VirtualMachineRelocateSpec
	$relocateSpec.Datastore = $dsView.MoRef
	$relocateSpec.Transform = "sparse"
   
   $vmView.RelocateVM($relocateSpec, $null)
}

