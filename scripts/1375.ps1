function Kill-Process(){
	param(
	[string[]]$ComputerNames,
	[string[]]$ProcessNames,
	$User
	)
	if ($ProcessNames -eq $null){Write-Error 'The parametre "ProcessNames" cannot be empty';break}
	if ($User -is [String]){$Connection = Get-Credential -Credential $User}
	if ($Connection -eq $null){
		foreach ($int1 in $ComputerNames){
			foreach ($int2 in $ProcessNames){
				if ($int2 -notlike "*.exe") {$int2 = $int2 + '.exe'}
				$Kill_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
								% {$_.terminate();$count++}
				$Kill_Process = "" | select @{e={$int1};n='Computer'},`
											@{e={$int2};n='Process'}, @{e={$count};n='Count'}
				$Kill_Process
			}
		}
	}
	else {
		foreach ($int1 in $ComputerNames){
			foreach ($int2 in $ProcessNames){
				$Kill_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" -Credential $Connection | 
								% {$_.terminate();$count++}
				$Kill_Process = "" | select @{e={$int1};n='Computer'},`
											@{e={$int2};n='Process'}, @{e={$count};n='Count'}
				$Kill_Process
			}
		}
	}
}
