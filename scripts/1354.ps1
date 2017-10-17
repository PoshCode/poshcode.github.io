function Kill-Process() {
param(
[string[]]$ComputerNames,
[string[]]$ProcessNames,
$User
)
###########################################################################################################
if ($ProcessNames -eq $null) {Write-Error 'The parametre "ProcessNames" cannot be empty';break}
###########################################################################################################
if ($User -is [String]) {
	$Connection = Get-Credential -Credential $User
	}
###########################################################################################################
foreach ($int1 in $ComputerNames){
	foreach ($int2 in $ProcessNames) {
		if ($int2 -notlike "*.exe") {$int2 = $int2 + '.exe'}
			if ($Connection -eq $null) {$count = 0
				$Process_Kill = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
								ForEach-Object {$_.terminate();$count++}					
				$Process_Kill = "" | select @{e={$int1};n='Computer'},`
											@{e={$int2};n='Process'}, @{e={$count};n='Count'}
			}
			else {$count = 0
				$Process_Kill = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
								ForEach-Object {$_.terminate();$count++}
				$Process_Kill = "" | select @{e={$int1};n='Computer'},`
											@{e={$int2};n='Process'}, @{e={$count};n='Count'}
			}
	$Process_Kill
	}
}
###########################################################################################################
}
