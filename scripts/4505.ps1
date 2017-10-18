# Declare custom object 
$CustObj = @()

# Get PID and %CPU. doesn't display owner and other information though
# Set High CPU threshold here by adding another "-and" condition
# Example for more than 60% CPU would be:
# $HighProcPids = gwmi Win32_PerfFormattedData_PerfProc_Process | ?{(($_.percentprocessortime -ne 0) -and ($_.idprocess -ne 0) -and ($_.percentprocessortime -gt 60))}| Select IdProcess, PercentProcessorTime
$HighProcPids = gwmi Win32_PerfFormattedData_PerfProc_Process | ?{(($_.percentprocessortime -ne 0) -and ($_.idprocess -ne 0))}| Select IdProcess, PercentProcessorTime

# Since Win32_PerfFormattedData_PerfProc_Process doesn't provide
# owner information, loop through list & query Win32_Process
foreach($obj in $HighProcPids){
    $tmpProcess = gwmi Win32_Process -Filter ([string]::Format("ProcessId=`'{0}`'",$obj.IdProcess))
    $tmpObj = New-Object System.Object
    Add-Member -InputObject $tmpObj -MemberType NoteProperty -Name "Owner" -Value $tmpProcess.getowner().user
    Add-Member -InputObject $tmpObj -MemberType NoteProperty -Name "PID" -Value $obj.IdProcess
    Add-Member -InputObject $tmpObj -MemberType NoteProperty -Name "Name" -Value $tmpProcess.ProcessName
    Add-Member -InputObject $tmpObj -MemberType NoteProperty -Name "CPU" -Value $obj.PercentProcessorTime
    Add-Member -InputObject $tmpObj -MemberType NoteProperty -Name "Cmdline" -Value $tmpProcess.CommandLine
    $CustObj += $tmpObj
}

Send-MailMessage -SmtpServer "smtp.domain.com" -To "admin@domain.com" -From ($env:computername+"@domain.com") -Subject "High CPU on $env:computername" -Body ($CustObj | Format-List * | Out-String)
Exit
