$OldServer = 'OldServer'
$NewServer = 'NewServer'
 
Import-Module ActiveDirectory
Get-ADUser -Filter "Enabled -eq 'true' -and HomeDirectory -like '*$OldServer*' -or ProfilePath -like '*$OldServer*'" -SearchBase "OU=xx,DC=xx,DC=xx,DC=xx" -Properties HomeDirectory, ProfilePath |
ForEach-Object {
    if ($_.HomeDirectory -like "*$OldServer*") {
        Set-ADUser -Identity $_.DistinguishedName -HomeDirectory $($_.HomeDirectory -replace $OldServer, $NewServer)
    }
    if ($_.ProfilePath -like "*$OldServer*") {
        Set-ADUser -Identity $_.DistinguishedName -ProfilePath $($_.ProfilePath -replace $OldServer, $NewServer)
    }
}
