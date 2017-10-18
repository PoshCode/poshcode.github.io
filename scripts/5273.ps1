#this is the account
$accountName = "BLA\user"

#this cruft here is so that we get UPN for the WindowsIdentity conscturctor
add-type -AssemblyName System.DirectoryServices.AccountManagement
$pc = new-object System.DirectoryServices.AccountManagement.PrincipalContext Domain,$env:USERDOMAIN
$p = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($pc,$accountName)

#and finally
$wi = new-object System.Security.Principal.WindowsIdentity $p.UserPrincipalName
$wp = [System.Security.Principal.WindowsPrincipal]$wi
$wp.IsInRole("Administrators")

