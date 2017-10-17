#Email Options
$from = "mailboxreport@yourdomain.com"
$to = "reports@yourdomain.com"
$smtpserver = "your_smtp_server_address"
$subject = "Mailbox Report for $($ENV:COMPUTERNAME)"

#Date variable (used in the file name)
$date = get-date -format yyyyMMdd

$ReportFile = "C:\mailboxreport$($date).htm"

#HTML formatting Options
$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$a = $a + "</style>"

Get-Mailbox | Get-MailboxStatistics | Sort-Object -Property TotalItemSize -descending | select-object  -property DisplayName,ItemCount,@{name="TotalItemSize"; Expression = {$_.TotalitemSize.Value.ToMB()}}, @{name="TotalDeletedItemSize"; Expression = {$_.TotalDeleteditemSize.Value.ToMB()}}| ConvertTo-HTML -head $a | Out-File $ReportFile
$mailboxes = Get-Mailbox | Get-MailboxStatistics | Sort-Object -Property TotalItemSize -descending | select-object  -property DisplayName,ItemCount,@{name="TotalItemSize"; Expression = {$_.TotalitemSize.Value.ToMB()}}, @{name="TotalDeletedItemSize"; Expression = {$_.TotalDeleteditemSize.Value.ToMB()}}
[long]$MailboxTotal = 0
[long]$DeletedTotal = 0
$mailboxes | foreach-object {$Mailboxtotal += $_.TotalItemSize; $DeletedTotal += $_.TotalDeletedItemSize}

Send-MailMessage -from $from -to $to -subject $subject -body "Total Item Size (MB): $($MailboxTotal), Total DeletedItemSize (MB): $($DeletedTotal)" -attachments $ReportFile -smtpserver $smtpserver
