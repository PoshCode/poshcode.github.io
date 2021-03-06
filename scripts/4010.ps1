#######################
<#
.SYNOPSIS
Gets HP PSP/SPP Agent Version
.DESCRIPTION
The Get-HPAgentVersion function gets the HP PSP/SPP version.
.EXAMPLE
Get-HPAgentVersion "Z002"
This command gets information for computername Z002.
.EXAMPLE
Get-Content ./servers.txt | Get-HPAgentVersion
This command gets information for a list of servers stored in servers.txt.
.EXAMPLE
Get-HPAgentVersion (get-content ./servers.txt)
This command gets information for a list of servers stored in servers.txt.
.NOTES 
Version History 
v1.0   - Chad Miller - Initial release 
#>
function Get-HPAgentVersion
{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullorEmpty()]
    [string[]]$ComputerName
    )
    BEGIN {}
    PROCESS {
        foreach ($computer in $computername) {
            Get-WMIObject -ComputerName $computer -Query "SELECT * FROM CIM_DataFile WHERE Drive ='C:' AND Path='\\WINDOWS\\system32\\CpqMgmt\\' AND FileName='agentver' AND Extension='dll'"  |
            Select CSName, Version, @{n='OS';e={(gwmi win32_operatingsystem -ComputerName $_.CSName).Version}}
        }
    }
    END {}
}

