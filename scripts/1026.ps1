Function Get-Proxy()
{
Process
{
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = "(cn=$_)"
$objSearcher.SearchScope = "Subtree"
$objUser = $objSearcher.FindOne()
[String]$DN = $objUser.properties.distinguishedname
$UserObj = [ADSI]"LDAP://$DN"
[String]$displayname = $UserObj.displayname
[String]$exchalias = $UserObj.mailnickname
[Array]$exchproxy = $UserObj.proxyaddresses
$displayname
$exchalias
ForEach($proxy In $exchproxy)
{
$proxy
}
}
}
[String]$UserCN = "bricep"
$UserCN | Get-Proxy
