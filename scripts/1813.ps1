$server = "dcserver1.mafoberg.net"
$session = new-pssession -computer $server -cred $creds

icm -Session $session -ScriptBlock {
    import-module activedirectory
    (get-ADUser -filter "*" -properties GivenName, SurName, EmailAddress | select -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName )
    
} | select -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName

Remove-PSSession $session

