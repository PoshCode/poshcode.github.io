function Out-CliXml
{
<#
.SYNOPSIS
Creates an XML-based representation of an object or objects and outputs it as a string.

.DESCRIPTION
The Out-Clixml cmdlet creates an XML-based representation of an object or objects and outputs it as a string. This cmdlet is similar to Export-CliXml except it doesn't output to a file.

.PARAMETER Depth
Specifies how many levels of contained objects are included in the XML representation. The default value is 2.

.PARAMETER InputObject
Specifies the object to be converted. Enter a variable that contains the objects, or type a command or expression that gets the objects. You can also pipe objects to Out-Clixml.

.INPUTS
System.Management.Automation.PSObject

You can pipe any object to Out-Clixml.

.OUTPUTS
System.String

.EXAMPLE
PS C:\> Get-Process -Id $PID | Out-CliXml

Description
-----------
Outputs the XML-based representation of the PowerShell process.
#>
    [CmdletBinding()] Param (
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]
        $Depth = 2,

        [Parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [PSObject]
        $InputObject
    )

    PROCESS
    {
        [System.Management.Automation.PSSerializer]::Serialize($InputObject, $Depth)
    }
}
