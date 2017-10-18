param($ComputerName = 'COMPUTERNAME')

$output = [PSCustomObject]@{ComputerName = $ComputerName;MonitorSizes=''}

$oWmi = Get-WmiObject -Namespace 'root\wmi' -ComputerName $ComputerName -Query "SELECT MaxHorizontalImageSize,MaxVerticalImageSize FROM WmiMonitorBasicDisplayParams";
$sizes = @();
if ($oWmi.Count -gt 1) {
	foreach ($i in $oWmi) {
		$x = [System.Math]::Pow($i.MaxHorizontalImageSize/2.54,2)
		$y = [System.Math]::Pow($i.MaxVerticalImageSize/2.54,2)
        $sizes += [System.Math]::Round([System.Math]::Sqrt($x + $y),0)
	}##endforeach
} else {
	$x = [System.Math]::Pow($oWmi.MaxHorizontalImageSize/2.54,2)
	$y = [System.Math]::Pow($oWmi.MaxVerticalImageSize/2.54,2)
	$sizes += [System.Math]::Round([System.Math]::Sqrt($x + $y),0)
}##endif

$output.MonitorSizes = $sizes

$output
