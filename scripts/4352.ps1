Import-Module activedirectory
$ou1 = Read-Host "Enter the name of the 1st OU"
$ou2 = Read-Host "Enter the name of the 2ed OU"
$a = get-adgroupmember -Identity $ou1 | get-aduser -properties displayname | select name, displayname
$b = get-adgroupmember -identity $ou2 | get-aduser -properties displayname | select name, displayname
Compare-Object $a $b -IncludeEqual | Out-GridView
Read-Host "Press any key to close..."
