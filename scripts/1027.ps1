Function ConvertUser
{
Process
{
ForEach($User In $_)
{
$strFilter = “(&(objectCategory=user)(displayName=$User))”
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = “Subtree”
$colUsers = $objSearcher.FindOne()
ForEach($objUser in $colUsers)
{
$objUser.properties.cn
}
}
}
}
Get-Content “C:\Scripts\Users.txt” | ConvertUser | Out-File “C:\Scripts\ConvertedUsers.txt”
