<#
.SYNOPSIS
    Demonstrates uptime using WMI 
.DESCRIPTION
    This script used Win32_ComputerSystem to determine how long your system
    has been running. This is a rewrite/improvement of sample 3 at
    http://msdn.microsoft.com/en-us/library/aa394591(VS.85).aspx. 
.NOTES
    File Name : Get-UpTime.ps1
    Author : Thomas Lee - tfl@psp.co.uk
    Requires : PowerShell V2 CTP3
.LINK
    Script Posted to: 
    http://www.pshscripts.blogspot.com
    Original sample posted at:
    http://msdn.microsoft.com/en-us/library/aa394591(VS.85).aspx
.EXAMPLE
    PS c:\foo> .\Get-UpTime.Ps1
    System Up for: 1 days, 8 hours, 40.781 minutes

#>

##
#  Start of script
##

# Helper Function - convert WMI date to TimeDate object
function WMIDateStringToDate($Bootup) {
	[System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup)
}

# Main script
$Computer = "." # adjust as needed
$computers = Get-WMIObject -class Win32_OperatingSystem -computer $computer

# There had better only be one object returned, but...
foreach ($system in $computers) {
# work out uptime
	$Bootup = $system.LastBootUpTime
	$LastBootUpTime = WMIDateStringToDate($Bootup)
	$now = Get-Date
	$Uptime = $now - $lastBootUpTime
	$d = $Uptime.Days
	$h = $Uptime.Hours
	$m = $uptime.Minutes
	$ms= $uptime.Milliseconds
# Display uptime
	"System Up for: {0} days, {1} hours, {2}.{3} minutes" -f $d,$h,$m,$ms
} 
# End script
