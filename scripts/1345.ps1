$cat = New-Object system.Diagnostics.PerformanceCounterCategory("Network Interface")
$inst = $nic.GetInstanceNames()
foreach ( $nic in $inst ) {
	$a = $nic.GetCounters( $nic )
	$a | ft CounterName, { $_.NextValue() } -AutoSize
}
