
## .\SharePoint_Users_Read.ps1 "http://some.urlname.com/" "User Information List" ""
## .\SharePoint_Users_Read.ps1 "http://some.urlname.com/" "User Information List" "user, someone"

param(
[string] $rqurdstrPath = $(Throw "--SharePoint Core Path required."), #required parameter
[string] $rqurdstrListName = $(Throw "--SharePoint List Name required."), #required parameter
[string] $strTargetUser = "" #non-required user name for ID Return
)

Write-Host "Beginning Processing--`n"


## Global Variables ##
$strUserIDReturn = ""

write-host "rqurdstrPath: $rqurdstrPath "
write-host "rqurdstrListName: $rqurdstrListName "

## Load SharePoint .NET Libraries ##
[void][System.reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$site = new-object Microsoft.SharePoint.SPSite($rqurdstrPath)
$userlist = $site.RootWeb.Lists[$rqurdstrListName]

write-host "site: $site "
write-host "userlist: $userlist`n"

# Print the ID and Title of each list item  #$userlist.Items | Format-List -property ID, Title
if($strTargetUser -eq "") {
	Write-Host "--Displaying all Portal Users"
	foreach($strItem in $userlist.Items) {
		[string]$strItem.ID + "--"+$strItem.Title
	}
}
else {
	write-host "--Targeting specific user to return ID"	
	$intUserIDReturn = -1
	
	foreach($strItem in $userlist.Items) {
		$intUserID=[int]$strItem.ID
		$strUserName=$strItem.Title
		if($strUserName -eq $strTargetUser) {
			$intUserIDReturn = $intUserID
			break;
		}
	}
	$intUserIDReturn
}

## NOTE: don't forget to dispose your .NET objects! ##
$site.RootWeb.Dispose()
$site.Dispose()



## End Processing ##
Write-Host "`nEnd Processing--`n"
