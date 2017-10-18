#########################################
# MaintenanceMode.ps1
# Created by NinjaTechie 2013-12-12
#
# Simple script to place several servers
# into maintenance mode at the same time
#
#########################################
 
$OMServer = "operationsmanagerserver.contoso.local"
$domain = "contoso.local"
$minutes = 240
$computers = '.\Computers.txt'
$class = "Microsoft.Windows.Computer"
$comment = 'Scheduled Maintenance'
 
Import-Module OperationsManager
New-SCOMManagementGroupConnection $OMServer
 
$class = Get-SCOMClass -Name $class
$startTime = [System.DateTime]::Now.ToUniversalTime()
$endTime = [System.DateTime]::Now.AddMinutes($minutes).ToUniversalTime()
 
$ComputerNames = Get-Content $computers
 
foreach ($name in $ComputerNames) {
 $instance = Get-SCOMClassInstance -Class $class | ? { $_.Name -eq ($name + "." + $domain) }
 "Putting " + $name + " into maintenance mode..."
 $instance.ScheduleMaintenanceMode($startTime, $endTime, "PlannedApplicationMaintenance", $comment , "Recursive")
 Start-Sleep -s 2
}
