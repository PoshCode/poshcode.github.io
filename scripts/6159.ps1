#
#restore-LastSnapshot 
#Reverts specified VM to last (most current) snapshot
#
#


param(
	[string]$vcenter,
	[string]$vm
)


connect-viserver -server $vcenter
$snap = Get-Snapshot -VM $vm | Sort-Object -Property Created -Descending | Select -First 1
Set-VM -VM $vm -SnapShot $snap -Confirm:$false
start-vm -vm $vm





