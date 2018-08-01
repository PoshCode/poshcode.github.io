function Update-Ipod {
	$start = Get-Date
	$iTunesCOM = New-Object -comObject iTunes.Application
	$iTunesCOM.UpdateIPod()
	$elapsedTime = (Get-Date) - $start
	Write-Host "Elapsed Time: $elapsedTime"
}
