function Get-MonthAccountCreated {
    <#
    .SYNOPSIS
    Gets Account created in given month.
    .DESCRIPTION
    Gets Account created in given month.
    
    .EXAMPLE 
    Get-MonthAccountCreated -Month 2 -Year 2012
    .EXAMPLE
    Get-MonthAccountCreated -Month 10 -Year 2012
        
    .PARAMETER Month
    Month as number.
    .PARAMETER YEAR
    Year
    #>
    [cmdletBinding()]
    param(
        [Parameter(mandatory=$True)]
        [ValidateRange(1,12)]
        [int]$Month,
        [Parameter(mandatory=$True)]
        [ValidateRange(1990,2020)]
        [int]$Year
    )
 
    BEGIN {}
    PROCESS {
        $mbx = Get-Mailbox -ResultSize Unlimited
        $result = $mbx | Where-Object { ($_.WhenCreated).Month -eq $month -and ($_.WhenCreated).year -eq $year } | Select-Object Name, WhenCreated 
        $result
        }
    
    END{}
}
