<#
	.SYNOPSIS
		Returns information about the Processor via WMI. 

	.DESCRIPTION
		Information about the processor is returned using the Win32_Processor WMI class. 

		You can provide a single computer/server name or supply an array/list.

		Operating systems prior to Windows 7 & Server 2008 may not return accurate results due to the difference in WMI versions.

	.PARAMETER  Computers
		Single computer name, list of computers or .txt file containing a list of computers.

	.EXAMPLE
		.\Get-ProcessorInventory.ps1 -Computers (Get-Content C:\ComputerList.txt)

	.EXAMPLE
		.\Get-ProcessorInventory.ps1 -Computers Test-Server.company.com

	.EXAMPLE
		.\Get-ProcessorInventory.ps1 -Computers SERVER1.company.com,SERVER2.company.com | Format-Table -AutoSize

	.EXAMPLE
		.\Get-ProcessorInventory.ps1 -Computers SERVER1.company.com,SERVER2.company.com | Export-Csv C:\ProcInv.csv -NoTypeInformation

	.INPUTS
		System.String

	.OUTPUTS
		Selected.System.Management.ManagementObject

	.NOTES
		#=======================================================
		Author: Kevin Kirkpatrick
		Created: 4/16/14

		Disclaimer: This script comes with no implied warranty or guarantee and is to be used at your own risk. It's recommended that you TEST
		execution of the script against Dev/Test before running against any Production system. 

		#========================================================

	.LINK 
		https://github.com/vN3rd/PowerShell-Scripts

	.LINK
		about_WMi

	.LINK
		about_Wmi_Cmdlets
#>

#Requires -Version 3

[cmdletbinding()]
Param (
	[parameter(Mandatory = $true,
			   ValueFromPipeline = $true,
			   HelpMessage = "Enter the name of a computer or an array of computer names")]
	[system.string[]]$Computers
)

# Set the EA preference to 'Stop' so that Non-Terminating errors will be caught and displayed in the catch block
$ErrorActionPreference = "Stop"

# Cycle through each computer and attempt to query WMI
foreach ($C in $Computers)
{
	# Create counter variable and increment by 1 for each item in the collection
	$i++
	
	# Test the connection to the computer, if it pings, continue on with the query
	if (Test-Connection -ComputerName $C -Count 1 -Quiet)
	{
		try
		{
			# Check the current OS and write a warning if a legacy OS is being scanned
			[string]$OSCheck = (Get-WmiObject -Query "SELECT Caption FROM win32_operatingsystem" -ComputerName $C).caption
			
			if (($OSCheck -like "*7*") -or ($OSCheck -like "*8*") -or ($OSCheck -like "*12*")) { }
			else { Write-Warning -Message "$C is running '$OSCheck', which may return inaccurate results" }
			
			#region FormattingHashTables
			#================================
			
			# Attempt to differentiate if the destination is a VM, or not. In VMware, vProcessors typically return a value of 0 for the L2 Processor Cache.
			# This was not testing with Hyper-V
			$Type = @{
				label = 'Type'
				expression = {
					if ($_.L2CacheSize -eq '0') { "Virtual" }
					else { "Physical" }
				}
			}# end $Type
			
			# Check to see if HyperThreading is enabled by comparing the number of logical processors with the number of cores
			$HyperThreading = @{
				label = 'HyperthreadingEnabled'
				expression = {
					if ($_.NumberOfLogicalProcessors -gt $_.NumberOfCores) { "Yes" }
					elseif ($_.NumberOfLogicalProcessors -eq $null) { "Required WMI Properties Not Available in OS"}
					else { "No" }
				}
			}# end $HyperThreading
			
			# Use hash tables to modify the paramter output names
			$ComputerName = @{ label = 'Computer'; Expression = { $_.PSComputerName } }
			$CoreCount = @{ label = 'CoreCount'; Expression = { $_.NumberOfCores } }
			$LogicalCores = @{ label = 'LogicalProcessors'; expression = { $_.NumberOfLogicalProcessors } }
			$Description = @{ label = 'Description'; Expression = { $_.Name } }
			$Socket = @{ label = 'Socket'; expression = { $_.SocketDesignation } }
			#================================
			#endregion
			
			# Run the query
			Get-WmiObject -Query "SELECT * FROM win32_processor" -ComputerName $C |
			Select-Object $ComputerName, $Socket, $CoreCount, $LogicalCores, $HyperThreading, $Description, $Type
			
			
			
		}# end try
		
		catch
		{
			# Catch any errors and write a warning that includes the computer name as well as the error message, which is stored in $_
			Write-Warning "$C - $_"
		}# end catch
		
	}# end if
	
	else
	{
		# If the computer was not reachable on the network, display such detail
		Write-Warning "$C is unreachable"
		
	}# end else
	
	# Write total progress to progress bar
	$TotalComputers = $Computers.Length
	$PercentComplete = [int](($i / $TotalComputers) * 100)
	Write-Progress -Activity "Working on $C..." -CurrentOperation "$PercentComplete% Complete" -Status "Percent Complete" -PercentComplete $PercentComplete
	
}# end foreach
