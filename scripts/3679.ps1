#requires -version 2.0
<#
################################################################################
## Run commands in multiple concurrent pipelines
##   by Arnoud Jansveld - www.jansveld.net/powershell
##
## Basic "drop in" usage examples:
##   - Functions that accept pipelined input:
##       Without Split-Job:
##          Get-Content hosts.txt | MyFunction | Export-Csv results.csv
##       With Split-Job:
##          Get-Content hosts.txt | Split-Job {MyFunction} | Export-Csv results.csv
##   - Functions that do not accept pipelined input (use foreach):
##       Without Split-Job:
##          Get-Content hosts.txt |% { .\MyScript.ps1 -ComputerName $_ } | Export-Csv results.csv
##       With Split-Job:
##          Get-Content hosts.txt | Split-Job {%{ .\MyScript.ps1 -ComputerName $_ }} | Export-Csv results.csv
##
## Example with an imported function:
##       function Test-WebServer ($ComputerName) {
##           $WebRequest = [System.Net.WebRequest]::Create("http://$ComputerName")
##           $WebRequest.GetResponse()
##       }
##       Get-Content hosts.txt | Split-Job {%{Test-WebServer $_ }} -Function Test-WebServer | Export-Csv results.csv
##
## Example with importing a module
##       Get-Content Clusters.txt | Split-Job { % { Get-Cluster -Name $_ } } -InitializeScript { Import-Module FailoverClusters }
##	
##
## Version History
## 1.2    Changes by Stephen Mills - stephenmills at hotmail dot com
##        Only works with PowerShell V2
##        Modified error output to use ErrorRecord parameter of Write-Error - catches Category Info then.
##        Works correctly in powershell_ise.  Previous version would let pipelines continue if ESC was pressed.  If Escape pressed, then it will do an async cancel of the pipelines and exit.
##        Add seconds remaining to progress bar
##        Parameters Added and related functionality:
##           InitializeScript - allows to have custom scripts to initilize ( Import-Module ...), parameter might be renamed Begin in the future.
##           MaxDuration - Cancel all pending and in process items in queue if the number of seconds is reached before all input is done.
##           ProgressInfo - Allows you to add additional text to progress bar
##           NoProgress - Hide Progress Bar
##           DisplayInterval - frequency to update Progress bar in milliseconds
##           InputObject - not yet used, planned to be used in future to support start processing the queue before pipeline isn't finished yet
##        Added example for importing a module.
## 1.0    First version posted on poshcode.org
##        Additional runspace error checking and cleanup
## 0.93   Improve error handling: errors originating in the Scriptblock now
##        have more meaningful output
##        Show additional info in the progress bar (thanks Stephen Mills)
##        Add SnapIn parameter: imports (registered) PowerShell snapins
##        Add Function parameter: imports functions
##        Add SplitJobRunSpace variable; allows scripts to test if they are
##        running in a runspace
## 0.92   Add UseProfile switch: imports the PS profile
##        Add Variable parameter: imports variables
##        Add Alias parameter: imports aliases
##        Restart pipeline if it stops due to an error
##        Set the current path in each runspace to that of the calling process
## 0.91   Revert to v 0.8 input syntax for the script block
##        Add error handling for empty input queue
## 0.9    Add logic to distinguish between scriptblocks and cmdlets or scripts:
##        if a ScriptBlock is specified, a foreach {} wrapper is added
## 0.8    Adds a progress bar
## 0.7    Stop adding runspaces if the queue is already empty
## 0.6    First version. Inspired by Gaurhoth's New-TaskPool script
################################################################################
#>

