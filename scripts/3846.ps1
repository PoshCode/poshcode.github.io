# ############################################################################# 
# NAME: FUNCTION-Get-LocalGroupMembership.ps1 
#  
# AUTHOR:	Francois-Xavier Cat 
# DATE:		2012/12/27 
# EMAIL:	fxcat@lazywinadmin.com
# WEBSITE:	LazyWinAdmin.com
# TWiTTER:	@lazywinadm
#  
# COMMENT:	This function get the local group membership on a local or remote  
#			machine using ADSI/WinNT. By default it will run on the localhost 
#			and check the group "Administrators".
# 
# VERSION HISTORY 
# 1.0 2012.12.27 Initial Version. 
#
# ############################################################################# 

Function Get-LocalGroupMembership {
<#
        .Synopsis
            Get the local group membership.
            
        .Description
            Get the local group membership.
            
        .Parameter ComputerName
            Name of the Computer to get group members. Default is "localhost".
            
        .Parameter GroupName
            Name of the GroupName to get members from. Default is "Administrators".
            
        .Example
            Get-LocalGroupMembership
            Description
            -----------
            Get the Administrators group membership for the localhost
            
        .Example
            Get-LocalGroupMembership -ComputerName SERVER01 -GroupName "Remote Desktop Users"
            Description
            -----------
            Get the membership for the the group "Remote Desktop Users" on the computer SERVER01

        .OUTPUTS
            PSCustomObject
            
        .INPUTS
            Array
            
        .Link
            N/A
        
        .Notes
            NAME:      Get-LocalGroupMembership
            AUTHOR:    Francois-Xavier Cat
            WEBSITE:   www.LazyWinAdmin.com
    #>
	
	[Cmdletbinding()]
	Param (
		[Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
		[string]$ComputerName = $env:COMPUTERNAME,
		
		[string]$GroupName = "Administrators"
		)
	
	# Create the array that will contains all the output of this function
	$Output = @()
	
	# Get the members for the group and computer specified
	$Group = [ADSI]"WinNT://$ComputerName/$GroupName" 
	$Members = @($group.psbase.Invoke("Members"))

	# Format the Output
	$members | foreach {
		$name = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
		$class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
		$path = $_.GetType().InvokeMember("ADsPath", 'GetProperty', $null, $_, $null)
		
		# Find out if this is a local or domain object
		if ($path -like "*/$ComputerName/*"){
			$Type = "Local"
			}
		else {$Type = "Domain"
		}
		
		$Details = "" | Select ComputerName,Account,Class,Group,Path,Type
		$Details.ComputerName = $ComputerName
		$Details.Account = $name
		$Details.Class = $class
        $Details.Group = $GroupName
		$details.Path = $path
		$details.Type = $type
		
		# Send the current result to the $output variable
		$output = $output + $Details
	}
	# Finally show the Output to the user.
	$output
}
