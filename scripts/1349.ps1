$cnt = 'Bytes Total/sec'
$inst = 'Broadcom NetXtreme Gigabit Ethernet - Packet Scheduler Miniport'
$cat = 'Network Interface'
$cnt2 = 'Current Bandwidth'
$cur = New-Object system.Diagnostics.PerformanceCounter($cat,$cnt,$inst)
$max = New-Object system.Diagnostics.PerformanceCounter($cat,$cnt2,$inst)
$curnum = $cur.NextValue()
$maxnum = $max.NextValue()
$util = (( $curnum * 8 ) / $maxnum ) * 100
$util
