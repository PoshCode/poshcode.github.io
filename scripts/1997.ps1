function Set-ComputerName {
	param(	[switch]$help,
		[string]$computerName=$(read-host "Please specify the new name of the computer"))
			
	$usage = "set-ComputerName -computername AnewName"
	if ($help) {Write-Host $usage;break}
	
	$computer = Get-WmiObject Win32_ComputerSystem
	$computer.Rename($computerName)
	}
