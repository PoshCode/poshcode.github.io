<#
.EXAMPLE  
    Get-GPO -Name TestOU | Get-GPOLinkedOrganizationalUnits
#>
Function Get-GPOLinkedOrganizationalUnits {
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)][Microsoft.GroupPolicy.Gpo]$GPO
    )

    Get-ADOrganizationalUnit -Filter { LinkedGroupPolicyObjects -eq $gpo.Path }
}
