#Script Author Information
$script:ProgramName = "Forest FSMO"
$script:ProgramDate = "11 Dec 2013"
$script:ProgramAuthor = "Geoffrey Guynn"
$script:ProgramAuthorEmail = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String("Z2VvZmZyZXlAZ3V5bm4ub3Jn"))

$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$ChildDomains = $Forest.Domains
$SchemaRole = $Forest.SchemaRoleOwner
$NamingRole = $Forest.NamingRoleOwner

$DomainObjects = @()

$ChildDomains | % {

    $CurrentDomain = $_
    
    $objDomain = $CurrentDomain | Select Name, Forest, PDCRoleOwner, RidRoleOwner, InfrastructureRoleOwner
    $objDomain | Add-Member -MemberType NoteProperty -Name SchemaRole -Value $SchemaRole
    $objDomain | Add-Member -MemberType NoteProperty -Name NamingRole -Value $NamingRole
    
    $DomainObjects += $objDomain
}

$DomainObjects
