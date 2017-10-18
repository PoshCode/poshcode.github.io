# Requires a connection to Exchange Server, or Exchange Management Shell

$s = New-PSSession -ConfigurationName Microsoft.Exchange -Name ExchMgmt -ConnectionUri http://ex14.domain.local/PowerShell/ -Authentication Kerberos
Import-PSSession $s

# Get all Client Access Server properties for all mailboxes with an ActiveSync Device Partnership
$Mailboxes = Get-CASMailbox -Filter {HasActivesyncDevicePartnership -eq $true} -ResultSize Unlimited

# Get DeviceID for all mailboxes
$EASMailboxes = $Mailboxes | Select-Object PrimarySmtpAddress,@{N='DeviceID';E={Get-ActiveSyncDeviceStatistics -Mailbox $_.Identity | Select-Object –ExpandProperty DeviceID}}

# Set the ActiveSyncAllowedDeviceIDs attribute of all Mailboxes
$EASMailboxes | foreach {Set-CASMailbox $_.PrimarySmtpAddress -ActiveSyncAllowedDeviceIDs $_.DeviceID}
