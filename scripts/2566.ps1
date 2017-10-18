function Write-Log {

	#region Parameters
	
		[cmdletbinding()]
		Param(
			[Parameter(ValueFromPipeline=$true,Mandatory=$true)] [ValidateNotNullOrEmpty()]
			[string] $Message,

			[Parameter()] [ValidateSet(“Error”, “Warn”, “Info”)]
			[string] $Level = “Info”,
			
			[Parameter()] [ValidateRange(1,30)]
			[Int16] $Indent = 0,

			[Parameter()]
			[IO.FileInfo] $Path = ”$env:temp\PowerShellLog.txt”,
			
			[Parameter()]
			[Switch] $Clobber,
			
			[Parameter()]
			[String] $EventLogName,
			
			[Parameter()]
			[String] $EventSource = ([IO.FileInfo] $MyInvocation.ScriptName).Name,
			
			[Parameter()]
			[Int32] $EventID = 1
			
		)
		
	#endregion

	Begin {}

	Process {
		try {			
			$msg = '{0}{1} : {2} : {3}' -f (" " * $Indent), (Get-Date -Format “yyyy-MM-dd HH:mm:ss”), $Level.ToUpper(), $Message
			
			switch ($Level) {
				'Error' { Write-Error $Message }
				'Warn' { Write-Warning $Message }
				'Info' { Write-Host ('{0}{1}' -f (" " * $Indent), $Message) -ForegroundColor White}
			}

			if ($Clobber) {
				$msg | Out-File -FilePath $Path
			} else {
				$msg | Out-File -FilePath $Path -Append
			}
			
			if ($EventLogName) {
			
				if(-not [Diagnostics.EventLog]::SourceExists($EventSource)) { 
					[Diagnostics.EventLog]::CreateEventSource($EventSource, $EventLogName) 
		        } 

				$log = New-Object System.Diagnostics.EventLog  
			    $log.set_log($EventLogName)  
			    $log.set_source($EventSource) 
				
				switch ($Level) {
					“Error” { $log.WriteEntry($Message, 'Error', $EventID) }
					“Warn”  { $log.WriteEntry($Message, 'Warning', $EventID) }
					“Info”  { $log.WriteEntry($Message, 'Information', $EventID) }
				}
			}

		} catch {
			throw “Failed to create log entry in: ‘$Path’. The error was: ‘$_’.”
		}
	}

	End {}

	<#
		.SYNOPSIS
			Writes logging information to screen and log file simultaneously.

		.DESCRIPTION
			Writes logging information to screen and log file simultaneously. Supports multiple log levels.

		.PARAMETER Message
			The message to be logged.

		.PARAMETER Level
			The type of message to be logged.
		
		.PARAMETER Indent
			The number of spaces to indent the line in the log file.

		.PARAMETER Path
			The log file path.
		
		.PARAMETER Clobber
			Existing log file is deleted when this is specified.
		
		.PARAMETER EventLogName
			The name of the system event log, e.g. 'Application'.
		
		.PARAMETER EventSource
			The name to appear as the source attribute for the system event log entry. This is ignored unless 'EventLogName' is specified.
		
		.PARAMETER EventID
			The ID to appear as the event ID attribute for the system event log entry. This is ignored unless 'EventLogName' is specified.

		.EXAMPLE
			PS C:\> Write-Log -Message "It's all good!" -Path C:\MyLog.log -Clobber -EventLogName 'Application'

		.EXAMPLE
			PS C:\> Write-Log -Message "Oops, not so good!" -Level Error -EventID 3 -Indent 2 -EventLogName 'Application' -EventSource "My Script"

		.INPUTS
			System.String

		.OUTPUTS
			No output.
	#>
}

