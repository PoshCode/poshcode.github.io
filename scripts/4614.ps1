# Checks if Quest Active Roles Management snapin is running and if not, loads it. 
if ((get-pssnapin |% {$_.name}) -notcontains "Quest.ActiveRoles.ADManagement")
{Add-PSSnapin Quest.ActiveRoles.ADManagement}

$usr = Read-Host "Enter Sam Account Name"

Get-QADMemberOf $usr | FL GroupName, Description, GroupType, GroupScope, ParentContainerDN | Out-File -Append "$usr Group Info.txt"

Start-Sleep 5

Invoke-Item "$usr Group Info.txt"

Start-Sleep 5

Del "$usr Group Info.txt"
