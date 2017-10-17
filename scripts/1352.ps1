$cnt = 'Bytes Total/sec'
$cat = 'Network Interface'
$cnt2 = 'Current Bandwidth'
foreach ($inst in ((new-object System.Diagnostics.PerformanceCounterCategory("network interface")).GetInstanceNames())){
	$cur = New-Object system.Diagnostics.PerformanceCounter($cat,$cnt,$inst)
	$max = New-Object system.Diagnostics.PerformanceCounter($cat,$cnt2,$inst)
	$curnum = $cur.NextValue()
	$maxnum = $max.NextValue()
	$ObjUtil = New-Object System.Object
	$ObjUtil | Add-Member -MemberType NoteProperty -Name "Util" -Value ((( $curnum * 8 ) / $maxnum ) * 100)
	$ObjUtil | Add-Member -MemberType NoteProperty -Name "InstanceName" -Value $inst
	$ObjUtil
}
