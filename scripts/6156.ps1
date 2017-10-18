    param([string]$computerName, [System.Management.Automation.PSCredential]$Credential)

    invoke-command -ComputerName $computername -Credential $Credential -ScriptBlock {

        $CPUPercent = @{
                Name = 'CurrentCPUPercent'
                Expression = {
                $TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
                [Math]::Round( ($_.CPU * 100 / $TotalSec), 2)
            }
        }
        $processes = Get-Process | ? {$_.TotalProcessorTime -ne $Null} | Select-Object -Property Name, @{Name="CPUSeconds"; Expression = {($_.CPU)}},@{Name="WorkingSetMB"; Expression = {($_.WorkingSet / 1mb)}},TotalProcessorTime, $CPUPercent, Description 
    
        $processes | Sort-Object -Property CurrentCPUPercent -Descending | Out-GridView -Title 'Current Highest CPU %'
    }
}
