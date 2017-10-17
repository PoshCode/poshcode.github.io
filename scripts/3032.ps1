#region Log File Management 
$ScriptName = $MyInvocation.mycommand.name 
$LocalAppDir = "$(gc env:LOCALAPPDATA)\PS_Data" 
$LogName = $ScriptName.replace(".ps1", ".log") 
$MaxLogFileSizeMB = 5 # After a log file reaches this size it will archive the existing and create a new one 

trap
[Exception] { 
sendl
"error: $($_.Exception.GetType().Name) - $($_.Exception.Message)" 
} 
function LogFileCheck 
{
if (!(Test-Path $LocalAppDir)) # Check if log file directory exists - if not, create and then create log file for this script. 
{
mkdir $LocalAppDir 
New-Item "$LocalAppDir\$LogName" -type file 
break 
}
if
(Test-Path "$LocalAppDir\$LogName") {
if (((gci "$LocalAppDir\$LogName").length/1MB) -gt $MaxLogFileSizeMB) # Check size of log file - to stop unweildy size, archive existing file if over limit and create fresh. 
{
$NewLogFile = $LogName.replace(".log", " ARCHIVED $(Get-Date -Format dd-MM-yyy-hh-mm-ss).log") 
ren "$LocalAppDir\$LogName" "$LocalAppDir\$NewLogFile" 
}
}
}
function sendl ([string]$message) # Send to log file 
{
$toOutput
= "$(get-date) > $message " | Out-File "$LocalAppDir\$LogName" -append -NoClobber 
}
LogFileCheck
#endregion Log File Management
