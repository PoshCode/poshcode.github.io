$Mailboxes = Get-CASMailbox -Filter {HasActivesyncDevicePartnership -eq $true}

$EASMailboxes = $Mailboxes | Select-Object PrimarySmtpAddress,@{N='DeviceID';E={Get-ActiveSyncDeviceStatistics -Mailbox $_.Identity | Select-Object –ExpandProperty DeviceID}}

$EASMailboxes | foreach {Set-CASMailbox $_.PrimarySmtpAddress -ActiveSyncAllowedDeviceIDs $_.DeviceID}
