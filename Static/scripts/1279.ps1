[string]$entry = $args[0]
if ($entry -eq $null) { [string]$entry = Read-Host -Prompt "Enter Computer Name" }

$Computers = Get-QADComputer $entry

$Computers | ForEach-Object {Get-WmiObject Win32_Registry -ComputerName $_.Name | Select-Object @{Name="Name";Expression={$_.__SERVER}},CurrentSize,MaximumSize,Caption}

