function Get-LunVM {
	param($Lun)

	Get-VM | Where {
		$_ | Get-Stat -stat disk.write.average -realtime -maxsamples 1 `
		    -erroraction SilentlyContinue |
			Where { $_.Instance -eq $Lun } }
}

