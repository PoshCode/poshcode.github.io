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
				$Process_Kill = "" | select @{e={$int1};n='&#1050;&#1086;&#1084;&#1087;&#1100;&#1102;&#1090;&#1077;&#1088;'},`
											@{e={$int2};n='&#1055;&#1088;&#1086;&#1094;&#1077;&#1089;&#1089;'}, @{e={$count};n='&#1050;&#1086;&#1083;&#1080;&#1095;&#1077;&#1089;&#1090;&#1074;&#1086;'}
			}
			else {$count = 0
				$Process_Kill = gwmi "win32_process"  -ComputerName $int1 -filter "name='$int2'" | 
								ForEach-Object {$_.terminate();$count++}
				$Process_Kill = "" | select @{e={$int1};n='&#1050;&#1086;&#1084;&#1087;&#1100;&#1102;&#1090;&#1077;&#1088;'},`
											@{e={$int2};n='&#1055;&#1088;&#1086;&#1094;&#1077;&#1089;&#1089;'}, @{e={$count};n='&#1050;&#1086;&#1083;&#1080;&#1095;&#1077;&#1089;&#1090;&#1074;&#1086;'}
			}
	$Process_Kill
	}
}
###########################################################################################################
}
