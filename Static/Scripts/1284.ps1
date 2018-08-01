foreach ($entry in (import-csv "spreadsheet.csv")) {
	$ipScript = @"
	`$NetworkConfig = Get-WmiObject -Class Win32_NetworkAdapterConfiguration
	`$NicAdapter = `$NetworkConfig | where {`$_.DHCPEnabled -eq "True"}
	`$NicAdapter.EnableStatic('$entry.IP','$entry.Netmask')
	`$NicAdapter.SetGateways('$entry.Gateway')
	"@

	Get-VM $entry.VMName | Invoke-VMScript -HostUser $entry.HU -HostPassword $entry.HP -GuestUser $gu -GuestPassword $gp $ipScript
}


