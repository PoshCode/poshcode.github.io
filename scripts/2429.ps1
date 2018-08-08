# Windows Scheduled Tasks Management PowerShell Module
# http://powershell.codeplex.com

Function Get-ScheduledTasks
{
	[CmdletBinding()]
	param (
		[ValidateNotNullOrEmpty()]
		[string] $TaskName,
		[string] $HostName )
	
	process
	{
		if ( $HostName ) { $HostName = "/S $HostName" }
		$ScheduledTasks = SCHTASKS.EXE /QUERY /FO CSV /NH $HostName
		foreach ( $Item in $ScheduledTasks )
		{
			if ( $Item -ne "" )
			{
				$Item = $Item -replace("""|\s","")
				$SplitItem = $Item -split(",")
				$ScheduledTaskName = $SplitItem[0]
				$ScheduledTaskStatus = $SplitItem[3]
				if ( $ScheduledTaskName -ne "" )
				{
					if ( $ScheduledTaskStatus -eq "" )
					{
						$ScheduledTaskStatus = "Not Running"
					}
					else
					{
						$ScheduledTaskStatus = "Running"
					}
					$objScheduledTaskName = New-Object System.Object
	    			$objScheduledTaskName | Add-Member -MemberType NoteProperty -Name TaskName -Value $ScheduledTaskName
					$objScheduledTaskName | Add-Member -MemberType NoteProperty -Name TaskStatus -Value $ScheduledTaskStatus
					$objScheduledTaskName | Where-Object { $_.TaskName -match $TaskName }
				}
			}
		}
	}
}
Function Start-ScheduledTask
{
	[CmdletBinding()]
	param (
		[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
		[string] $TaskName,
		[string] $HostName )

	process
	{
		if ( $HostName ) { $HostName = "/S $HostName" }
		SCHTASKS.EXE /RUN /TN $TaskName $HostName
	}
}
Function Stop-ScheduledTask
{
	[CmdletBinding()]
	param (
		[ValidateNotNullOrEmpty()]
		[Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
		[string] $TaskName,
		[string] $HostName )

	process
	{
		if ( $HostName ) { $HostName = "/S $HostName" }
		SCHTASKS.EXE /END /TN $TaskName $HostName
	}
}
Export-ModuleMember Get-ScheduledTasks, Start-ScheduledTask, Stop-ScheduledTask
