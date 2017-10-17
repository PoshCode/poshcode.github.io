param ( $Age = 30 )

Connect-VIServer vcenter.domain.com
$vm = Get-VM
$snapshots = Get-Snapshot -VM $vm
Write-Host -ForegroundColor Red "Old snapshots found:"
foreach ( $snap in $snapshots ) {
	if ( $snap.Created -lt (Get-Date).AddDays( -$Age ) ) {
		Write-Host "Name: " $snap.Name "  Size: " $snap.SizeMB "  Created: " $snap.Created
	}
}
