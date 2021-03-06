
param ($LDAPPath = "", [switch]$Help)

if ($Help)
{
	""
	Write-Host "Usage: .\Get-ADNonExpPass.ps1 <LDAPPath>" -foregroundcolor Yellow
	Write-Host "Ex: .\Get-ADNonExpPass.ps1 'LDAP://ou=users,dc=domain,dc=com'" -foregroundcolor Yellow
	""
	break
}

#UAC Flag in Hex
#http://support.microsoft.com/kb/305144
$DontExpire = 0x10000

$Root = [ADSI]$LDAPPath

$Category = "user"

$Selector = New-Object DirectoryServices.DirectorySearcher
$Selector.SearchRoot = $Root 
$Selector.Filter = ("(objectCategory=$Category)")
#$Selector.pagesize = 2000

# Grab all the user objects for the OU
$Users = $Selector.findall()

foreach ($User in $Users) {

	$DN = $User.properties.distinguishedname
	$UserProp = [ADSI]"LDAP://$dn"
	
	if (($UserProp.UserAccountControl[0] -band $DontExpire) -eq 65536)
		{
		$UserProp | Select Name, UserAccountControl
		}

}

