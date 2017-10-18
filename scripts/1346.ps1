$cat = New-Object system.Diagnostics.PerformanceCounterCategory("Network Interface")
$inst = $cat.GetInstanceNames()
foreach ( $nic in $inst ) {
	$a = $cat.GetCounters( $nic )
	$a | ft CounterName, { $_.NextValue() } -AutoSize
}
