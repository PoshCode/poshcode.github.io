#####################################################
# Migrate a VM to new storage and set to Thin Prov  #
#####################################################
# Set the VM name you want to move
$Server = 'SERVERNAME'
# Set the location you want to move the VM to
$DataStore = 'DATASTORE'
# Set the vCenter name (should not need to be changed)
$VCName = 'VCENTERSERVER'
# Load VMWare Snapin
asnp VMware.VimAutomation.Core -ErrorAction SilentlyContinue
# Connect to vCenter
Connect-VIServer $VCName -User 'USERNAME' -Password 'PASSWORD'
# Check if server is powered off, if not perform a clean shutdown
$VMPower = Get-VM $Server
If($VMPower.PowerState -eq 'PoweredOn'){
	Get-VM $Server | Shutdown-VMGuest
	}
# Wait for VM to stop
Start-Sleep -s 30
# Move the server to the new storage and set it to thin provisioned 
Move-VM $Server -Datastore $DataStore -DiskStorageFormat Thin
# Power on the VM
#Start-VM $Server 
# disconnect from the vCenter CLI 
Disconnect-VIServer -Confirm:$False
