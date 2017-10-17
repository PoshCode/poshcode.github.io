function Delete-ADUser
{
	Param($userName = $(throw 'Enter a username to delete'))
	$searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"","(&(objectcategory=user)(sAMAccountName=$userName))")
	$user = $searcher.findone().GetDirectoryEntry()
	$user.psbase.DeleteTree()
}


$NumDays = 90
$LogDir = ".\Removed-User-Accounts.log"

$currentDate = [System.DateTime]::Now
$currentDateUtc = $currentDate.ToUniversalTime()
$lltstamplimit = $currentDateUtc.AddDays(- $NumDays)
$lltIntLimit = $lltstampLimit.ToFileTime()
$adobjroot = [adsi]''
$objstalesearcher = New-Object System.DirectoryServices.DirectorySearcher($adobjroot)
$objstalesearcher.filter = "(&(objectCategory=person)(objectClass=user)(lastLogonTimeStamp<=" + $lltIntLimit + "))"
$users = $objstalesearcher.findone()

Write-Output `n`n"----------------------------------------" "ACCOUNTS OLDER THAN "$NumDays" DAYS" "PROCESSED ON:" $currentDate "----------------------------------------" `
| Out-File $LogDir -append

if ($users.Count -eq 0)
{
       Write-Output "  No account needs to be removed." | Out-File $LogDir -append
}
else
{
       foreach ($user in $users)
       {
              # Read the user properties
              [string]$adsPath = $user.Properties.adspath
              [string]$displayName = $user.Properties.displayname
              [string]$samAccountName = $user.Properties.samaccountname
              [string]$lastLogonInterval = $user.Properties.lastlogontimestamp
 
              # Delete the user
              Delete-ADUser $samAccountName
 
              # Convert the date and time to the local time zone
              $lastLogon = [System.DateTime]::FromFileTime($lastLogonInterval)
             
              Write-Output "  Removed user " $displayName" | Username: "$samAccountName" | Last Logon: "$lastLogon"`n" `
			  | Out-File $LogDir -append
       }
}

