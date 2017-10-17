#========================================================================
# Created By: Anders Wahlqvist
# Website: DollarUnderscore (http://dollarunderscore.azurewebsites.net)
#========================================================================

function Get-GroupStructure
{
    <#
    .SYNOPSIS
    This cmdlets exports the structure of nested groups and users.

    .DESCRIPTION
    This cmdlets exports the structure of nested groups and users, in a simliar way
    as file structures are presented.

    It requires the Active Directory module to run.

    .EXAMPLE
    Get-GroupStructure -GroupName "Domain Admins"

    .PARAMETER GroupName
    Specify the name of the "root group".

    .PARAMETER GroupPath
    Set the "start level" of the returned string. Mostly used internally, you can safely ignore this.

    #>

    param ([string] $GroupPath = '',
           [string] $GroupName)

    $GroupMembers = @()
    $GroupMembers += Get-ADGroupMember $GroupName | Sort-Object objectClass -Descending

    $LoopCount = @($GroupPath -split " \\ " | Where-Object { $_ -eq $GroupName })

    if ($LoopCount.Count -ge 2) {
        Write-Error "Nested group loop detected. Group: $GroupName"
        return;
    }

    if ($GroupPath -eq '') {
        $GroupPath = "$GroupName \ "
    }

    if ($GroupMembers.Count -eq 0) {
        Write-Output $GroupPath
    }

    foreach($GroupMember in $GroupMembers) {
        
        Remove-Variable DrilledDownGroupPath, UserPath -ErrorAction SilentlyContinue

        if ($GroupMember.objectClass -eq 'group') {
            $DrilledDownGroupPath = $GroupPath + "$($GroupMember.name) \ "
            Get-GroupStructure -GroupPath $DrilledDownGroupPath -GroupName $GroupMember.name
        }
        else {
            $UserPath = "$GroupPath$($GroupMember.Name) ($($GroupMember.SamAccountName))"
            Write-Output $UserPath
        }
    }
}