function Split-Job
{
	param (
		[Parameter(Position=0, Mandatory=$true)]$Scriptblock,
		[Parameter()][int]$MaxPipelines=10,
		[Parameter()][switch]$UseProfile,
		[Parameter()][string[]]$Variable,
		[Parameter()][string[]]$Function = @(),
		[Parameter()][string[]]$Alias = @(),
		[Parameter()][string[]]$SnapIn,
		[Parameter()][float]$MaxDuration = $( [Int]::MaxValue ),
		[Parameter()][string]$ProgressInfo ='',
		[Parameter()][int]$ProgressID = 0,
		[Parameter()][switch]$NoProgress,
		[Parameter()][int]$DisplayInterval = 300,
		[Parameter()][scriptblock]$InitializeScript,
		[Parameter(ValueFromPipeline=$true)][object[]]$InputObject
	)

	begin
	{
		$StartTime = Get-Date
		#$DisplayTime = $StartTime.AddMilliseconds( - $DisplayInterval )
		$ExitForced = $false


		 function Init ($InputQueue){
			# Create the shared thread-safe queue and fill it with the input objects
			$Queue = [Collections.Queue]::Synchronized([Collections.Queue]@($InputQueue))
			$QueueLength = $Queue.Count
			# Do not create more runspaces than input objects
			if ($MaxPipelines -gt $QueueLength) {$MaxPipelines = $QueueLength}
			# Create the script to be run by each runspace
			$Script  = "Set-Location '$PWD'; "
			$Script += {
				$SplitJobQueue = $($Input)
				& {
					trap {continue}
					while ($SplitJobQueue.Count) {$SplitJobQueue.Dequeue()}
@@				} }.ToString() + '|' + $Scriptblock
@@
			# Create an array to keep track of the set of pipelines
			$Pipelines = New-Object System.Collections.ArrayList

			# Collect the functions and aliases to import
			$ImportItems = ($Function -replace '^','Function:') +
				($Alias -replace '^','Alias:') |
				Get-Item | select PSPath, Definition
			$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
		}

		function Add-Pipeline {
			# This creates a new runspace and starts an asynchronous pipeline with our script.
			# It will automatically start processing objects from the shared queue.
			$Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($Host)
			$Runspace.Open()
			if (!$?) { throw "Could not open runspace!" }
			$Runspace.SessionStateProxy.SetVariable('SplitJobRunSpace', $True)

			function CreatePipeline
			{
				param ($Data, $Scriptblock)
				$Pipeline = $Runspace.CreatePipeline($Scriptblock)
				if ($Data)
				{
					$Null = $Pipeline.Input.Write($Data, $True)
					$Pipeline.Input.Close()
				}
				$Null = $Pipeline.Invoke()
				$Pipeline.Dispose()
			}

			# Optionally import profile, variables, functions and aliases from the main runspace
			
			if ($UseProfile)
			{
				CreatePipeline -Script "`$PROFILE = '$PROFILE'; . `$PROFILE"
			}

			if ($Variable)
			{
				foreach ($var in (Get-Variable $Variable -Scope 2))
				{
					trap {continue}
					$Runspace.SessionStateProxy.SetVariable($var.Name, $var.Value)
				}
			}
			if ($ImportItems)
			{
				CreatePipeline $ImportItems {
					foreach ($item in $Input) {New-Item -Path $item.PSPath -Value $item.Definition}
				}
			}
			if ($SnapIn)
			{
				CreatePipeline (Get-PSSnapin $Snapin -Registered) {$Input | Add-PSSnapin}
			}
			
			#Custom Initialization Script for startup of Pipeline - needs to be after other other items added.
			if ($InitializeScript -ne $null)
			{
				CreatePipeline -Scriptblock $InitializeScript
			}

			$Pipeline = $Runspace.CreatePipeline($Script)
			$Null = $Pipeline.Input.Write($Queue)
			$Pipeline.Input.Close()
			$Pipeline.InvokeAsync()
			$Null = $Pipelines.Add($Pipeline)
		}

		function Remove-Pipeline ($Pipeline)
		{
			# Remove a pipeline and runspace when it is done
			$Pipeline.RunSpace.CloseAsync()
			#Removed Dispose so that Split-Job can be quickly aborted even if currently running something waiting for a timeout.
			#Added call to [System.GC]::Collect() at end of script to free up what memory it can.
			#$Pipeline.Dispose()
			$Pipelines.Remove($Pipeline)
		}
	}

	end
	{
		


		# Main
		# Initialize the queue from the pipeline
		. Init $Input
		# Start the pipelines
		try
		{
			while ($Pipelines.Count -lt $MaxPipelines -and $Queue.Count) {Add-Pipeline}

			# Loop through the pipelines and pass their output to the pipeline until they are finished
			while ($Pipelines.Count)
			{
				# Only update the progress bar once per $DisplayInterval
				if (-not $NoProgress -and $Stopwatch.ElapsedMilliseconds -ge $DisplayInterval)
				{
					$Completed = $QueueLength - $Queue.Count - $Pipelines.count
					$Stopwatch.Reset()
					$Stopwatch.Start()
					#$LastUpdate = $stopwatch.ElapsedMilliseconds
					$PercentComplete = (100 - [Int]($Queue.Count)/$QueueLength*100)
					$Duration = (Get-Date) - $StartTime
					$DurationString = [timespan]::FromSeconds( [Math]::Floor($Duration.TotalSeconds)).ToString()
					$ItemsPerSecond = $Completed / $Duration.TotalSeconds
					$SecondsRemaining = [math]::Round(($QueueLength - $Completed)/ ( .{ if ($ItemsPerSecond -eq 0 ) { 0.001 } else { $ItemsPerSecond}}))
					
					Write-Progress -Activity "** Split-Job **  *Press Esc to exit*  Next item: $(trap {continue}; if ($Queue.Count) {$Queue.Peek()})" `
						-status "Queues: $($Pipelines.Count) QueueLength: $($QueueLength) StartTime: $($StartTime)  $($ProgressInfo)" `
						-currentOperation  "$( . { if ($ExitForced) { 'Aborting Job!   ' }})Completed: $($Completed) Pending: $($QueueLength- ($QueueLength-($Queue.Count + $Pipelines.Count))) RunTime: $($DurationString) ItemsPerSecond: $([math]::round($ItemsPerSecond, 3))"`
						-PercentComplete $PercentComplete `
						-Id $ProgressID `
						-SecondsRemaining $SecondsRemaining
				}	
				foreach ($Pipeline in @($Pipelines))
				{
					if ( -not $Pipeline.Output.EndOfPipeline -or -not $Pipeline.Error.EndOfPipeline)
					{
						$Pipeline.Output.NonBlockingRead()
						$Pipeline.Error.NonBlockingRead() | % { Write-Error -ErrorRecord $_ }

					} else
					{
						# Pipeline has stopped; if there was an error show info and restart it			
						if ($Pipeline.PipelineStateInfo.State -eq 'Failed')
						{
							Write-Error $Pipeline.PipelineStateInfo.Reason
							
							# Restart the runspace
							if ($Queue.Count -lt $QueueLength) {Add-Pipeline}
						}
						Remove-Pipeline $Pipeline
					}
					if ( ((Get-Date) - $StartTime).TotalSeconds -ge $MaxDuration -and -not $ExitForced)
					{
						Write-Warning "Aborting job! The MaxDuration of $MaxDuration seconds has been reached. Inputs that have not been processed will be skipped."
						$ExitForced=$true
					}
					
					if ($ExitForced) { $Pipeline.StopAsync(); Remove-Pipeline $Pipeline }
				}
				while ($Host.UI.RawUI.KeyAvailable)
				{
					if ($Host.ui.RawUI.ReadKey('NoEcho,IncludeKeyDown,IncludeKeyUp').VirtualKeyCode -eq 27 -and !$ExitForced)
					{
						$Queue.Clear();
						Write-Warning 'Aborting job! Escape pressed! Inputs that have not been processed will be skipped.'
						$ExitForced = $true;
						#foreach ($Pipeline in @($Pipelines))
						#{
						#	$Pipeline.StopAsync()
						#}
					}		
				}
				if ($Pipelines.Count) {Start-Sleep -Milliseconds 50}
			}

			#Clear the Progress bar so other apps don't have to keep seeing it.
			Write-Progress -Completed -Activity "`0" -Status "`0"

			# Since reference to Dispose was removed.  I added this to try to help with releasing resources as possible.
			# This might be a bad idea, but I'm leaving it in for now. (Stephen Mills)
			[GC]::Collect()
		}
		finally
		{
			foreach ($Pipeline in @($Pipelines))
			{
				if ( -not $Pipeline.Output.EndOfPipeline -or -not $Pipeline.Error.EndOfPipeline)
				{
					Write-Warning 'Pipeline still runinng.  Stopping Async.'
					$Pipeline.StopAsync()
					Remove-Pipeline $Pipeline
				}
			}
		}
	}
}
