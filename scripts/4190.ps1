Param (
    [string]$computerName = $env:computerName
)

if ($computerName -eq $env:computerName) {
    $os = Get-WmiObject -Class win32_operatingsystem
    $boottime = [management.managementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
    $now = [DateTime]::Now
    $uptime = New-TimeSpan -Start $boottime -End $now
    Write-Host "Current System Uptime on $computerName`:" $uptime.Days 'Days,' $uptime.Hours 'Hours,' $uptime.Minutes 'Minutes,' $uptime.Seconds 'Seconds'
} else {
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        $os = Get-WmiObject -Class win32_operatingsystem
        $boottime = [management.managementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
        $now = [DateTime]::Now
        $uptime = New-TimeSpan -Start $boottime -End $now
        Write-Host "Current System Uptime on $env:computerName`:" $uptime.Days 'Days,' $uptime.Hours 'Hours,' $uptime.Minutes 'Minutes,' $uptime.Seconds 'Seconds'
    }
}
