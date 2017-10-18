Import-Module OperationsManager

$computer = "mycomputer.mydomain.com"

$time = (Get-date).AddMinutes(15)

$instance = Get-SCOMClassInstance -Name $computer -ComputerName myscommgmtserver

Start-SCOMMaintenanceMode -Instance $instance -EndTime $time -Comment "Applying updates" -Reason PlannedOther
