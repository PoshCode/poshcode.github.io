function View-Process {
param(
[string[]]$ComputerNames,
[string[]]$ProcessNames,
$User
)
###########################################################################################################
if ($User -is [String]) {
	$Connection = Get-Credential -Credential $User
	}
###########################################################################################################
foreach ($int1 in $ComputerNames) {
	if ($ProcessNames -eq $null) {
		if ($Connection -eq $null) {
			$View_Process = gwmi "win32_process"  -ComputerName $int1 | 
							select __SERVER,Name,Handle
		}
		else {
			$View_Process = gwmi "win32_process"  -ComputerName $int1 -Credential $Connection | 
							select __SERVER,Name,Handle
		}
	$View_Process
	}
	else {
		foreach ($int2 in $ProcessNames) {
			if ($int2 -notlike "*.exe") {$int2 = $int2 + '.exe'}
			if ($Connection -eq $null) {
				$View_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
								select __SERVER,Name,Handle
			}
			else {
				$View_Process = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" -Credential $Connection | 
								select __SERVER,Name,Handle
			}
		$View_Process
		}
	}
}
###########################################################################################################
}
