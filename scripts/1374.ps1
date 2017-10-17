function View-Process(){
	param(
	[string[]]$ComputerNames,
	[string[]]$ProcessNames,
	$User
	)
	if ($User -is [String]){
		$Connection = Get-Credential -Credential $User
	}
	if ($ProcessNames -eq $null){
		if ($Connection -eq $null){
			foreach ($int1 in $ComputerNames){
				$View_Process = gwmi "win32_process"  -ComputerName $int1 |
								select __SERVER,Name,Handle
				$View_Process
			}
		}
		else {
			foreach ($int1 in $ComputerNames){
				$View_Process = gwmi "win32_process"  -ComputerName $int1 -Credential $Connection | 
								select __SERVER,Name,Handle
				$View_Process
			}
		}
	}
	else {
		if ($Connection -eq $null){
			foreach ($int1 in $ComputerNames){
				foreach ($int2 in $ProcessNames){
					if ($int2 -notlike "*.exe") {$int2 = $int2 + '.exe'}
						$View_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
										select __SERVER,Name,Handle
					$View_Process
				}
			}
		}
		else {
			foreach ($int1 in $ComputerNames){
				foreach ($int2 in $ProcessNames){
					$View_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" -Credential $Connection | 
									select __SERVER,Name,Handle
					$View_Process
				}
			}
		}
	}
}
