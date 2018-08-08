function WhileTimeout ( [int]$interval, [int]$maxTries, [scriptblock]$condition )
{
	$i = 0
	$startTime = Get-Date
	while ( &$condition ) {
		$i++
		if ( $i -lt $maxTries ) {
			Start-Sleep -seconds $interval
		} else {
			Throw "Operation exceeded timeout"
		}
	}
	$endTime = Get-Date
	$duration = ( $endTime - $startTime ).TotalSeconds
	Write-Verbose "Operation elapsed time: $duration seconds"
}


