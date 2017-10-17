# Get Mailbox information in CSV Format. 

# Checks if Quest Active Roles Management snapin is running and if not, loads it. 
if ((get-pssnapin |% {$_.name}) -notcontains "Microsoft.Exchange.Management.PowerShell.E2010")
{Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010}

$SVR = Read-Host "Enter Exchange Server name"

#get email sizes 
get-mailboxserver $SVR | `
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics |  `
Select-Object DisplayName, ServerName, ItemCount, TotalItemSize, TotalDeletedItemSize, @{label="TotalItemSize(MB)"; expression={$_.TotalItemSize.Value.ToMB()}}, StorageLimitStatus, Database | Export-Csv $SVR-users.csv -force -NoTypeInformation
