function Get-VMHostLunLatency {
	param($VMHost)

	$luns = $VMHost | Get-ScsiLun
	foreach ($lun in $luns) {
		$stats = $VMHost |
			Get-Stat -stat disk.totalreadlatency.average,disk.totalwritelatency.average -maxsamples 1 -realtime |
			Where { $_.Instance -eq $Lun.CanonicalName }
		if ($stats.length -ne $null) {
			$obj = New-Object PSObject
			$obj | Add-Member -MemberType NoteProperty -Name Lun -Value $lun.CanonicalName
			$obj | Add-Member -MemberType NoteProperty -Name ReadLatency -Value ($stats[0].Value)
			$obj | Add-Member -MemberType NoteProperty -Name WriteLatency -Value ($stats[1].Value)
			Write-Output $obj
		}
	}
}

