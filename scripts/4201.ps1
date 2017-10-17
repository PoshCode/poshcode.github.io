Param (
    [string]$computerName = $env:computerName
)

$os = Get-WmiObject -ComputerName $computerName -Class win32_operatingsystem
$boottime = [management.managementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
$now = [management.managementDateTimeConverter]::ToDateTime($os.localdatetime)
$uptime = New-TimeSpan -Start $boottime -End $now
if ($computername -ne $os.csname) { $altname = " ($($os.csname))" }
Write-Host "Uptime on ${computerName}${altname}`:" $uptime.Days 'Days,' $uptime.Hours 'Hours,' $uptime.Minutes 'Minutes,' $uptime.Seconds 'Seconds'

