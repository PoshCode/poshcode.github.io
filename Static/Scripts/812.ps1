$vm = get-vm testvm
$ds = $vm | get-datastore
move-vm -VM $vm -Destination (get-vmhost MyDestination) -Datastore $ds
