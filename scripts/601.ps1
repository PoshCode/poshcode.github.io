function Select-Alive {param(	[object]$InputObject,
								[string]$Property,
								[int32]$Requests = 3)

	PROCESS {
		if ($InputObject -eq $null) {$In = $_} else {$In = $InputObject}
		if ($In.GetType().Name -eq "String") {
			$HostName = $In
		} 
		elseif (($In | Get-Member | Where-Object {$In.Name -eq $Property}) -ne $null) {
			$HostName = $In.$Property
		} else {return $null}
		
		for ($i = 1; $i -le $Requests; $i++) {
			$Result = Get-WmiObject -Class Win32_PingStatus -ComputerName . -Filter "Address='$HostName'"
			Start-Sleep -Seconds 1
			if ($Result.StatusCode -ne 0) {return $null}
		}
		return $In
	}
}

