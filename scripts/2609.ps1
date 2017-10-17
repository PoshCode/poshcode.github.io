function Initialize-WindowsInstallPoint {
<#
	.SYNOPSIS
		Initializes a drive to become a Windows OS install point.
		
	.DESCRIPTION
		The Initialize-WindowsInstallPoint function uses the "diskpart" utility to wipe, partition, and format a local or removable drive.
		The "bootsect" tool processes the bootmgr allowing the drive to become a bootable device from which Windows can be installed.
		Once the drive is initialized, copy the entire contents of the Windows install media to the drive.
		Windows Vista, 7, Server 2008, and Server 2008 R2 are supported.
	
	.PARAMETER Drive
		Specifies the drive to initialize as a Windows install point.
		<DriveLetter:>
	
	.PARAMETER BootsectPath
		The full file path to the "bootsect.exe" tool. For Windows versions 6.x, it's located on the installation media in the "boot" folder.
	
	.PARAMETER DiskpartPath
		The full file path to the "diskpart.exe" tool. Default parameter value: $env:SystemRoot\System32\diskpart.exe

	.EXAMPLE
		Initialize-WindowsInstallPoint X: D:\boot\bootsect.exe
		Initializes drive X: using the bootsect.exe tool located in the boot folder of drive D:
	
	.INPUTS
		System.String
	
	.OUTPUTS
		None
	
	.NOTES
		Name: Initialize-WindowsInstallPoint
		Author: Rich Kusak (rkusak@cbcag.edu)
		Created: 2009-10-24
		Last Edit: 2011-04-07 18:48
		Version: 1.7.0.0
		
		#Requires Version 2.0

	.LINK
		bootsect.exe

	.LINK
		diskpart.exe
#>

	[CmdletBinding(ConfirmImpact='High', SupportsShouldProcess=$true)]
	param (
		[Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true,
			HelpMessage='The drive qualifier of the device to become a Windows install point.'
		)]
		[ValidateScript({
			switch ($_) {
				$env:SystemDrive {throw 'This operation cannot be performed on the system drive.'}
				{$_ -match '^[a-z]:$'} {$true}
				default {throw "The argument '$_' is not a valid drive designation. Supply an argument that matches '<DriveLetter>:' and try the command again."}
			}
		})]
		[string]$Drive,
		
		[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,
			HelpMessage='The full path to the bootsect.exe tool.'
		)]
		[Alias('FullName')]
		[ValidateScript({
			if (Test-Path $_ -Include '*bootsect.exe') {$true} else {
				throw "The argument '$_' is not a real path to the bootsect.exe tool."
			}
		})]
		[string]$BootsectPath,
		
		[Parameter(ValueFromPipelineByPropertyName=$true,
			HelpMessage='The full path to the diskpart.exe tool.'
		)]
		[ValidateScript({
			if (Test-Path $_ -Include '*diskpart.exe') {$true} else {
				throw "The arguments '$_' is not a real path to the diskpart.exe tool."
			}
		})]
		[string]$DiskpartPath = "$env:SystemRoot\System32\diskpart.exe"
	)

	begin {
		
		function Test-Elevation {
			$admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
			$identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
			$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)

			$principal.IsInRole($admin)
		}
		
		# Test that PowerShell is running as an administrator
		if (-not (Test-Elevation)) {
			throw 'Administrator privileges are required. PowerShell is not running as an administrator.'
		}
		
		$dpExitCodes = @{
			0 = 'No error occurred. The entire script ran without failure.'
			1 = 'A fatal exception occurred. There may be a serious problem.'
			2 = 'The arguments specified on a Diskpart command line were incorrect.'
			3 = 'Diskpart was unable to open the specified script or output file.'
			4 = 'One of the services Diskpart uses returned a failure.'
			5 = 'A command syntax error occurred. The script failed because an object was improperly selected or was invalid for use with that command.'
		}
		
		# Temporary files for the diskpart script and redirect standard output
		$dpScript = [System.IO.Path]::GetTempFileName()
		$rso = [System.IO.Path]::GetTempFileName()
		
		# Set the initial instance of the variable used to control the flow of $psCmdlet
		$psc = $null
	} # end begin
	
	process {
		
		# Capitalize drive letter for display
		$Drive = $Drive.ToUpper()
		
		# Detrimine if the drive meets the requirements to become a Windows install point
		Write-Debug 'Getting WMI object Win32_LogicalDisk'
		$logicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = '$Drive' "

		if ($logicalDisk.DriveType -notmatch '^(2|3)$') {
			return Write-Error "Drive '$Drive' is not a local or removable drive." -TargetObject $Drive
		} elseif ($logicalDisk.Size -lt 3.5GB) {
			# Different Windows editions vary in size but a drive 3.5GB or greater should accomidate all editions
			Write-Warning "Drive '$Drive' may not be large enough for Windows installation files."
		}

		if ($psc -eq $null) {$psc = $psCmdlet}
		if ($psc.ShouldProcess($Drive, "Initialize Windows install point. Any existing data will be DESTROYED")) {
			Write-Progress -Activity 'Initialize Windows Install Point' -Status "Drive $Drive" -CurrentOperation 'Preparing disk volume' -PercentComplete 0
			
			# Diskpart script content
			@"
				Select Volume $($Drive[0])
				Clean
				Create Partition Primary
				Select Partition 1
				Active
				Format Quick FS=NTFS Label=WindowsInstallPoint
				Assign Letter $Drive
				Exit
"@ | Out-File $dpScript -Encoding ASCII -Force

			Write-Debug 'Starting process diskpart.exe'
			# Using Start-Process allows the exit code to be processed from either the console or ISE.
			$diskpart = Start-Process $DiskpartPath "/s $dpScript" -NoNewWindow -Wait -PassThru -RedirectStandardOutput $rso

			1..45 | ForEach {
				Write-Progress -Activity 'Initialize Windows Install Point' -Status "Drive $Drive" -CurrentOperation 'Preparing disk volume' -PercentComplete $_
				Sleep -Milliseconds 20
			}
			
			# Removes empty lines from the original diskpart.exe output and sends it to the verbose stream
			Get-Content $rso | Select-String '.' | ForEach {Write-Verbose $_}
			
			# Diskpart error handling
			if ($diskpart.ExitCode -eq 0) {
				Write-Verbose "Drive '$Drive' has been successfully processed by the diskpart.exe tool."
			} elseif ($diskpart.ExitCode -gt 0) {
				return Write-Error $dpExitCodes.($diskpart.ExitCode)
			} else {
				return Write-Error 'An unknown error occured.'
			}
			
			Write-Debug 'Starting process bootsect.exe'
			# Using Start-Process allows the exit code to be processed from either the console or ISE.
			$bootsect = Start-Process $BootsectPath "/NT60 $Drive" -NoNewWindow -Wait -PassThru -RedirectStandardOutput $rso

			46..90 | ForEach {
				Write-Progress -Activity 'Initialize Windows Install Point' -Status "Drive $Drive" -CurrentOperation 'Setting boot code' -PercentComplete $_
				Sleep -Milliseconds 20
			}

			# Removes empty lines from the original bootsect.exe output and sends it to the verbose stream
			Get-Content $rso | Select-String '.' | ForEach {Write-Verbose $_}

			# Bootsect error handling
			if ($bootsect.ExitCode -eq 0) {
				Write-Verbose "Drive '$Drive' has been successfully processed by the bootsect.exe tool."
				Write-Progress -Activity 'Initialize Windows Install Point' -Status "Drive $Drive" -CurrentOperation 'Complete' -PercentComplete 100
				Sleep -Seconds 1
			} else {
				return Write-Error "$bootsect"
			}
		} # end ShouldProcess
		
		Write-Verbose "Drive '$Drive' has been successfully initialized as a Windows install point."
	} # end process

	end {
		
		# Cleanup temporary files
		Remove-Item $dpScript, $rso -Force -WhatIf:$false
	}
} # end function Initialize-WindowsInstallPoint
