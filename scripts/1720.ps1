function Get-ParameterEnum
{
<#
.Synopsis
    Displays enumeration values for specific parameter.
.Description
    For provided combination of cmdlet/parameter displays all possible values. Parameter has to be
    enumeration type. Displays also numeric value and enumeration name.
.Parameter Cmdlet
    Name of the cmdlet.
.Parameter Parameter
    Name of the parameter you need to check.
.Example
    Get-ParameterEnum -Cmdlet dir -Parameter ErrorAction
    
    0: SilentlyContinue
    1: Stop
    2: Continue
    3: Inquire
    
.Example
    Get-ParameterEnum write-host ForegroundColor
    
    System.ConsoleColor
    0: Black
    1: DarkBlue
    2: DarkGreen
    3: DarkCyan
    4: DarkRed
    5: DarkMagenta
    6: DarkYellow
    7: Gray
    8: DarkGray
    9: Blue
    10: Green
    11: Cyan
    12: Red
    13: Magenta
    14: Yellow
    15: White 
    
.Link
    http://msdn.microsoft.com/en-us/library/system.enum.aspx           
#>

    param (
        [Parameter(Mandatory=$true,Position=0)]
            [string]$Cmdlet,
            
        [Parameter(Mandatory=$true,Position=1)]
            [string]$Parameter
    )

    $parameterClass = "((Get-Command $cmdlet).Parameters.$parameter.ParameterType).ToString()"
    Invoke-Expression $parameterClass
    Invoke-Expression "[Enum]::GetValues($parameterClass)" | % {"$($_.value__): $_"}
}
