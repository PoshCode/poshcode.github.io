<# 	   .SYNOPSIS
        WMI Events Handler
	   .DESCRIPTION
		Handles WMI Events Based on Queries
       .PARAMETER
		
       .INPUTS
	   $computername, $Query
			$Query = "select * from __instanceCreationEvent within 10 where targetInstance isa 'win32_Process' and targetInstance.name = 'Firefox.exe'"
			$Query = "select * from __instanceCreationEvent within 10 where targetInstance isa 'win32_Process'"
			$Query = "select * from __instanceDeletionEvent within 10 where targetInstance isa 'win32_Process' and targetInstance.ProcessID = '1143'"
	   .OUTPUTS
	   .NOTES
        Name: Get-WMIEvent
        Author: Steve Jarvi
        DateCreated: 10 Sept 2013
	   .EXAMPLE
    #>
Function Get-WMIEvent {
param (
[string]$computername
[string]$query
)

$ManagementScope = New-Object management.ManagementScope("\\$computername\root\cimv2")
$Eventwatcher = New-Object management.managementEventWatcher($ManagementScope, $Query)

$Event = $Eventwatcher.waitForNextEvent()
$Event.targetinstance
$Eventwatcher.start()
}
