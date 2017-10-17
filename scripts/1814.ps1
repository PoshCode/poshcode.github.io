$server = "dcserver1.mafoberg.net"
$session = new-pssession -computer $server -cred $creds

icm -Session $session -ScriptBlock {
    import-module activedirectory
    (get-ADUser -filter "*" -properties GivenName, SurName, EmailAddress | select -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName )
    
} | select -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName

Remove-PSSession $session

#####output####
PSComputerName     : dcserver1.mafoberg.net
RunspaceId         : ebb3ebe0-7ad6-4a0e-ab33-63b29fb9890f
PSShowComputerName : True
DistinguishedName  : CN=taland,OU=swteknikere,OU=Teknikere,DC=mafoberg,DC=net
EmailAddress       : 
Enabled            : True
GivenName          : Talbe
Name               : taland
ObjectClass        : user
ObjectGUID         : 7a675f74-db4c-4015-9a50-12e2624daf5c
SamAccountName     : taland
SID                : S-1-5-21-146981098-1029485922-1443047703-1180
Surname            : Andar
UserPrincipalName  : 
